//
//  GKDubbingManager.h
//  GKDubbingDemo
//
//  Created by QuintGao on 2018/11/3.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 沙盒路径
#define kDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

// 录音文件路径
#define kDubbingPath [kDocumentPath stringByAppendingPathComponent:@"dubbing"]
#define kDubbingRecordPath [kDubbingPath stringByAppendingPathComponent:@"dubbing_record.m4a"]
#define kDubbingVideoPath  [kDubbingPath stringByAppendingPathComponent:@"dubbing_video.mp4"]

@interface GKDubbingManager : NSObject

+ (void)createDubbingPath;

@end

@interface GKDubbingEffect : NSObject

@property (nonatomic, copy) NSString    *effect_name;
@property (nonatomic, copy) NSString    *effect_img_name;
@property (nonatomic, copy) NSString    *effect_path;

@end

NS_ASSUME_NONNULL_END
