//
//  InputCandidate.h
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InputCandidate : NSObject

@property (nonatomic) NSString *input;
@property (nonatomic) NSString *candidate;

- (id)initWithInput:(NSString *)input candidate:(NSString *)candidate;

@end
