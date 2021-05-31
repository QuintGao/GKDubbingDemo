//
//  GKButton.h
//  GKDubbingDemo
//
//  Created by QuintGao on 2018/11/4.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GKButtonLayoutStyle) {
    GKButtonLayoutStyleLeftImageRightTitle  = 0,    // 左图片，右标题
    GKButtonLayoutStyleLeftTitleRightImage  = 1,    // 左标题，右图片
    GKButtonLayoutStyleUpImageDownTitle     = 2,    // 上图片，下标题
    GKButtonLayoutStyleUpTitleDownImage     = 3     // 上标题，下图片
};

@interface GKButton : UIButton

- (instancetype)initWithLayoutStyle:(GKButtonLayoutStyle)layoutStyle titleToBottom:(BOOL)titleToBottom;

// 布局方式
@property (nonatomic, assign) GKButtonLayoutStyle   layoutStyle;

// 图片与文件最小间距，默认是3
@property (nonatomic, assign) CGFloat   midSpacing;

// 图片大小
@property (nonatomic, assign) CGSize    imageSize;

// 布局方式为GKButtonLayoutStyleUpImageDownTitle时有效
@property (nonatomic, assign) BOOL      titleToBottom;

@end

NS_ASSUME_NONNULL_END
