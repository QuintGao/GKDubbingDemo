//
//  GKButton.m
//  GKDubbingDemo
//
//  Created by QuintGao on 2018/11/4.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKButton.h"

@implementation GKButton

- (instancetype)initWithLayoutStyle:(GKButtonLayoutStyle)layoutStyle titleToBottom:(BOOL)titleToBottom {
    if (self = [super init]) {
        self.layoutStyle = layoutStyle;
        self.titleToBottom = titleToBottom;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.midSpacing = 3.0f;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGSizeEqualToSize(CGSizeZero, self.imageSize)) {
        [self.imageView sizeToFit];
    }else {
        CGRect imageFrame = self.imageView.frame;
        imageFrame.size.width = self.imageSize.width;
        imageFrame.size.height = self.imageSize.height;
        self.imageView.frame = imageFrame;
    }
    
    [self.titleLabel sizeToFit];
    
    if (self.layoutStyle == GKButtonLayoutStyleLeftImageRightTitle) {
        [self layoutHorizontalWithLeftView:self.imageView rightView:self.titleLabel];
    }else if (self.layoutStyle == GKButtonLayoutStyleLeftTitleRightImage) {
        [self layoutHorizontalWithLeftView:self.titleLabel rightView:self.imageView];
    }else if (self.layoutStyle == GKButtonLayoutStyleUpImageDownTitle) {
        if (self.titleToBottom) {
            CGRect titleF = self.titleLabel.frame;
            CGRect imageF = self.imageView.frame;
            
            titleF.origin.y = CGRectGetHeight(self.frame) - CGRectGetHeight(titleF);
            titleF.origin.x = (CGRectGetWidth(self.frame) - CGRectGetWidth(titleF)) / 2;
            self.titleLabel.frame = titleF;
            
            imageF.origin.y = CGRectGetHeight(self.frame) - CGRectGetHeight(titleF) - self.midSpacing - CGRectGetHeight(imageF);
            imageF.origin.x = (CGRectGetWidth(self.frame) - CGRectGetWidth(imageF)) / 2;
            self.imageView.frame = imageF;
        }else {
            [self layoutVerticalWithUpView:self.imageView downView:self.titleLabel];
        }
    }else if (self.layoutStyle == GKButtonLayoutStyleUpTitleDownImage) {
        [self layoutVerticalWithUpView:self.titleLabel downView:self.imageView];
    }
}

- (void)layoutHorizontalWithLeftView:(UIView *)leftView rightView:(UIView *)rightView {
    CGRect leftViewFrame    = leftView.frame;
    CGRect rightViewFrame   = rightView.frame;
    
    CGFloat totalWidth = CGRectGetWidth(leftViewFrame) + self.midSpacing + CGRectGetWidth(rightViewFrame);
    leftViewFrame.origin.x = (CGRectGetWidth(self.frame) - totalWidth) / 2.0f;
    leftViewFrame.origin.y = (CGRectGetHeight(self.frame) - CGRectGetHeight(leftViewFrame)) / 2.0f;
    leftView.frame = leftViewFrame;
    
    rightViewFrame.origin.x = CGRectGetMaxX(leftViewFrame) + self.midSpacing;
    rightViewFrame.origin.y = (CGRectGetHeight(self.frame) - CGRectGetHeight(rightViewFrame)) / 2.0f;
    rightView.frame = rightViewFrame;
}

- (void)layoutVerticalWithUpView:(UIView *)upView downView:(UIView *)downView {
    CGRect upViewFrame      = upView.frame;
    CGRect downViewFrame    = downView.frame;
    
    CGFloat totalHeight = CGRectGetHeight(upViewFrame) + self.midSpacing + CGRectGetHeight(downViewFrame);
    
    upViewFrame.origin.y = (CGRectGetHeight(self.frame) - totalHeight) / 2.0;
    upViewFrame.origin.x = (CGRectGetWidth(self.frame) - CGRectGetWidth(upViewFrame)) / 2.0;
    upView.frame = upViewFrame;
    
    downViewFrame.origin.y = CGRectGetMaxY(upViewFrame) + self.midSpacing;
    downViewFrame.origin.x = (CGRectGetWidth(self.frame) - CGRectGetWidth(downViewFrame)) / 2.0;
    downView.frame = downViewFrame;
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    [super setImage:image forState:state];
    [self setNeedsLayout];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    [self setNeedsLayout];
}

- (void)setMidSpacing:(CGFloat)midSpacing {
    _midSpacing = midSpacing;
    [self setNeedsLayout];
}

- (void)setImageSize:(CGSize)imageSize {
    _imageSize = imageSize;
    [self setNeedsLayout];
}

@end
