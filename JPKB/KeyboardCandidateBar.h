//
//  KeyboardCandidateBar.h
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InputCandidate;

@protocol KeyboardCandidateBarDelegate;

@interface KeyboardCandidateBar : UIView

@property (nonatomic, weak) id<KeyboardCandidateBarDelegate> delegate;
@property (nonatomic) NSArray *candidates;

@property (nonatomic, readonly) InputCandidate *selectedCandidate;

- (void)acceptCurrentCandidate;
- (void)selectPreviousCandidate;
- (void)selectNextCandidate;

@end

@protocol KeyboardCandidateBarDelegate <NSObject>

- (void)candidateBar:(KeyboardCandidateBar *)candidateBar didAcceptCandidate:(InputCandidate *)segment;

@end
