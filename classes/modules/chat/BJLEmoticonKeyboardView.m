//
//  BJLEmoticonKeyboardView.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-04-17.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLEmoticonKeyboardView.h"

#import "BJLViewControllerImports.h"

#import "BJLEmoticonCell.h"

NS_ASSUME_NONNULL_BEGIN

/*
 iPhone7 portrait keyboard height: 258
 20 * 2 + 15 * 3 + 32 * 4 = 213
 */
static const CGFloat iPadWidth = 375.0;
static const CGFloat verMargin = 20.0, interitemSpacing = 15.0, lineSpacing = 10.0, itemSize = 32.0;
static const NSInteger cellsPerColumn = 4;
static const CGFloat keyboardHeight = (verMargin * 2
                                       + interitemSpacing * (cellsPerColumn - 1)
                                       + itemSize * cellsPerColumn);

static inline CGFloat calcHorMargin(CGFloat width, NSInteger cellsPerRow) {
    return (width - cellsPerRow * itemSize - (cellsPerRow - 1) * lineSpacing) / 2;
}
static inline NSInteger calcCellsPerRow(CGFloat width) {
    NSInteger cellsPerRow = 0;
    while (calcHorMargin(width, cellsPerRow + 1) >= lineSpacing) {
        cellsPerRow += 1;
    }
    return cellsPerRow;
}
static inline NSInteger calcCellsPerPage(NSInteger cellsPerRow) {
    return cellsPerColumn * cellsPerRow;
}

static NSString * const reuseIdentifier = @"emoticon";

@interface BJLEmoticonKeyboardView ()

@property (nonatomic) BOOL iPad;

@property (nonatomic) NSInteger cellsPerRow, cellsPerPage;
@property (nonatomic) UICollectionViewFlowLayout *collectionLayout;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) UIPageControl *pageControl;

@end

@implementation BJLEmoticonKeyboardView

- (instancetype)init {
    return [self initForIdiomPad:NO];
}

- (instancetype)initForIdiomPad:(BOOL)iPad {
    self = [super initWithFrame:bjl_structSet((CGRect)CGRectZero, {
        set.size = [self intrinsicContentSize];
    })];
    if (self) {
        self.iPad = iPad;
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = self.iPad ? nil : [UIColor whiteColor];
        
        self.collectionView = ({
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                                                  collectionViewLayout:[self makeLayout]];
            collectionView.pagingEnabled = YES;
            collectionView.showsHorizontalScrollIndicator = NO;
            collectionView.showsVerticalScrollIndicator = NO;
            collectionView.bounces = YES;
            collectionView.alwaysBounceHorizontal = YES;
            collectionView.alwaysBounceVertical = NO;
            collectionView.backgroundColor = [UIColor clearColor];
            [collectionView registerClass:[BJLEmoticonCell class] forCellWithReuseIdentifier:reuseIdentifier];
            collectionView.dataSource = self;
            collectionView.delegate = self;
            
            [self addSubview:collectionView];
            [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.equalTo(self.bjl_safeAreaLayoutGuide ?: self);
                make.height.equalTo(@(keyboardHeight));
            }];
            
            collectionView;
        });
        
        self.pageControl = ({
            UIPageControl *pageControl = [UIPageControl new];
            pageControl.hidesForSinglePage = YES;
            pageControl.pageIndicatorTintColor = [UIColor bjl_grayBorderColor];
            pageControl.currentPageIndicatorTintColor = [UIColor bjl_blueBrandColor];
            [self addSubview:pageControl];
            [pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.bjl_safeAreaLayoutGuide ?: self);
                make.bottom.equalTo(self.bjl_safeAreaLayoutGuide ?: self).with.offset(- BJLViewSpaceS);
                make.height.equalTo(@8.0);
            }];
            bjl_weakify(self);
            [pageControl bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
                bjl_strongify(self);
                NSInteger page = self.pageControl.currentPage;
                CGFloat width = CGRectGetWidth(self.collectionView.bounds);
                [self.collectionView setContentOffset:CGPointMake(page * width, 0) animated:YES];
            } forControlEvents:UIControlEventValueChanged];
            pageControl;
        });
   }
    return self;
}

#pragma mark - layout

// @see https://stackoverflow.com/a/40359406/456536
- (CGSize)intrinsicContentSize {
    CGFloat height = keyboardHeight;
    if (!self.iPad) {
        if (@available(iOS 11.0, *)) {
            height += self.safeAreaInsets.bottom;
        }
    }
    return CGSizeMake(self.iPad ? iPadWidth : UIViewNoIntrinsicMetric, height);
}

- (void)safeAreaInsetsDidChange {
    [super safeAreaInsetsDidChange];
    // @see https://stackoverflow.com/a/40359406/456536
    [self invalidateIntrinsicContentSize];
}

- (void)updateLayoutForTraitCollection:(UITraitCollection *)newCollection animated:(BOOL)animated {
    // !!!: dispatch_after 解决 iOS 11 旋转、collectionView 刷新之后表情错乱的问题，bjl_dispatch_async_main_queue 不管用
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateLayoutAnimated:animated];
    });
}

- (void)updateLayoutAnimated:(BOOL)animated {
    UICollectionViewFlowLayout *layout = [self makeLayout]; // update self.cellsPerRow & self.cellsPerPage
    { // http://stackoverflow.com/a/36304943/456536
        [self.collectionView reloadData];
        [self.collectionView.collectionViewLayout invalidateLayout];
        [self.collectionView setCollectionViewLayout:layout animated:animated];
    }
    
    NSInteger currentPage = self.pageControl.currentPage;
    self.pageControl.numberOfPages = [self.collectionView numberOfSections];
    self.pageControl.currentPage = MIN(currentPage, self.pageControl.numberOfPages);
}

- (UICollectionViewFlowLayout *)makeLayout {
    CGFloat layoutWidth = 0.0;
    if (self.iPad) {
        layoutWidth = iPadWidth;
    }
    else if (@available(iOS 11.0, *)) {
        layoutWidth = CGRectGetWidth(self.safeAreaLayoutGuide.layoutFrame); // maybe 0.0
    }
    
    // NO else, prevent layoutWidth == 0.0
    if (layoutWidth <= 0.0) {
        layoutWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    }
    
    self.cellsPerRow = calcCellsPerRow(layoutWidth);
    self.cellsPerPage = calcCellsPerPage(self.cellsPerRow);
    
    return ({
        CGFloat horMargin = calcHorMargin(layoutWidth, self.cellsPerRow);
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(verMargin, horMargin,
                                               verMargin, horMargin);
        // headerReferenceSize, footerReferenceSize
        layout.minimumLineSpacing = lineSpacing;
        layout.minimumInteritemSpacing = interitemSpacing;
        layout.itemSize = CGSizeMake(itemSize, itemSize);
        layout;
    });
}

#pragma mark - emoticons

- (void)setEmoticons:(nullable NSArray<BJLEmoticon *> *)emoticons {
    NSString *key = NSStringFromSelector(@selector(emoticons));
    [self willChangeValueForKey:key];
    self->_emoticons = emoticons;
    [self.collectionView reloadData];
    [self didChangeValueForKey:key];
    
    NSInteger currentPage = self.pageControl.currentPage;
    self.pageControl.numberOfPages = [self.collectionView numberOfSections];
    self.pageControl.currentPage = MIN(currentPage, self.pageControl.numberOfPages);
}

- (nullable BJLEmoticon *)emoticonAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger page = indexPath.section; // indexPath.item / self.cellsPerPage
    NSInteger indexInPage = indexPath.item; // indexPath.item % self.cellsPerPage
    
    NSInteger column = indexInPage / cellsPerColumn;
    NSInteger row = indexInPage % cellsPerColumn;
    
    NSInteger index = page * self.cellsPerPage + row * self.cellsPerRow + column;
    return [self.emoticons bjl_objectOrNilAtIndex:index];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return ceil((double)self.emoticons.count / self.cellsPerPage);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellsPerPage;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BJLEmoticon *emoticon = [self emoticonAtIndexPath:indexPath];
    
    BJLEmoticonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell updateWithEmoticon:emoticon];
    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    BJLEmoticon *emoticon = [self emoticonAtIndexPath:indexPath];
    if (emoticon && self.selectEmoticonCallback) self.selectEmoticonCallback(emoticon);
}

#pragma mark - <UIScrollViewDelegate>

- (void)bjl_scrollViewDidEndScrolling:(UIScrollView *)scrollView {
    self.pageControl.currentPage = round(scrollView.contentOffset.x
                                         / CGRectGetWidth(scrollView.bounds));
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self bjl_scrollViewDidEndScrolling:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self bjl_scrollViewDidEndScrolling:scrollView];
}

@end

NS_ASSUME_NONNULL_END
