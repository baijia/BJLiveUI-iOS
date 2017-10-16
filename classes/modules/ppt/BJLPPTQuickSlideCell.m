//
//  BJLPPTQuickSlideCell.m
//  Pods
//
//  Created by HuangJie on 2017/7/6.
//  Copyright © 2017年 BaijiaYun. All rights reserved.
//

#import "BJLPPTQuickSlideCell.h"

#import "BJLViewImports.h"

static const CGSize labelSize = {16.0, 16.0};

@interface BJLPPTQuickSlideCell ()

@property (nonatomic, strong) UIImageView *pptView;
@property (nonatomic, strong) UILabel *numberLabel;

@end

@implementation BJLPPTQuickSlideCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupContentView];
    }
    return self;
}

#pragma mark - setup contentView

- (void)setupContentView {
    self.selectedBackgroundView.backgroundColor = [UIColor bjl_blueBrandColor];
    
    // pptView
    self.pptView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        imageView;
    });
    [self.contentView addSubview:self.pptView];
    [self.pptView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    // numberLabel
    self.numberLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor bjl_lightDimColor];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    [self.contentView addSubview:self.numberLabel];
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(self.contentView);
        make.width.greaterThanOrEqualTo(@(labelSize.width));
        make.width.lessThanOrEqualTo(self.contentView.mas_width);
        make.height.equalTo(@(labelSize.height));
    }];
}

#pragma mark - update content

- (void)updateContentWithSlidePage:(BJLSlidePage *)slidePage {
    // ppt
    [self.pptView bjl_setImageWithURL:[NSURL URLWithString:slidePage.pageURLString]
                          placeholder:[UIImage bjl_imageWithColor:[UIColor bjl_grayImagePlaceholderColor]]
                           completion:nil];
    
    // number
    NSString *numberText;
    if (slidePage.documentPageIndex == 1) {
        numberText = @"白板";
    }
    else {
        numberText = [NSString stringWithFormat:@"%td", slidePage.documentPageIndex - 1];
    }
    self.numberLabel.text = numberText;
}

#pragma mark - overwrite

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.layer.borderWidth = selected ? 2.0 : BJLOnePixel;
    self.layer.borderColor = selected ? [[UIColor bjl_blueBrandColor] CGColor] : [[UIColor bjl_grayLineColor] CGColor];
}

@end
