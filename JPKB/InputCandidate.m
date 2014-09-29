//
//  InputCandidate.m
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "InputCandidate.h"

@implementation InputCandidate

- (id)initWithInput:(NSString *)input candidate:(NSString *)candidate
{
    self = [super init];
    if (self) {
        _input = input;
        _candidate = candidate;
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    return ([object isKindOfClass:[InputCandidate class]] &&
            [self.input isEqualToString:[object input]] &&
            [self.candidate isEqualToString:[object candidate]]);
}

#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))

- (NSUInteger)hash
{
    return NSUINTROTATE([_input hash], NSUINT_BIT / 2) ^ [_candidate hash];
}

@end
