//
//  InputManager.h
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol InputManagerDelegate;

@interface InputManager : NSObject

@property (nonatomic, readonly) NSArray *candidates;
@property (nonatomic, weak) id delegate;

- (void)requestCandidatesForInput:(NSString *)input;

@end

@protocol InputManagerDelegate <NSObject>

- (void)inputManager:(InputManager *)inputManager didCompleteWithCandidates:(NSArray *)candidates;
- (void)inputManager:(InputManager *)inputManager didFailWithError:(NSError *)error;

@end
