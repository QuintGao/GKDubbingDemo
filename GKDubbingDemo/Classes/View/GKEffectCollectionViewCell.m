//
//  GKEffectCollectionViewCell.m
//  GKDubbingDemo
//
//  Created by QuintGao on 2018/11/4.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKEffectCollectionViewCell.h"
#import <Masonry/Masonry.h>

@interface GKEffectCollectionViewCell()

@property (nonatomic, strong) UIImageView   *iconView;
@property (nonatomic, strong) UILabel       *nameLabel;

@end

@implementation GKEffectCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.nameLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    [_iconView setFrame:CGRectMake((self.frame.size.width - screenWidth / 750 * 100.0f) / 2,
                                 (self.frame.size.height - screenWidth / 750 * 100.0f) / 2,
                                 screenWidth / 750 * 100.0f,
                                 screenWidth / 750 * 100.0f)];
    
    [_nameLabel setFrame:CGRectMake(0,
                                     (self.frame.size.height - screenWidth / 750 * 100.0f) / 2 + screenWidth / 750 * 100.0f,
                                     self.frame.size.width,
                                     (self.frame.size.height - screenWidth / 750 * 100.0f) / 2)];
}

- (void)setEffect:(GKDubbingEffect *)effect {
    _effect = effect;
    
    self.iconView.image = [UIImage imageNamed:effect.effect_img_name];
    
    self.nameLabel.text = effect.effect_name;
}

#pragma mark - 懒加载
- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [UIImageView new];
    }
    return _iconView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont systemFontOfSize:13.0f];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

@end
