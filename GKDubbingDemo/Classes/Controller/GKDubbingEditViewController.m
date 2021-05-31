//
//  GKDubbingEditViewController.m
//  GKAudioRecorderDemo
//
//  Created by QuintGao on 2018/11/3.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDubbingEditViewController.h"
#import <GKAudioRecorder/GKAudioRecorder.h>
#import "GKVideoPlayer.h"
#import "GKButton.h"
#import "GKSliderView.h"
#import "GKDubbingManager.h"
#import <Masonry/Masonry.h>
#import <GKMessageTool/GKMessageTool.h>
#import "GKEffectCollectionViewCell.h"
#import "GKDubbingPublishViewController.h"

@interface GKDubbingEditViewController ()<GKVideoPlayerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UILabel   *titleView;
@property (nonatomic, strong) UIButton  *saveBtn;

@property (nonatomic, strong) GKVideoPlayer *player;
@property (nonatomic, strong) UIImageView   *playView;
@property (nonatomic, strong) GKButton      *playBtn;
@property (nonatomic, strong) UIView        *sliderBgView;
@property (nonatomic, strong) GKSliderView  *sliderView;

@property (nonatomic, strong) UICollectionView  *collectionView;
@property (nonatomic, strong) NSMutableArray    *effects;
@property (nonatomic, strong) NSMutableArray    *selectEffects;
@property (nonatomic, strong) NSMutableArray    *effectViews;

@end

@implementation GKDubbingEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navRightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.saveBtn];
    self.gk_navTitle = @"插入音效";
    
    [self.view addSubview:self.playView];
    [self.view addSubview:self.sliderBgView];
    [self.sliderBgView addSubview:self.sliderView];
    
    [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(64);
        make.width.mas_equalTo(200.0f);
        make.height.mas_equalTo(200.0f * 16 / 9);
    }];
    
    [self.sliderBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.playView.mas_bottom);
        make.height.mas_equalTo(20.0f);
    }];
    
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.centerY.equalTo(self.sliderBgView);
        make.height.mas_equalTo(4.0f);
    }];
    
    [self loadEffects];
}

- (void)loadEffects {
    NSDictionary *pListDic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"effmusicinfo" ofType:@"plist"]];
    // 排序
    NSMutableArray *allKeysArr = [NSMutableArray arrayWithArray:pListDic.allKeys];
    [allKeysArr sortUsingComparator:^NSComparisonResult(NSString *value1, NSString *value2) {
        if ([[value1 substringFromIndex:3] intValue] > [[value1 substringFromIndex:3] intValue]) {
            return NSOrderedDescending;
        }else if ([[value1 substringFromIndex:3] intValue] < [[value2 substringFromIndex:3] intValue]) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
    [allKeysArr enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        GKDubbingEffect *effect = [GKDubbingEffect new];
        effect.effect_img_name  = [NSString stringWithFormat:@"recorder_eff%lu", (unsigned long)idx];
        effect.effect_name      = pListDic[key];
        effect.effect_path      = [[[NSBundle mainBundle] pathForResource:@"eff" ofType:@"bundle"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a", key]];
        [self.effects addObject:effect];
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300) collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsVerticalScrollIndicator = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    [self.collectionView registerClass:[GKEffectCollectionViewCell class] forCellWithReuseIdentifier:@"GKEffectCollectionViewCell"];
    [self.view addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.sliderBgView.mas_bottom);
    }];
    
    [self.collectionView reloadData];
}

#pragma mark - GKVideoPlayerDelegate
- (void)player:(GKVideoPlayer *)player statusChanged:(GKVideoPlayerStatus)status {
    
}

- (void)player:(GKVideoPlayer *)player currentTime:(float)currentTime totalTime:(float)totalTime progress:(float)progress {
    self.sliderView.value = progress;
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.effects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GKEffectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GKEffectCollectionViewCell" forIndexPath:indexPath];
    cell.effect = self.effects[indexPath.item];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets top = {0, 0, 0, 0};
    return top;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat wh = [UIScreen mainScreen].bounds.size.width / 4.0f;
    return CGSizeMake(wh, wh);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 记录选中的音效，及需要插入音效的时间
    GKDubbingEffect *effect = self.effects[indexPath.item];
    
    GKAudioEffect *audioEffect = [GKAudioEffect new];
    audioEffect.effect_path = effect.effect_path;
    audioEffect.effect_time = self.player.currentTime;
    
    __weak typeof(self) weakSelf = self;
    
    [GKMessageTool showMessage:@"插入音效"];
    [[GKAudioRecorder sharedInstance] insertEffectWithAudioPath:kDubbingRecordPath effect:audioEffect success:^(AVCompositionTrack * _Nonnull track) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [GKMessageTool hideMessage];
            audioEffect.effect_track = track;
            [weakSelf.selectEffects addObject:audioEffect];
            
            // 插入成功后，播放音效
            [[GKAudioRecorder sharedInstance] startPlayEffectWithPath:effect.effect_path];
            
            // 添加音效视图
            [weakSelf insertEffectViewAtTime:audioEffect.effect_time
                                       index:[weakSelf.selectEffects indexOfObject:audioEffect]];
        });
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"音效插入失败：%@", error);
    }];
}

#pragma mark - User Actions
- (void)saveAction:(id)sender {
    NSMutableArray *pathArr = [NSMutableArray new];
    [pathArr addObject:kDubbingRecordPath];
    [pathArr addObject:self.videoPath];
    
    [GKMessageTool showMessage:@"视频合成中..."];
    [[GKAudioRecorder sharedInstance] compositionVideoWithVideoPath:self.videoPath audioPath:kDubbingRecordPath exportVideoPath:kDubbingVideoPath progress:^(float progress) {
        NSLog(@"视频合成进度：%f", progress);
    } success:^{
        NSLog(@"视频合成成功");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@", kDubbingRecordPath);
            [GKMessageTool hideMessage];
            GKDubbingPublishViewController *publishVC = [GKDubbingPublishViewController new];
            [self.navigationController pushViewController:publishVC animated:YES];
        });
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"视频合成失败：%@", error);
    }];
}

- (void)playAction:(id)sender {
    if (self.player.isPlaying) {
        [[GKAudioRecorder sharedInstance] pausePlayAudio];
        
        [self.player pause];
    }else {
        __weak typeof(self) weakSelf = self;
        [[GKAudioRecorder sharedInstance] startPlayAudioWithPath:kDubbingRecordPath time:0 finished:^{
            [weakSelf playAction:nil];
        }];
        
        [self.player setMute:YES];
        if (self.player.status == GKVideoPlayerStatusUnload) {
            [self.player playVideoWithView:self.playView url:self.videoPath];
        }else {
            [self.player resume];
        }
    }
}

- (void)effectDeleteAction:(UITapGestureRecognizer *)tap {
    UIView *effectView = tap.view;
    
    NSInteger index = effectView.tag - [effectView hash];
    
    GKAudioEffect *effect = self.selectEffects[index];
    
    // 调用删除方法，删除音效
    [GKMessageTool showMessage:@"删除音效"];
    [[GKAudioRecorder sharedInstance] deleteEffectWithAudioPath:kDubbingRecordPath effect:effect success:^{
        NSLog(@"音效删除成功");
        dispatch_async(dispatch_get_main_queue(), ^{
            [GKMessageTool hideMessage];
            [self.selectEffects removeObjectAtIndex:index];
            [self.effectViews removeObjectAtIndex:index];
            [effectView removeFromSuperview];
        });
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"音效删除失败：%@", error);
    }];
}

#pragma mark - Private Methods
- (void)insertEffectViewAtTime:(float)time index:(NSInteger)index {
    UIView *effectView = [UIView new];
    effectView.backgroundColor = [UIColor whiteColor];
    effectView.frame = CGRectMake(kScreenW * time / self.player.totalTime, 0, 4, 20.0f);
    effectView.tag = [effectView hash] + index;
    UITapGestureRecognizer *effectTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(effectDeleteAction:)];
    [effectView addGestureRecognizer:effectTap];
    [self.sliderBgView addSubview:effectView];
    [self.effectViews addObject:effectView];
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

- (UIButton *)saveBtn {
    if (!_saveBtn) {
        _saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [_saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _saveBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_saveBtn addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
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

- (UIView *)sliderBgView {
    if (!_sliderBgView) {
        _sliderBgView = [UIView new];
        _sliderBgView.backgroundColor = [UIColor blackColor];
    }
    return _sliderBgView;
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

- (NSMutableArray *)effects {
    if (!_effects) {
        _effects = [NSMutableArray new];
    }
    return _effects;
}

- (NSMutableArray *)selectEffects {
    if (!_selectEffects) {
        _selectEffects = [NSMutableArray new];
    }
    return _selectEffects;
}

- (NSMutableArray *)effectViews {
    if (!_effectViews) {
        _effectViews = [NSMutableArray new];
    }
    return _effectViews;
}

@end
