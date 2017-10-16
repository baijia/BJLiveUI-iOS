//
//  BJLPPTQuickSlideViewController.m
//  Pods
//
//  Created by HuangJie on 2017/7/5.
//  Copyright © 2017年 BaijiaYun. All rights reserved.
//

#import "BJLPPTQuickSlideViewController.h"
#import "BJLOverlayViewController.h"
#import "BJLPPTQuickSlideCell.h"
#import <BJLiveCore/BJLRoom.h>

static const CGSize pptSize = {.width = 80.0, .height = 60.0};
static NSString * const cellReuseIdentifier = @"slidePageCell";

@interface BJLPPTQuickSlideViewController ()

@property (nonatomic, strong) BJLRoom *room;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<BJLSlidePage *> *slidePages;
@property (nonatomic, assign) NSInteger maxDocumentPageCount;

@end

@implementation BJLPPTQuickSlideViewController

- (instancetype)initWithRoom:(BJLRoom *)room {
    self = [super init];
    if (self) {
        self.room = room;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.layer.borderWidth = BJLOnePixel;
    self.view.layer.borderColor = [UIColor bjl_grayBorderColor].CGColor;
    
    [self setupCollectionView];
    [self makeObserving];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollToIndex:self.room.slideshowViewController.localPageIndex];
}

#pragma mark - observing

- (void)makeObserving {
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.room.slideshowVM, allDocuments)
         observer:^BOOL(id _Nullable old, NSArray<BJLDocument *> * _Nullable now) {
             bjl_strongify(self);
             self.slidePages = [self.room.slideshowVM slidePagesWithFillSize:pptSize];
             [self.collectionView reloadData];
             return YES;
         }];
    
    [self bjl_kvo:BJLMakeProperty(self.room.slideshowVM, currentSlidePage)
         observer:^BOOL(id _Nullable old, id _Nullable now) {
             bjl_strongify(self);
             BJLSlidePage *currentSlidePage = [now bjl_as:[BJLSlidePage class]];
             if (!currentSlidePage) {
                 // currentSlidepage 空值处理，手动定位到白板页
                 self.maxDocumentPageCount = 1;
                 return YES;
             }
             // 设置最大翻页数
             self.maxDocumentPageCount = currentSlidePage.documentPageIndex+1;
             [self.collectionView reloadData];
             return YES;
         }];
    
    [self bjl_kvo:BJLMakeProperty(self.room.slideshowViewController, localPageIndex)
         observer:^BOOL(id  _Nullable old, id  _Nullable now) {
             NSInteger localIndex = [now integerValue];
             [self scrollToIndex:localIndex];
             [self.collectionView reloadData];
             return YES;
         }];
}

#pragma mark - slidePages

- (NSArray<BJLSlidePage *> *)slidePages {
    if (!_slidePages) {
        _slidePages = [self.room.slideshowVM slidePagesWithFillSize:pptSize];
    }
    return _slidePages;
}

#pragma mark - UICollectionView

- (void)setupCollectionView {
    self.collectionView = ({
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = BJLViewSpaceM;
        layout.minimumLineSpacing = BJLViewSpaceS;
        layout.itemSize = pptSize;
        layout.sectionInset = UIEdgeInsetsMake(BJLViewSpaceL, BJLViewSpaceL, BJLViewSpaceL, BJLViewSpaceL);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.bounces = YES;
        collectionView.alwaysBounceHorizontal = YES;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        [collectionView registerClass:[BJLPPTQuickSlideCell class] forCellWithReuseIdentifier:cellReuseIdentifier];
        collectionView;
    });
    
    // constraint
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
        make.height.greaterThanOrEqualTo(@(pptSize.height + BJLViewSpaceM * 2)).priorityHigh();
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.room.loginUser.isTeacher
        || self.room.loginUser.isAssistant
        || self.room.slideshowViewController.studentCanPreviewForward) {
        return self.slidePages.count;
    }
    else {
        return MIN(self.maxDocumentPageCount, self.slidePages.count);
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BJLPPTQuickSlideCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    BJLSlidePage *slidePage = [self.slidePages bjl_objectOrNilAtIndex:indexPath.row];
    [cell updateContentWithSlidePage:slidePage];
    cell.selected = (indexPath.row == self.room.slideshowViewController.localPageIndex);
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.room.slideshowViewController setLocalPageIndex:indexPath.row];
    [collectionView reloadData];
    if (self.selectPPTCallback) {
        self.selectPPTCallback();
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return pptSize;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - scroll

- (void)scrollToIndex:(NSInteger)index {
    if (index < 0 || index >= [self.collectionView numberOfItemsInSection:0]) {
        return;
    }
    // 滑动当前页到中间
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
}

@end
