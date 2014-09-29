//
//  KeyboardView.m
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "KeyboardView.h"
#import "KeyboardButton.h"
#import "KeyboardCandidateBar.h"
#import "KanaInputEngine.h"
#import "InputManager.h"
#import "InputCandidate.h"

const CGFloat AccessoryViewHeightDefault = 40.0;
const CGFloat AccessoryViewHeightLandscape = 30.0;
const CGFloat MarkedTextLabelHeightDefault = 14.0;
const CGFloat MarkedTextLabelHeightLandscape = 10.0;

typedef NS_ENUM(NSInteger, KeyboardSize) {
    KeyboardSizeUnknown = -1,
    KeyboardSize4Portrait,
    KeyboardSize4Landscape,
    KeyboardSize5Landscape,
    KeyboardSize6Portrait,
    KeyboardSize6Landscape,
    KeyboardSize6PlusPortrait,
    KeyboardSize6PlusLandscape,
};

@interface KeyboardView () <KeyboardInputEngineDelegate, KeyboardCandidateBarDelegate>

@property (nonatomic) KanaInputEngine *inputEngine;
@property (nonatomic) InputManager *inputManager;

@property (nonatomic) KeyboardLayout *keyboardLayout;
@property (nonatomic) KeyboardSize keyboardSize;

@property (nonatomic) BOOL shifted;
@property (nonatomic) BOOL shiftLocked;

@property (nonatomic) NSString *markedText;
@property (nonatomic) UILabel *markedTextLabel;

@property (nonatomic) KeyboardCandidateBar *candidateBar;

@property (nonatomic) UIView *borderTop;
@property (nonatomic) UIView *borderBottom;

@end

@implementation KeyboardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.inputEngine = [[KanaInputEngine alloc] init];
        self.inputEngine.delegate = self;
        
        self.inputManager = [[InputManager alloc] init];
        self.inputManager.delegate = self;
        
        CGRect labelFrame = frame;
        labelFrame.size.height = MarkedTextLabelHeightDefault;
        UILabel *markedTextLabel = [[UILabel alloc] initWithFrame:labelFrame];
        markedTextLabel.backgroundColor = [UIColor whiteColor];
        markedTextLabel.font = [UIFont systemFontOfSize:12.0];
        markedTextLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1.0];
        [self addSubview:markedTextLabel];
        self.markedTextLabel = markedTextLabel;
        
        CGRect barFrame = labelFrame;
        barFrame.origin.y = CGRectGetHeight(labelFrame);
        barFrame.size.height = AccessoryViewHeightDefault - CGRectGetHeight(labelFrame);
        KeyboardCandidateBar *candidateBar = [[KeyboardCandidateBar alloc] initWithFrame:barFrame];
        candidateBar.delegate = self;
        [self addSubview:candidateBar];
        self.candidateBar = candidateBar;
        
        UIColor *borderColor = [UIColor colorWithWhite:0.784 alpha:1.000];
        CGFloat scale = [[UIScreen mainScreen] scale];
        
        UIView *borderTop = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds), 1.0 / scale)];
        borderTop.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        borderTop.backgroundColor = borderColor;
        [self addSubview:borderTop];
        self.borderTop = borderTop;
        
        UIView *borderBottom = [[UIView alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(barFrame) - 1.0 / scale, CGRectGetWidth(self.bounds), 1.0 / scale)];
        borderBottom.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        borderBottom.backgroundColor = borderColor;
        [self addSubview:borderBottom];
        self.borderBottom = borderBottom;
        
        self.markedText = @"";
        
        [self setupKeyboardLayout];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.keyboardLayout) {
        [self setupKeyboardLayout];
        [self.keyboardLayout setupKeyboardButtonsWithView:self];
    }
    
    [self updateKeyboardLayout];
}

#pragma mark -

- (void)setupKeyboardLayout
{
    KeyboardSize keyboardSize = [self currentKeyboardSize];
    switch (keyboardSize) {
        case KeyboardSize4Portrait:
        case KeyboardSize4Landscape:
        case KeyboardSize5Landscape:
            self.keyboardLayout = [KeyboardLayoutPhone5 keyboardLayout];
            break;
            
        case KeyboardSize6Portrait:
        case KeyboardSize6Landscape:
            self.keyboardLayout = [KeyboardLayoutPhone6 keyboardLayout];
            break;
            
        case KeyboardSize6PlusPortrait:
        case KeyboardSize6PlusLandscape:
            self.keyboardLayout = [KeyboardLayoutPhone6Plus keyboardLayout];
            break;
            
        case KeyboardSizeUnknown:
            break;
    }
    
    self.keyboardLayout.inputMode = self.inputMode;
}

- (void)updateKeyboardLayout
{
    KeyboardMetrics metrics = [self currentKeyboardMetrics];
    self.keyboardLayout.metrics = metrics;
    
    CGRect bounds = self.bounds;
    
    if (metrics == KeyboardMetricsDefault) {
        CGRect labelFrame = bounds;
        labelFrame.size.height = MarkedTextLabelHeightDefault;
        self.markedTextLabel.frame = labelFrame;
        
        CGRect barFrame = labelFrame;
        barFrame.origin.y = CGRectGetHeight(labelFrame);
        barFrame.size.height = AccessoryViewHeightDefault - CGRectGetHeight(labelFrame);
        self.candidateBar.frame = barFrame;
    } else {
        [self.markedTextLabel sizeToFit];
        CGRect labelFrame = self.markedTextLabel.frame;
        labelFrame.size.height = AccessoryViewHeightLandscape;
        self.markedTextLabel.frame = labelFrame;
        
        CGRect barFrame = labelFrame;
        barFrame.origin.x = CGRectGetMaxX(labelFrame);
        barFrame.size.width = CGRectGetWidth(bounds) - CGRectGetMaxX(labelFrame);
        barFrame.size.height = AccessoryViewHeightLandscape;
        self.candidateBar.frame = barFrame;
    }
    
    CGRect borderBottomFrame = self.borderBottom.frame;
    borderBottomFrame.origin.y = CGRectGetMaxY(self.candidateBar.frame) - 1.0 / [[UIScreen mainScreen] scale];
    self.borderBottom.frame = borderBottomFrame;
}

- (KeyboardSize)currentKeyboardSize
{
    CGRect bounds = self.bounds;
    if (CGRectIsEmpty(bounds)) {
        return KeyboardSizeUnknown;
    }
    
    CGFloat viewWidth = CGRectGetWidth(bounds);
    CGFloat viewHeight = CGRectGetHeight(bounds);
    
    if (viewWidth >= 414.0 && viewHeight >= 226.0) {
        return KeyboardSize6PlusPortrait;
    } else if (viewWidth >= 375.0 && viewHeight >= 216.0) {
        return KeyboardSize6Portrait;
    } else if (viewWidth >= 320.0 && viewHeight >= 216.0) {
        return KeyboardSize4Portrait;
    } else if (viewWidth >= 736.0 && viewHeight >= 162.0) {
        return KeyboardSize6PlusLandscape;
    } else if (viewWidth >= 667.0 && viewHeight >= 162.0) {
        return KeyboardSize6Landscape;
    } else if (viewWidth >= 568.0 && viewHeight >= 162.0) {
        return KeyboardSize5Landscape;
    } else if (viewWidth >= 480.0 && viewHeight >= 162.0) {
        return KeyboardSize4Landscape;
    }
    
    return KeyboardSizeUnknown;
}

- (KeyboardMetrics)currentKeyboardMetrics
{
    CGRect bounds = self.bounds;
    if (CGRectIsEmpty(bounds)) {
        return KeyboardMetricsDefault;
    }
    
    KeyboardSize keyboardSize = [self currentKeyboardSize];
    switch (keyboardSize) {
        case KeyboardSize4Portrait:
        case KeyboardSize6Portrait:
        case KeyboardSize6PlusPortrait:
        case KeyboardSizeUnknown:
            return KeyboardMetricsDefault;
        case KeyboardSize4Landscape:
        case KeyboardSize6Landscape:
        case KeyboardSize6PlusLandscape:
            return KeyboardMetricsLandscape;
        case KeyboardSize5Landscape:
            return KeyboardMetricsLandscape568;
    }
}

#pragma mark -

- (void)setupEventHandlers:(UIButton *)button
{
    [button addTarget:self action:@selector(buttonDidTouchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(buttonDidTouchUp:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -

- (void)setInputMode:(KeyboardInputMode)inputMode
{
    _inputMode = inputMode;
    self.keyboardLayout.inputMode = inputMode;
}

- (void)setMarkedText:(NSString *)markedText
{
    _markedText = markedText;
    self.markedTextLabel.text = markedText;
    self.inputEngine.text = markedText;
    [self setNeedsLayout];
}

#pragma mark -

- (void)buttonDidTouchDown:(KeyboardButton *)button
{
    KeyboardButtonIndex keyIndex = button.keyIndex;
    if (keyIndex < KeyboardButtonIndexNextKeyboard) {
        NSString *input = [button titleForState:UIControlStateNormal];
        if (self.inputMode == KeyboardInputModeKana) {
            [self.inputEngine addKeyInput:input];
        } else {
            [self.delegate keyboardView:self didAcceptCandidate:input];
        }
        [self resetShift];
    } else {
        switch (keyIndex) {
            case KeyboardButtonIndexToggleInputMode:
                [self handleToggleInputMode];
                break;
                
            case KeyboardButtonIndexShift:
                [self handleShift];
                break;
                
            case KeyboardButtonIndexSpace:
                [self handleSpace];
                break;
                
            case KeyboardButtonIndexComma:
                [self handleComma];
                break;
                
            case KeyboardButtonIndexPeriod:
                [self handlePeriod];
                break;
                
            case KeyboardButtonIndexDelete:
                [self handleDelete];
                break;
                
            case KeyboardButtonIndexPreviousCursor:
                [self.delegate keyboardViewBackCursor:self];
                break;
                
            case KeyboardButtonIndexNextCursor:
                [self.delegate keyboardViewForwardCursor:self];
                break;
                
            default:
                break;
        }
    }
}

- (void)buttonDidTouchUp:(KeyboardButton *)button
{
    KeyboardButtonIndex keyIndex = button.keyIndex;
    switch (keyIndex) {
        case KeyboardButtonIndexNextKeyboard:
            [self acceptCurrentCandidate];
            [self.delegate keyboardViewShouldAdvanceToNextInputMode:self];
            break;
            
        case KeyboardButtonIndexReturn:
            [self handleReturn];
            break;
            
        case KeyboardButtonIndexDismiss:
            [self.delegate keyboardViewShouldDismiss:self];
            [self resetShift];
            break;
            
        case KeyboardButtonIndexPreviousCandidate:
            [self.candidateBar selectPreviousCandidate];
            break;
            
        case KeyboardButtonIndexNextCandidate:
            [self.candidateBar selectNextCandidate];
            break;
            
        default:
            break;
    }
}

- (void)buttonDidTouchDownRepeat:(KeyboardButton *)button
{
    KeyboardButtonIndex keyIndex = button.keyIndex;
    switch (keyIndex) {
        case KeyboardButtonIndexShift:
            [self handleShiftLock];
            break;
            
        default:
            break;
    }
}

- (void)handleToggleInputMode
{
    if (self.inputMode == KeyboardInputModeKana) {
        self.inputMode = KeyboardInputModeNumberPunctual;
    } else {
        self.inputMode = KeyboardInputModeKana;
    }
}

- (void)handleSpace
{
    NSString *markedText = self.markedText;
    NSUInteger length = markedText.length;
    if (length == 0) {
        [self.delegate keyboardView:self didAcceptCandidate:@" "];
    } else {
        [self.candidateBar selectNextCandidate];
    }
}

- (void)handleComma
{
    if (self.inputMode == KeyboardInputModeKana) {
        [self.inputEngine addKeyInput:@"、"];
    } else {
        [self.delegate keyboardView:self didAcceptCandidate:@","];
    }
}

- (void)handlePeriod
{
    if (self.inputMode == KeyboardInputModeKana) {
        [self.inputEngine addKeyInput:@"。"];
    } else {
        [self.delegate keyboardView:self didAcceptCandidate:@"."];
    }
}

- (void)handleDelete
{
    NSString *markedText = self.markedText;
    NSUInteger length = markedText.length;
    if (length == 0) {
        [self.delegate keyboardViewDidInputDelete:self];
    } else {
        self.markedText = [markedText substringToIndex:length - 1];
        if (self.markedText.length > 0) {
            [self.inputManager requestCandidatesForInput:self.markedText];
        } else {
            self.candidateBar.candidates = nil;
        }
    }
}

- (void)handleReturn
{
    NSString *markedText = self.markedText;
    NSUInteger length = markedText.length;
    if (length == 0) {
        [self.delegate keyboardViewDidInputReturn:self];
    } else {
        [self acceptCurrentCandidate];
    }
}

- (void)handleShift
{
    if (self.shiftLocked) {
        self.shiftLocked = NO;
    } else {
        self.shifted = !self.shifted;
    }
}

- (void)handleShiftLock
{
    self.shiftLocked = !self.shiftLocked;
}

- (void)resetShift
{
    if (!self.shiftLocked) {
        self.shifted = NO;
    }
}

#pragma mark -

- (void)setShifted:(BOOL)shifted
{
    _shifted = shifted;
    self.inputEngine.shifted = shifted;
    self.keyboardLayout.shifted = shifted;
}

- (void)setShiftLocked:(BOOL)shiftLocked
{
    _shiftLocked = shiftLocked;
    _shifted = shiftLocked;
    self.inputEngine.shifted = shiftLocked;
    self.keyboardLayout.shiftLocked = shiftLocked;
}

#pragma mark -

- (void)acceptCurrentCandidate
{
    if (self.candidateBar.selectedCandidate) {
        [self.candidateBar acceptCurrentCandidate];
    } else {
        [self.delegate keyboardView:self didAcceptCandidate:self.markedText];
        
        self.markedText = @"";
        self.candidateBar.candidates = nil;
    }
}

#pragma mark -

- (void)keyboardInputEngine:(KanaInputEngine *)engine processedText:(NSString *)text displayText:(NSString *)displayText;
{
    self.markedText = displayText;
    [self.inputManager requestCandidatesForInput:text];
}

#pragma mark -

- (void)inputManager:(InputManager *)inputManager didCompleteWithCandidates:(NSArray *)candidates
{
    self.candidateBar.candidates = candidates;
}

- (void)inputManager:(InputManager *)inputManager didFailWithError:(NSError *)error
{
    
}

#pragma mark -

- (void)candidateBar:(KeyboardCandidateBar *)candidateBar didAcceptCandidate:(InputCandidate *)segment
{
    NSString *input = segment.input;
    NSRange range = [self.markedText rangeOfString:input];
    if (range.location != NSNotFound) {
        self.markedText = [self.markedText stringByReplacingCharactersInRange:range withString:@""];
    }
    
    if (self.markedText.length > 0) {
        [self.inputManager requestCandidatesForInput:self.markedText];
    }
    
    [self.delegate keyboardView:self didAcceptCandidate:segment.candidate];
}

@end
