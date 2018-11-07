//
//  GKAudioRecorder.h
//  GKAudioRecorderDemo
//
//  Created by QuintGao on 2018/11/3.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GKAudioEffect;

@interface GKAudioRecorder : NSObject

/**
 录音单例

 @return 录音实例对象
 */
+ (instancetype)sharedInstance;


/**
 注册录音器
 */
- (void)registerRecorder;

/**
 注销录音器
 */
- (void)unregisterRecorder;

#pragma mark - 录音
/**
 开始录音（仅录制手机外界声音如：人声）

 @param success 开始成功
 @param failure 开始失败
 */
- (void)startRecordWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

/**
 暂停录制
 */
- (void)pauseRecord;

/**
 重新录制
 */
- (void)resetRecord;

/**
 完成录制

 @param path 录音文件存储路径
 @param progress 完成进度回调
 @param success 成功回调
 @param failure 失败回调
 */
- (void)finishRecordWithPath:(NSString *)path
                    progress:(void (^)(float progress))progress
                     success:(void (^)(void))success
                     failure:(void (^)(NSError *error))failure;

/**
 开启背景音乐录制(手机内声音，需播放)
 */
- (void)openBGMRecord;

/**
 关闭背景音乐录制
 */
- (void)closeBGMRecord;

#pragma mark - 播放（仅支持本地音频播放）
#pragma mark - 录音试听
/**
 播放录音文件

 @param finished 播放完成回调
 */
- (void)startRecordAuditionWithFinished:(void (^)(void))finished;

/**
 停止录音试听
 */
- (void)stopRecordAudition;

#pragma mark - 播放音效

/**
 播放音效（短音频，无暂停，停止方法）

 @param path 音效地址
 */
- (void)startPlayEffectWithPath:(NSString *)path;

#pragma mark - 播放音频
/**
 开始音频播放，可指定开始播放时间

 @param path 音频地址
 @param time 播放时间（默认0）
 @param finished 播放完成回调
 */
- (void)startPlayAudioWithPath:(NSString *)path time:(float)time finished:(void (^)(void))finished;

/**
 暂停音频播放
 */
- (void)pausePlayAudio;

/**
 停止音频播放
 */
- (void)stopPlayAudio;

#pragma mark - 音视频合成
/**
 在指定音频中插入音效

 @param audioPath 音频地址
 @param effect 音效数据模型
 @param success 插入成功回调
 @param failure 插入失败回调
 */
- (void)insertEffectWithAudioPath:(NSString *)audioPath
                           effect:(GKAudioEffect *)effect
                          success:(void (^)(AVCompositionTrack *track))success
                          failure:(void (^)(NSError *error))failure;


/**
 在指定音频中删除音效

 @param audioPath 音频地址
 @param effect 音效数据模型（effect_track必须传入）
 @param success 删除成功回调
 @param failure 删除失败回调
 */
- (void)deleteEffectWithAudioPath:(NSString *)audioPath
                           effect:(GKAudioEffect *)effect
                          success:(void (^)(void))success
                          failure:(void (^)(NSError *error))failure;


/**
 音频合成（音频+音频，从0开始混合）

 @param audioPathArr 音频地址数组
 @param exportAudioPath 导出的音频地址
 @param progress 导出进度回调
 @param success 导出成功回调
 @param failure 导出失败回调
 */
- (void)compositionAudioWithAudioPathArr:(NSArray *)audioPathArr
                         exportAudioPath:(NSString *)exportAudioPath
                                progress:(void (^)(float progress))progress
                                 success:(void (^)(void))success
                                 failure:(void (^)(NSError *error))failure;

/**
 音频拼接（音频+音频）

 @param audioPathArr 音频地址数组
 @param exportAudioPath 导出的音频地址
 @param progress 导出进度回调
 @param success 导出成功回调
 @param failure 导出失败回调
 */
- (void)splicingAudioWithAudioPathArr:(NSArray *)audioPathArr
                      exportAudioPath:(NSString *)exportAudioPath
                             progress:(void (^)(float progress))progress
                              success:(void (^)(void))success
                              failure:(void (^)(NSError *error))failure;

/**
 视频合成（音频+视频）

 @param videoPath 视频地址
 @param audioPath 音频地址
 @param exportVideoPath 导出的视频地址
 @param progress 合成进度回调
 @param success 合成成功回调
 @param failure 合成视频回调
 */
- (void)compositionVideoWithVideoPath:(NSString *)videoPath
                            audioPath:(NSString *)audioPath
                      exportVideoPath:(NSString *)exportVideoPath
                             progress:(void (^)(float progress))progress
                              success:(void (^)(void))success
                              failure:(void (^)(NSError *error))failure;

@end

@interface GKAudioEffect : NSObject

// 音频本地路径
@property (nonatomic, copy) NSString                *effect_path;
// 音效插入时间
@property (nonatomic, assign) float                 effect_time;
// 音效合成轨迹（删除音效时必须传入）
@property (nonatomic, strong) AVCompositionTrack    *effect_track;

@end

NS_ASSUME_NONNULL_END
