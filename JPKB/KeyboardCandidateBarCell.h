//
//  KeyboardCandidateBarCell.h
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/13.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyboardCandidateBarCell : UICollectionViewCell

@property (nonatomic) NSString *text;
@property (nonatomic) IBOutlet UILabel *textLabel;

@property (nonatomic) BOOL showsTopSeparator;
@property (nonatomic) BOOL showsBottomSeparator;

@end
