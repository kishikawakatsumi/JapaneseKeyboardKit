//
//  KeyboardCandidateBarCell.m
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/13.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "KeyboardCandidateBarCell.h"

@interface KeyboardCandidateBarCell ()

@property (nonatomic) UIView *leftSeparator;
@property (nonatomic) UIView *rightSeparator;

@end

@implementation KeyboardCandidateBarCell

- (void)awakeFromNib
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    self.leftSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0 / scale, CGRectGetHeight(self.bounds))];
    self.leftSeparator.backgroundColor = [UIColor colorWithRed:0.773 green:0.780 blue:0.820 alpha:1.000];
    [self.contentView addSubview:self.leftSeparator];
    
    self.rightSeparator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - 1.0 / scale, 0.0, 1.0 / scale, CGRectGetHeight(self.bounds))];
    self.rightSeparator.backgroundColor = [UIColor colorWithRed:0.773 green:0.780 blue:0.820 alpha:1.000];
    [self.contentView addSubview:self.rightSeparator];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.text = self.text;
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    self.leftSeparator.frame = CGRectMake(0.0, 0.0, 1.0 / scale, CGRectGetHeight(self.bounds));
    self.rightSeparator.frame = CGRectMake(CGRectGetWidth(self.bounds) - 1.0 / scale, 0.0f, 1.0 / scale, CGRectGetHeight(self.bounds));
    
    self.leftSeparator.hidden = !self.showsTopSeparator;
    self.rightSeparator.hidden = !self.showsBottomSeparator;
}

- (void)setText:(NSString *)text
{
    _text = text;
    [self setNeedsLayout];
}

@end
