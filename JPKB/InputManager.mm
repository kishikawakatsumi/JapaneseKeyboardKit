//
//  InputManager.m
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "InputManager.h"
#import "InputCandidate.h"

#if !TARGET_IPHONE_SIMULATOR
#define USE_MOZC 1
#endif

#if USE_MOZC

#include <string>

using namespace std;

#include "composer/composer.h"
#include "composer/table.h"
#include "converter/conversion_request.h"
#include "converter/converter_interface.h"
#include "converter/segments.h"
#include "prediction/predictor_interface.h"
#include "engine/engine_factory.h"
#include "engine/engine_interface.h"

void MakeSegmentsForSuggestion(const string key, mozc::Segments *segments) {
    segments->Clear();
    segments->set_max_prediction_candidates_size(10);
    segments->set_request_type(mozc::Segments::SUGGESTION);
    mozc::Segment *seg = segments->add_segment();
    seg->set_key(key);
    seg->set_segment_type(mozc::Segment::FREE);
}

void MakeSegmentsForPrediction(const string key, mozc::Segments *segments) {
    segments->Clear();
    segments->set_max_prediction_candidates_size(50);
    segments->set_request_type(mozc::Segments::PREDICTION);
    mozc::Segment *seg = segments->add_segment();
    seg->set_key(key);
    seg->set_segment_type(mozc::Segment::FREE);
}

@interface InputManager ()

@property (nonatomic, readwrite) NSArray *candidates;
@property (nonatomic) NSOperationQueue *networkQueue;

@end

@implementation InputManager {
    scoped_ptr<mozc::EngineInterface> engine;
    mozc::ConverterInterface *converter;
    mozc::PredictorInterface *predictor;
}

- (id)init
{
    self = [super init];
    if (self) {
        engine.reset(mozc::EngineFactory::Create());
        converter = engine->GetConverter();
        CHECK(converter);
        predictor = engine->GetPredictor();
        CHECK(predictor);
    }
    
    return self;
}

- (void)requestCandidatesForInput:(NSString *)input
{
    mozc::commands::Request request;
    mozc::Segments segments;
    
    mozc::composer::Table table;
    mozc::composer::Composer composer(&table, &request);
    composer.InsertCharacterPreedit(input.UTF8String);
    mozc::ConversionRequest conversion_request(&composer, &request);
    
    converter->StartPredictionForRequest(conversion_request, &segments);
    
    NSMutableOrderedSet *candidates = [[NSMutableOrderedSet alloc] init];
    
    for (int i = 0; i < segments.segments_size(); ++i) {
        const mozc::Segment &segment = segments.segment(i);
        for (int j = 0; j < segment.candidates_size(); ++j) {
            const mozc::Segment::Candidate &cand = segment.candidate(j);
            [candidates addObject:[[InputCandidate alloc] initWithInput:[NSString stringWithUTF8String:segment.key().c_str()] candidate:[NSString stringWithUTF8String:cand.value.c_str()]]];
        }
    }
    
    converter->StartConversionForRequest(conversion_request, &segments);
    
    for (int i = 0; i < segments.segments_size(); ++i) {
        const mozc::Segment &segment = segments.segment(i);
        for (int j = 0; j < segment.candidates_size(); ++j) {
            const mozc::Segment::Candidate &cand = segment.candidate(j);
            [candidates addObject:[[InputCandidate alloc] initWithInput:[NSString stringWithUTF8String:cand.key.c_str()] candidate:[NSString stringWithUTF8String:cand.value.c_str()]]];
        }
    }
    
    self.candidates = candidates.array;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate inputManager:self didCompleteWithCandidates:self.candidates];
    });
}

@end

#else

@interface InputManager ()

@property (nonatomic, readwrite) NSArray *candidates;
@property (nonatomic) NSOperationQueue *networkQueue;

@end

@implementation InputManager

- (id)init
{
    self = [super init];
    if (self) {
        self.networkQueue = [[NSOperationQueue alloc] init];
        self.networkQueue.maxConcurrentOperationCount = 1;
    }
    
    return self;
}

- (void)requestCandidatesForInput:(NSString *)input
{
    [self.networkQueue cancelAllOperations];
    
    NSString *encodedText =[input stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/transliterate?langpair=ja-Hira%%7Cja&text=%@", encodedText]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0f];
    request.HTTPShouldUsePipelining = YES;
    
    [NSURLConnection sendAsynchronousRequest:request queue:self.networkQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSMutableArray *candidates = [[NSMutableArray alloc] init];
            
            NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            for (NSArray *result in results) {
                NSString *text = result.firstObject;
                NSArray *list = result.lastObject;
                for (NSString *candidate in list) {
                    [candidates addObject:[[InputCandidate alloc] initWithInput:text candidate:candidate]];
                }
                
                self.candidates = candidates;
                
                break;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate inputManager:self didCompleteWithCandidates:self.candidates];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate inputManager:self didFailWithError:connectionError];
            });
        }
    }];
}

@end

#endif
