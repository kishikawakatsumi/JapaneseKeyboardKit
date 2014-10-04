//
//  KanaInputEngine.h
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeyboardView.h"

@interface KanaInputEngine : NSObject

@property (nonatomic, weak) id delegate;

@property (nonatomic) BOOL shifted;
@property (nonatomic) NSString *text;

- (void)insertCharacter:(NSString *)input;
- (void)backspace;

@end

@protocol KeyboardInputEngineDelegate <NSObject>

- (void)keyboardInputEngine:(KanaInputEngine *)engine processedText:(NSString *)text displayText:(NSString *)displayText;

@end
