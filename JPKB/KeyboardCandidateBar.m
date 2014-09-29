//
//  KeyboardCandidateBar.m
//  JapaneseKeyboardKit
//
//  Created by kishikawa katsumi on 2014/09/28.
//  Copyright (c) 2014 kishikawa katsumi. All rights reserved.
//

#import "KeyboardCandidateBar.h"
#import "KeyboardCandidateBarCell.h"
#import "InputCandidate.h"

@interface KeyboardCandidateBar () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) UICollectionViewFlowLayout *flowLayout;

@end

@implementation KeyboardCandidateBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor whiteColor];
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout.minimumLineSpacing = 0.0;
    self.flowLayout.minimumInteritemSpacing = 0.0;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0.0, -1.0, 0.0, 0.0);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.bounces = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0, -1.0 / scale, 0.0, 0.0);
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([KeyboardCandidateBarCell class]) bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    
    [self addSubview:self.collectionView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    self.flowLayout.itemSize = CGSizeMake(viewHeight, viewHeight);
    [self.flowLayout invalidateLayout];
}

#pragma mark -

- (void)acceptCurrentCandidate
{
    NSIndexPath *selectedIndexPath = self.collectionView.indexPathsForSelectedItems.firstObject;
    if (selectedIndexPath) {
        [self acceptCandidate:selectedIndexPath];
    }
}

- (void)acceptCandidate:(NSIndexPath *)indexPath
{
    InputCandidate *segment = self.candidates[indexPath.item];
    [self.delegate candidateBar:self didAcceptCandidate:segment];
    
    self.candidates = nil;
}

- (void)selectPreviousCandidate
{
    NSInteger index = 0;
    NSIndexPath *selectedIndexPath = self.collectionView.indexPathsForSelectedItems.firstObject;
    if (selectedIndexPath) {
        [self collectionView:self.collectionView didUnhighlightItemAtIndexPath:selectedIndexPath];
        index = selectedIndexPath.item - 1;
    }
    
    NSUInteger count = self.candidates.count;
    if (count > 0) {
        if (index <= 0) {
            index = count - 1;
        }
        if (index < count) {
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
            [self.collectionView selectItemAtIndexPath:previousIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionRight];
            [self collectionView:self.collectionView didHighlightItemAtIndexPath:previousIndexPath];
        }
    }
}

- (void)selectNextCandidate
{
    NSInteger index = 0;
    NSIndexPath *selectedIndexPath = self.collectionView.indexPathsForSelectedItems.firstObject;
    if (selectedIndexPath) {
        [self collectionView:self.collectionView didUnhighlightItemAtIndexPath:selectedIndexPath];
        index = selectedIndexPath.item + 1;
    }
    
    NSUInteger count = self.candidates.count;
    if (count > 0) {
        if (index == count) {
            index = 0;
        }
        if (index < count) {
            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
            [self.collectionView selectItemAtIndexPath:nextIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionRight];
            [self collectionView:self.collectionView didHighlightItemAtIndexPath:nextIndexPath];
        }
    }
}

- (InputCandidate *)selectedCandidate
{
    InputCandidate *segment;
    NSIndexPath *selectedIndexPath = self.collectionView.indexPathsForSelectedItems.firstObject;
    if (selectedIndexPath) {
        segment = self.candidates[selectedIndexPath.item];
    }
    return segment;
}

- (void)setCandidates:(NSArray *)candidates
{
    _candidates = candidates;
    
    NSIndexPath *selectedIndexPath = self.collectionView.indexPathsForSelectedItems.firstObject;
    if (selectedIndexPath) {
        [self collectionView:self.collectionView didUnhighlightItemAtIndexPath:selectedIndexPath];
        [self.collectionView deselectItemAtIndexPath:selectedIndexPath animated:NO];
    }
    
    self.collectionView.contentOffset = CGPointZero;
    [self.collectionView reloadData];
}

#pragma mark -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.candidates.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger item = indexPath.item;
    
    KeyboardCandidateBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    InputCandidate *segment = self.candidates[item];
    
    cell.text = segment.candidate;
    
    cell.showsTopSeparator = item < self.candidates.count;
    cell.showsBottomSeparator = item == self.candidates.count - 1;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    InputCandidate *segment = self.candidates[indexPath.item];
    CGSize size = [segment.candidate sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0]}];
    return CGSizeMake(size.width + 20.0, self.flowLayout.itemSize.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self acceptCandidate:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithRed:0.773 green:0.780 blue:0.820 alpha:1.000];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = nil;
}

@end
