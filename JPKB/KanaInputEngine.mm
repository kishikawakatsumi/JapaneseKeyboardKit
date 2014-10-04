//
//  KanaInputEngine.m
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "KanaInputEngine.h"

#if !TARGET_IPHONE_SIMULATOR
#define USE_MOZC 1
#endif

#if USE_MOZC

#include <iostream>
#include <string>

using namespace std;

#include "composer/composer.h"

#include "base/flags.h"
#include "base/scoped_ptr.h"
#include "composer/composition_interface.h"
#include "composer/table.h"
#include "session/commands.pb.h"
#include "transliteration/transliteration.h"

@interface KanaInputEngine ()

@property (nonatomic) NSMutableString *proccessedText;
@property (nonatomic) NSMutableString *displayText;

@end

@implementation KanaInputEngine {
    mozc::composer::Table table;
    mozc::composer::Composer *composer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.proccessedText = [[NSMutableString alloc] init];
        self.displayText = [[NSMutableString alloc] init];
        
        const char kDefaultPreeditTableFile[] = "system://romanji-hiragana.tsv";
        table.LoadFromFile(kDefaultPreeditTableFile);
        
        composer = new mozc::composer::Composer(&table, &mozc::commands::Request::default_instance());
    }
    return self;
}

- (void)dealloc
{
    delete composer;
}

- (void)insertCharacter:(NSString *)input
{
    if (_shifted) {
        input = input.uppercaseString;
    } else {
        input = input.lowercaseString;
    }
    
    composer->InsertCharacter(input.UTF8String);
    string output;
    composer->GetStringForPreedit(&output);
    
    _proccessedText.string = [NSString stringWithUTF8String:output.c_str()];
    _displayText.string = _proccessedText.copy;
    
    [self.delegate keyboardInputEngine:self processedText:_proccessedText.copy displayText:_displayText.copy];
}

- (void)backspace
{
    composer->Backspace();
    [self.delegate keyboardInputEngine:self processedText:_proccessedText.copy displayText:_displayText.copy];
}

- (void)setText:(NSString *)text
{
    composer->Reset();
    composer->InsertCharacter(text.UTF8String);
}

@end

#else

@interface KanaInputEngine ()

@property (nonatomic) NSMutableString *proccessedText;
@property (nonatomic) NSMutableString *displayText;

@end

@implementation KanaInputEngine

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.proccessedText = [[NSMutableString alloc] init];
        self.displayText = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)insertCharacter:(NSString *)input
{
    if (_shifted) {
        input = input.uppercaseString;
    } else {
        input = input.lowercaseString;
    }
    
    if ([input compare:@"A" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
        [input compare:@"I" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
        [input compare:@"U" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
        [input compare:@"E" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
        [input compare:@"O" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        [_displayText appendString:input];
        
        NSMutableString *kanaText = [[NSMutableString alloc] initWithString:_displayText];
        CFStringTransform((CFMutableStringRef)kanaText, NULL, kCFStringTransformLatinHiragana, FALSE);
        
        _proccessedText.string = kanaText;
        _displayText.string = kanaText;
    } else if (_displayText.length > 0 && [[_displayText substringFromIndex:_displayText.length - 1] compare:input options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        if ([input compare:@"N" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            [_displayText replaceCharactersInRange:NSMakeRange(_displayText.length - 1, 1) withString:@"ん"];
        } else {
            [_displayText replaceCharactersInRange:NSMakeRange(_displayText.length - 1, 1) withString:@"っ"];
            [_displayText appendString:input];
        }
    } else {
        [_displayText appendString:input];
    }
    
    [self.delegate keyboardInputEngine:self processedText:_proccessedText.copy displayText:_displayText.copy];
}

- (void)backspace
{
    if (_displayText.length > 0) {
        [_displayText deleteCharactersInRange:NSMakeRange(_displayText.length - 1, 1)];
    }
    _proccessedText.string = _displayText.copy;
}

- (void)setText:(NSString *)text
{
    _proccessedText.string = text;
    _displayText.string = text;
}

@end

#endif
