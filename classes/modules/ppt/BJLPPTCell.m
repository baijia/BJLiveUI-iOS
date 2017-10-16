//
//  BJLPPTCell.m
//  BJLiveUI
//
//  Created by MingLQ on 2017-03-18.
//  Copyright © 2017 BaijiaYun. All rights reserved.
//

#import "BJLPPTCell.h"

#import "BJLViewImports.h"

#import "ICLProgressView.h"

NS_ASSUME_NONNULL_BEGIN

NSString * const BJLPPTCellIdentifier_uploading = @"uploading", * const BJLPPTCellIdentifier_document = @"document";

static const CGFloat iconSize = 24.0;

@interface BJLPPTCell ()

@property (nonatomic) UIImageView *iconView;
@property (nonatomic) UILabel *nameLabel, *stateLabel;
@property (nonatomic) UIView *progressView;

@end

@implementation BJLPPTCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self makeSubviews];
        [self makeConstraints];
        
        [self prepareForReuse];
    }
    return self;
}

- (void)makeSubviews {
    self.iconView = ({
        UIImageView *imageView = [UIImageView new];
        imageView.backgroundColor = [UIColor bjl_grayImagePlaceholderColor];
        imageView.layer.cornerRadius = BJLButtonCornerRadius;
        imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:imageView];
        imageView;
    });
    
    self.nameLabel = ({
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor bjl_darkGrayTextColor];
        label.font = [UIFont systemFontOfSize:15.0];
        [self.contentView addSubview:label];
        label;
    });
    
    self.stateLabel = ({
        UILabel *label = [UILabel new];
        label.textAlignment = NSTextAlignmentRight;
        label.textColor = [UIColor bjl_lightGrayTextColor];
        label.font = [UIFont systemFontOfSize:13.0];
        [self.contentView addSubview:label];
        label;
    }); 
    
    self.progressView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor bjl_lightGrayBackgroundColor];
        [self.contentView insertSubview:view atIndex:0];
        view;
    });
}

- (void)makeConstraints {
    [self.stateLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.stateLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(BJLViewSpaceL);
        make.centerY.equalTo(self.contentView);
        make.width.height.equalTo(@(iconSize));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconView.mas_right).with.offset(BJLViewSpaceM);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.nameLabel.mas_right).with.offset(BJLViewSpaceM);
        make.right.equalTo(self.contentView).with.offset(- BJLViewSpaceM);
        make.centerY.equalTo(self.contentView);
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.iconView.image = nil;
    self.nameLabel.text = nil;
    
    self.stateLabel.hidden = YES;
    self.stateLabel.text = nil;
    
    self.progressView.hidden = YES;
}

- (void)updateWithUploadingTask:(BJLPPTUploadingTask *)uploadingTask {
    self.iconView.image = [self iconWithImageFile:uploadingTask.imageFile];
    self.nameLabel.text = uploadingTask.imageFile.fileName;
    
    self.stateLabel.hidden = NO;
    self.stateLabel.text = ({
        NSString *stateText = nil;
        switch (uploadingTask.state) {
            case BJLUploadState_waiting:
                stateText = uploadingTask.error ? @"上传失败" : @"等待上传";
                break;
            case BJLUploadState_uploading:
                stateText = @"上传中";
                break;
            case BJLUploadState_uploaded:
                stateText = @"等待添加";
                break;
            default:
                break;
        }
        stateText;
    });
    
    self.progressView.hidden = NO;
    [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self.contentView);
        // left 0.1 for adding state
        make.width.equalTo(self.contentView).multipliedBy(1.0 - uploadingTask.progress * 0.95);
    }];
}

- (void)updateWithDocument:(BJLDocument *)document {
    self.iconView.image = [self iconWithDocument:document];
    self.nameLabel.text = document.fileName;
    self.stateLabel.text = nil;
    self.stateLabel.hidden = YES;
    self.progressView.hidden = YES;
}

- (UIImage *)iconWithImageFile:(ICLImageFile *)imageFile {
    return [UIImage imageNamed:@"bjl_ic_file_jpg"]; // thumbnail
}

- (UIImage *)iconWithDocument:(BJLDocument *)document {
    NSString *imageName = nil;
    if (document.pageInfo.isAlbum) {
        NSString *fileExtension = (document.fileExtension.length
                                   ? [document.fileExtension lowercaseString]
                                   : [document.fileName.pathExtension lowercaseString]);
        if ([fileExtension isEqualToString:@"pdf"]) {
            imageName = @"bjl_ic_file_PDF";
        }
        else if ([fileExtension isEqualToString:@"ppt"]) {
            imageName = @"bjl_ic_file_PPT";
        }
    }
    return [UIImage imageNamed:imageName ?: @"bjl_ic_file_jpg"]; // thumbnail
}

@end

NS_ASSUME_NONNULL_END
