//
//  GKDubbingRecordViewController.m
//  GKAudioRecorderDemo
//
//  Created by QuintGao on 2018/11/3.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDubbingRecordViewController.h"
#import <GKAudioRecorder/GKAudioRecorder.h>
#import "GKVideoPlayer.h"
#import "GKButton.h"
#import "GKSliderView.h"
#import "GKDubbingManager.h"
#import <Masonry/Masonry.h>
#import <GKMessageTool/GKMessageTool.h>
#import "GKDubbingEditViewController.h"

@interface GKDubbingRecordViewController ()<GKVideoPlayerDelegate>

@property (nonatomic, strong) UILabel   *titleView;
@property (nonatomic, strong) UIButton  *finishBtn;

@property (nonatomic, strong) GKVideoPlayer *player;
@property (nonatomic, strong) UIImageView   *playView;
@property (nonatomic, strong) GKButton      *playBtn;
@property (nonatomic, strong) GKSliderView  *sliderView;

@property (nonatomic, strong) UIButton      *recordBtn;                 // 录音按钮
@property (nonatomic, strong) UIButton      *resetRecordBtn;            // 重新录制按钮
@property (nonatomic, strong) UIButton      *auditionRecordBtn;         // 录音试听按钮

@property (nonatomic, assign) BOOL          isPreviewVideo;             // 是否正在预览视频
@property (nonatomic, assign) BOOL          isRecording;                // 是否正在录音
@property (nonatomic, assign) BOOL          isAudition;                 // 是否正在试听

@property (nonatomic, assign) float         recordTime;

@property (nonatomic, copy) NSString        *videoPath;
@property (nonatomic, copy) NSString        *bgmPath;

@end

@implementation GKDubbingRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[GKAudioRecorder sharedInstance] registerRecorder];
    
    self.gk_navRightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.finishBtn];
    self.gk_navTitleView = self.titleView;
    
    [self.view addSubview:self.playView];
    [self.view addSubview:self.playBtn];
    [self.view addSubview:self.sliderView];
    [self.view addSubview:self.recordBtn];
    [self.view addSubview:self.resetRecordBtn];
    [self.view addSubview:self.auditionRecordBtn];
    
    [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.gk_navigationBar.mas_bottom);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(200.0f);
        make.height.mas_equalTo(200.0f * 16 / 9);
    }];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.playView);
    }];
    
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.playView.mas_bottom).offset(15.0f);
        make.height.mas_equalTo(4.0f);
    }];
    
    [self.recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.sliderView.mas_bottom).offset(40.0f);
        make.width.height.mas_equalTo(110.0f);
    }];
    
    [self.resetRecordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.recordBtn);
        make.right.equalTo(self.recordBtn.mas_left).offset(-20.0f);
        make.width.mas_equalTo(100.0f);
        make.height.mas_equalTo(40.0f);
    }];
    
    [self.auditionRecordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.recordBtn);
        make.left.equalTo(self.recordBtn.mas_right).offset(20.0f);
        make.width.mas_equalTo(100.0f);
        make.height.mas_equalTo(40.0f);
    }];
    
    self.videoPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
    self.bgmPath   = [[NSBundle mainBundle] pathForResource:@"bgm" ofType:@"m4a"];
}

#pragma mark - GKVideoPlayerDelegate
- (void)player:(GKVideoPlayer *)player statusChanged:(GKVideoPlayerStatus)status {
    if (status == GKVideoPlayerStatusEnded) {
        if (self.isRecording) {
            [self finishAction:nil];
        }
        
        if (self.isPreviewVideo) {
            [self.player seekToTime:self.recordTime];
            self.sliderView.value = self.recordTime / self.player.totalTime;
        }
    }
}

- (void)player:(GKVideoPlayer *)player currentTime:(float)currentTime totalTime:(float)totalTime progress:(float)progress {
    self.sliderView.value = progress;
    
    NSString *currentTimeStr = [self timeFormattedMS:currentTime];
    NSString *totalTimeStr   = [self timeFormattedMS:totalTime];
    
    self.titleView.text = [NSString stringWithFormat:@"%@/%@", currentTimeStr, totalTimeStr];
    
    if (currentTime >= 10.0 && self.isRecording) {
        self.finishBtn.hidden = NO;
    }
}

#pragma mark - User Actions
- (void)finishAction:(id)sender {
    [GKMessageTool showMessage:@"录音合成中..."];
    
    [[GKAudioRecorder sharedInstance] pauseRecord];
    [[GKAudioRecorder sharedInstance] stopPlayAudio];
    [self.player pause];
    
    [[GKAudioRecorder sharedInstance] finishRecordWithPath:kDubbingRecordPath progress:^(float progress) {
        NSLog(@"录音合成进度：%f", progress);
    } success:^{
        NSLog(@"录音合成成功");
        dispatch_async(dispatch_get_main_queue(), ^{
            [GKMessageTool hideMessage];
            GKDubbingEditViewController *editVC = [GKDubbingEditViewController new];
            editVC.videoPath = self.videoPath;
            [self.navigationController pushViewController:editVC animated:YES];
        });
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"录音合成失败：%@", error);
    }];
}

- (void)playAction:(id)sender {
    if (self.isRecording) return;
    if (self.isAudition) return;
    
    if (self.player.isPlaying) {
        [self.player seekToTime:self.recordTime];
        [self.player pause];
        
        self.playBtn.hidden = NO;
        self.sliderView.value = self.recordTime / self.player.totalTime;
    }else {
        [self.player setMute:NO];
        if (self.player.status == GKVideoPlayerStatusUnload) {
            [self.player playVideoWithView:self.playView url:self.videoPath];
        }else {
            [self.player resume];
        }
        self.playBtn.hidden = YES;
    }
}

- (void)recordAction:(id)sender {
    self.recordBtn.selected = !self.recordBtn.selected;
    
    // 如果正在预览视频
    if (self.isPreviewVideo) {
        [self playAction:nil];
    }
    
    // 如果正在试听，先结束试听
    if (self.isAudition) {
        [self auditionRecordAction:nil];
    }
    
    if (self.recordBtn.selected) {  // 开始录制
        self.isRecording = YES;
        
        // 开始录制背景音乐
        [[GKAudioRecorder sharedInstance] startPlayAudioWithPath:self.bgmPath time:0 finished:^{}];
        [[GKAudioRecorder sharedInstance] openBGMRecord];
        
        [[GKAudioRecorder sharedInstance] startRecordWithSuccess:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                // 静音播放视频
                [self playVideoMuted:NO];
            });
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"开始录制失败：%@", error);
        }];
        
        self.resetRecordBtn.hidden      = YES;
        self.auditionRecordBtn.hidden   = YES;
    }else { // 暂停录制
        self.isRecording = NO;
        
        [[GKAudioRecorder sharedInstance] pauseRecord];
        [[GKAudioRecorder sharedInstance] pausePlayAudio];
        
        // 暂停视频播放并记录录音时间
        [self.player pause];
        self.recordTime = self.player.currentTime;
        
        // 显示视图按钮
        self.resetRecordBtn.hidden      = NO;
        self.auditionRecordBtn.hidden   = NO;
        self.playBtn.hidden             = NO;
    }
}

- (void)resetRecordAction:(id)sender {
    [[GKAudioRecorder sharedInstance] resetRecord];
    
    self.recordTime = 0;
    [self.player seekToTime:0];
    self.sliderView.value = 0;
}

- (void)auditionRecordAction:(id)sender {
    self.auditionRecordBtn.selected = !self.auditionRecordBtn.selected;
    
    if (self.auditionRecordBtn.selected) { // 开始试听
        self.isAudition = YES;
        
        // 如果正在预览视频
        if (self.isPreviewVideo) {
            [self playAction:nil];
        }
        
        __weak typeof(self) weakSelf = self;
    
        [[GKAudioRecorder sharedInstance] startRecordAuditionWithFinished:^{
            // 试听结束后，停止试听
            [weakSelf auditionRecordAction:nil];
        }];
        
        // 同时播放静音播放视频
        [self playVideoMuted:YES];
    }else { // 暂停视图
        self.isAudition = NO;
        [[GKAudioRecorder sharedInstance] stopRecordAudition];
        
        [self.player pause];
        [self.player seekToTime:self.recordTime];
        self.sliderView.value = self.recordTime / self.player.totalTime;
        self.playBtn.hidden = NO;
    }
}

#pragma mark - Private Methods
// 秒数转换成 分钟:秒数
- (NSString *)timeFormattedMS:(int)totalSeconds {
    int hours = totalSeconds / 3600;
    int minutes = (totalSeconds % 3600) / 60;
    int seconds = (totalSeconds % 3600) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d",hours * 60 + minutes, seconds];
}

- (void)playVideoMuted:(BOOL)isAudition {
    if (self.isAudition) {
        [self.player seekToTime:0];
    }
    
    [self.player setMute:YES];
    self.playBtn.hidden = YES;
    
    if (self.player.status == GKVideoPlayerStatusUnload) {
        [self.player playVideoWithView:self.playView url:self.videoPath];
    }else {
        [self.player resume];
    }
}

#pragma mark - Getter
- (UILabel *)titleView {
    if (!_titleView) {
        _titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        _titleView.textColor = [UIColor blackColor];
        _titleView.font = [UIFont systemFontOfSize:16.0f];
    }
    return _titleView;
}

- (UIButton *)finishBtn {
    if (!_finishBtn) {
        _finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        [_finishBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_finishBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _finishBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_finishBtn addTarget:self action:@selector(finishAction:) forControlEvents:UIControlEventTouchUpInside];
        _finishBtn.hidden = YES;
    }
    return _finishBtn;
}

- (GKVideoPlayer *)player {
    if (!_player) {
        _player = [GKVideoPlayer new];
        _player.delegate = self;
    }
    return _player;
}

- (UIImageView *)playView {
    if (!_playView) {
        _playView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"test"]];
        _playView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playAction:)];
        [_playView addGestureRecognizer:tap];
    }
    return _playView;
}

- (GKButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[GKButton alloc] initWithLayoutStyle:GKButtonLayoutStyleUpImageDownTitle titleToBottom:NO];
        [_playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_playBtn setTitle:@"预览原声" forState:UIControlStateNormal];
        [_playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _playBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _playBtn.midSpacing = 15.0f;
        _playBtn.userInteractionEnabled = NO;
    }
    return _playBtn;
}

- (GKSliderView *)sliderView {
    if (!_sliderView) {
        _sliderView = [GKSliderView new];
        _sliderView.maximumTrackTintColor = [UIColor whiteColor];
        _sliderView.minimumTrackTintColor = [UIColor purpleColor];
        _sliderView.sliderHeight = 4.0f;
    }
    return _sliderView;
}

- (UIButton *)recordBtn {
    if (!_recordBtn) {
        _recordBtn = [UIButton new];
        _recordBtn.backgroundColor = [UIColor whiteColor];
        [_recordBtn setTitle:@"录制" forState:UIControlStateNormal];
        [_recordBtn setTitle:@"暂停" forState:UIControlStateSelected];
        [_recordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _recordBtn.layer.cornerRadius = 55.0f;
        _recordBtn.layer.masksToBounds = YES;
        [_recordBtn addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordBtn;
}

- (UIButton *)resetRecordBtn {
    if (!_resetRecordBtn) {
        _resetRecordBtn = [UIButton new];
        [_resetRecordBtn setTitle:@"重新录制" forState:UIControlStateNormal];
        _resetRecordBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        [_resetRecordBtn addTarget:self action:@selector(resetRecordAction:) forControlEvents:UIControlEventTouchUpInside];
        _resetRecordBtn.backgroundColor = [UIColor blueColor];
        _resetRecordBtn.hidden = YES;
    }
    return _resetRecordBtn;
}

- (UIButton *)auditionRecordBtn {
    if (!_auditionRecordBtn) {
        _auditionRecordBtn = [UIButton new];
        [_auditionRecordBtn setTitle:@"开始试听" forState:UIControlStateNormal];
        [_auditionRecordBtn setTitle:@"停止试听" forState:UIControlStateSelected];
        _auditionRecordBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        [_auditionRecordBtn addTarget:self action:@selector(auditionRecordAction:) forControlEvents:UIControlEventTouchUpInside];
        _auditionRecordBtn.backgroundColor = [UIColor blueColor];
        _auditionRecordBtn.hidden = YES;
    }
    return _auditionRecordBtn;
}

@end
