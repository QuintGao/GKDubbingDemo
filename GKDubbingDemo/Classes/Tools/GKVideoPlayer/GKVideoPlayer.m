//
//  GKVideoPlayer.m
//  GKDubbingDemo
//
//  Created by QuintGao on 2018/11/3.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKVideoPlayer.h"
#import <TXLiteAVSDK_Player/TXLiveBase.h>
#import <TXLiteAVSDK_Player/TXVodPlayer.h>
#import <TXLiteAVSDK_Player/TXVodPlayListener.h>

@interface GKVideoPlayer()<TXVodPlayListener>

@property (nonatomic, strong) TXVodPlayer   *player;

@end

@implementation GKVideoPlayer

#pragma mark - Public Methods
- (void)playVideoWithView:(UIView *)playView url:(NSString *)url {
    // 设置播放视图
    [self.player setupVideoWidget:playView insertIndex:0];
    
    // 准备播放，这里可处理暂停音频的播放
    [self playerStatusChanged:GKVideoPlayerStatusPrepared];
    
    // 开始播放
    [self.player startPlay:url];
}

- (void)removeVideo {
    [self.player stopPlay];
    [self.player removeVideoWidget];
    [self playerStatusChanged:GKVideoPlayerStatusUnload];
}

- (void)pause {
    if (self.status == GKVideoPlayerStatusUnload) return;
    
    [self playerStatusChanged:GKVideoPlayerStatusPaused];
    
    [self.player pause];
}

- (void)resume {
    if (self.status == GKVideoPlayerStatusUnload) return;
    
    if (self.status == GKVideoPlayerStatusPaused) {
        [self.player resume];
        [self playerStatusChanged:GKVideoPlayerStatusPlaying];
    }
}

- (void)resetPlay {
    [self.player resume];
}

- (void)setMute:(BOOL)bEnable {
    [self.player setMute:bEnable];
}

- (void)seekToTime:(float)time {
    [self.player seek:time];
}

- (void)playerStatusChanged:(GKVideoPlayerStatus)status {
    self.status = status;
    
    if ([self.delegate respondsToSelector:@selector(player:statusChanged:)]) {
        [self.delegate player:self statusChanged:status];
    }
}

- (BOOL)isPlaying {
    return self.player.isPlaying;
}

#pragma mark - TXVodPlayListener
- (void)onPlayEvent:(TXVodPlayer *)player event:(int)EvtID withParam:(NSDictionary *)param {
    switch (EvtID) {
        case PLAY_EVT_PLAY_LOADING: {   // loading
            if (self.status == GKVideoPlayerStatusPaused) {
                [self playerStatusChanged:GKVideoPlayerStatusPaused];
            }else {
                [self playerStatusChanged:GKVideoPlayerStatusLoading];
            }
        }
            break;
        case PLAY_EVT_PLAY_BEGIN: {     // 开始播放
            [self playerStatusChanged:GKVideoPlayerStatusPlaying];
        }
            break;
        case PLAY_EVT_PLAY_END: {   // 播放结束
            [self playerStatusChanged:GKVideoPlayerStatusEnded];
        }
            break;
        case PLAY_EVT_VOD_PLAY_PREPARED: {   // 视频加载完毕
            
        }
            break;
        case PLAY_EVT_VOD_LOADING_END: {   // loading结束
            //            NSLog(@"加载结束");
        }
            break;
        case PLAY_ERR_NET_DISCONNECT: {   // 失败，多次重连无效
            [self playerStatusChanged:GKVideoPlayerStatusError];
        }
            break;
        case PLAY_EVT_PLAY_PROGRESS: {   // 进度更新
            if (self.status == GKVideoPlayerStatusPlaying) {
                self.totalTime = [param[EVT_PLAY_DURATION] floatValue];
//                self.duration = self.totalTime;
                
                self.currentTime = [param[EVT_PLAY_PROGRESS] floatValue];
                
                //                float buffTime = [param[EVT_PLAYABLE_DURATION] floatValue];
                
                float progress = self.totalTime == 0 ? 0 : self.currentTime / self.totalTime;
                //                float buffProgress = duration == 0 ? 0 : buffTime / duration;
                if (progress >= 0.95) {
                    progress = 1.0f;
                }
                
                if (self.totalTime > 0) {
                    if ([self.delegate respondsToSelector:@selector(player:currentTime:totalTime:progress:)]) {
                        [self.delegate player:self currentTime:self.currentTime totalTime:self.totalTime progress:progress];
                    }
                }
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)onNetStatus:(TXVodPlayer *)player withParam:(NSDictionary *)param {
    
}

#pragma mark - 懒加载
- (TXVodPlayer *)player {
    if (!_player) {
        [TXLiveBase setLogLevel:LOGLEVEL_NULL];
        [TXLiveBase setConsoleEnabled:NO];
        
        _player = [TXVodPlayer new];
        _player.vodDelegate = self;
        //        _player.loop = YES; // 开启循环播放
    }
    return _player;
}

@end
