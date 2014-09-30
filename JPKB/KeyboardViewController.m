//
//  KeyboardViewController.m
//  JPKB
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "KeyboardViewController.h"
#import "KeyboardView.h"

@interface KeyboardViewController () <KeyboardViewDelegate>

@property (nonatomic) NSLayoutConstraint *widthConstraint;
@property (nonatomic) NSLayoutConstraint *heightConstraint;

@property (nonatomic) KeyboardView *keyboardView;

@end

@implementation KeyboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.keyboardView = [[KeyboardView alloc] initWithFrame:self.view.bounds];
    self.keyboardView.translatesAutoresizingMaskIntoConstraints = NO;
    self.keyboardView.delegate = self;
    
    [self.view addSubview:self.keyboardView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.keyboardView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.keyboardView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.keyboardView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.keyboardView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view.superview
                                                                    attribute:NSLayoutAttributeLeading
                                                                   multiplier:1.0
                                                                     constant:0.0]];
    
    [self.view.superview addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view.superview
                                                                    attribute:NSLayoutAttributeTrailing
                                                                   multiplier:1.0
                                                                     constant:0.0]];
    
    CGFloat height = CGRectGetHeight(self.view.bounds);
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:0.0
                                                          constant:height + 44.0];
    [self.view addConstraint:self.heightConstraint];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    
    if (width == 0.0) {
        return;
    }
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = CGRectGetWidth(screenBounds);
    CGFloat screenHeight = CGRectGetHeight(screenBounds);
    
    if (screenWidth >= screenHeight) {
        screenWidth = screenHeight;
    }
    
    if (self.heightConstraint) {
        [self.view removeConstraints:@[self.heightConstraint]];
    }
    
    if (width == screenWidth || (width == 320.0 && screenWidth == 414.0)) {
        CGFloat height;
        if (width == 414.0) {
            height = 226.0;
        } else if (width == 375.0 || width == 320.0) {
            height = 216.0;
        }
        
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:0.0
                                                              constant:height + 44.0];
        [self.view addConstraint:self.heightConstraint];
    } else {
        CGFloat height = 162.0;
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:0.0
                                                              constant:height + 32.0];
        [self.view addConstraint:self.heightConstraint];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -

- (void)textWillChange:(id<UITextInput>)textInput
{
    
}

- (void)textDidChange:(id<UITextInput>)textInput
{
    
}

#pragma mark -

- (void)keyboardViewShouldAdvanceToNextInputMode:(KeyboardView *)keyboardView
{
    [self advanceToNextInputMode];
}

- (void)keyboardViewShouldDismiss:(KeyboardView *)keyboardView
{
    [self dismissKeyboard];
}

- (void)keyboardViewDidInputDelete:(KeyboardView *)keyboardView
{
    [self.textDocumentProxy deleteBackward];
}

- (void)keyboardViewDidInputReturn:(KeyboardView *)keyboardView
{
    [self.textDocumentProxy insertText:@"\n"];
}

- (void)keyboardViewBackCursor:(KeyboardView *)keyboardView
{
    [self.textDocumentProxy adjustTextPositionByCharacterOffset:-1];
}

- (void)keyboardViewForwardCursor:(KeyboardView *)keyboardView
{
    [self.textDocumentProxy adjustTextPositionByCharacterOffset:1];
}

- (void)keyboardView:(KeyboardView *)keyboardView didAcceptCandidate:(NSString *)candidate
{
    [self.textDocumentProxy insertText:candidate];
}

@end
