//
//  GKVideoPlayer.h
//  GKDubbingDemo
//
//  Created by QuintGao on 2018/11/3.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GKVideoPlayerStatus) {
    GKVideoPlayerStatusUnload,              // 未加载
    GKVideoPlayerStatusPrepared,            // 准备播放
    GKVideoPlayerStatusLoading,             // 加载中
    GKVideoPlayerStatusPlaying,             // 播放中
    GKVideoPlayerStatusPaused,              // 暂停中
    GKVideoPlayerStatusEnded,               // 播放完成
    GKVideoPlayerStatusError                // 错误
};

@class GKVideoPlayer;

@protocol GKVideoPlayerDelegate<NSObject>

- (void)player:(GKVideoPlayer *)player statusChanged:(GKVideoPlayerStatus)status;

- (void)player:(GKVideoPlayer *)player currentTime:(float)currentTime totalTime:(float)totalTime progress:(float)progress;

@end

@interface GKVideoPlayer : NSObject

@property (nonatomic, weak) id<GKVideoPlayerDelegate> delegate;

@property (nonatomic, assign) GKVideoPlayerStatus status;

@property (nonatomic, assign) BOOL  isPlaying;

@property (nonatomic, assign) float currentTime;
@property (nonatomic, assign) float totalTime;

// 在指定视图上播放视频
- (void)playVideoWithView:(UIView *)playView url:(NSString *)url;

// 停止播放并移除播放视图
- (void)removeVideo;

// 暂停播放
- (void)pause;

// 恢复播放
- (void)resume;

// 重新播放
- (void)resetPlay;

// 设置静音播放
- (void)setMute:(BOOL)bEnable;

// seek
- (void)seekToTime:(float)time;

@end

NS_ASSUME_NONNULL_END
