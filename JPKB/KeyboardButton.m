//
//  KeyboardButton.m
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "KeyboardButton.h"

@implementation KeyboardButton

- (CGRect)backgroundRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 3.0, 3.0);
}

@end
