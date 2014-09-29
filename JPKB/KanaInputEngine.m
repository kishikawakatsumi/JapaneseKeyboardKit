//
//  KanaInputEngine.m
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "KanaInputEngine.h"

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

- (void)addKeyInput:(NSString *)input
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

- (void)setText:(NSString *)text
{
    _proccessedText.string = text;
    _displayText.string = text;
}

@end
