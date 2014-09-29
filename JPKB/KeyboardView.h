//
//  KeyboardView.h
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardLayout.h"

@class KeyboardButton;

@interface KeyboardView : UIView

@property (nonatomic, weak) id delegate;
@property (nonatomic) KeyboardInputMode inputMode;

- (void)buttonDidTouchDown:(KeyboardButton *)button;
- (void)buttonDidTouchUp:(KeyboardButton *)button;
- (void)buttonDidTouchDownRepeat:(KeyboardButton *)button;

@end

@protocol KeyboardViewDelegate <NSObject>

- (void)keyboardViewShouldAdvanceToNextInputMode:(KeyboardView *)keyboardView;
- (void)keyboardViewShouldDismiss:(KeyboardView *)keyboardView;
- (void)keyboardViewDidInputDelete:(KeyboardView *)keyboardView;
- (void)keyboardViewDidInputReturn:(KeyboardView *)keyboardView;
- (void)keyboardViewBackCursor:(KeyboardView *)keyboardView;
- (void)keyboardViewForwardCursor:(KeyboardView *)keyboardView;
- (void)keyboardView:(KeyboardView *)keyboardView didAcceptCandidate:(NSString *)candidate;

@end
