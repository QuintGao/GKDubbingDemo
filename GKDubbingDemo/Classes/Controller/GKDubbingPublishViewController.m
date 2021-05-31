//
//  GKDubbingPublishViewController.m
//  GKAudioRecorderDemo
//
//  Created by QuintGao on 2018/11/3.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDubbingPublishViewController.h"
#import "GKVideoPlayer.h"
#import "GKButton.h"
#import <Masonry/Masonry.h>
#import "GKDubbingManager.h"

@interface GKDubbingPublishViewController ()<GKVideoPlayerDelegate>

@property (nonatomic, strong) UILabel   *titleView;
@property (nonatomic, strong) UIButton  *saveBtn;

@property (nonatomic, strong) GKVideoPlayer *player;
@property (nonatomic, strong) UIImageView   *playView;
@property (nonatomic, strong) GKButton      *playBtn;

@end

@implementation GKDubbingPublishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.playView];
    
    [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(64);
        make.width.mas_equalTo(200.0f);
        make.height.mas_equalTo(200.0f * 16 / 9);
    }];
}

#pragma mark - GKVideoPlayerDelegate
- (void)player:(GKVideoPlayer *)player statusChanged:(GKVideoPlayerStatus)status {
    
}

- (void)player:(GKVideoPlayer *)player currentTime:(float)currentTime totalTime:(float)totalTime progress:(float)progress {
    
}

#pragma mark - User Actions
- (void)playAction:(id)sender {
    if (self.player.isPlaying) {
        [self.player pause];
    }else {
        if (self.player.status == GKVideoPlayerStatusUnload) {
            [self.player playVideoWithView:self.playView url:kDubbingVideoPath];
        }else {
            [self.player resume];
        }
    }
}

#pragma mark - 懒加载
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

@end
