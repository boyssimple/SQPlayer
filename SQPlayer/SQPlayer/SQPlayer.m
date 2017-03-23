//
//  SQPlayer.m
//  SQPlayer
//
//  Created by zhouMR on 2017/3/23.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import "SQPlayer.h"
#import <AVFoundation/AVFoundation.h>
#define CONTROL_HEIGHT 50

@interface SQPlayer()
@property (nonatomic, strong) UIImageView *ivBg;
@property (nonatomic,strong) AVPlayer *player;              //播放器对象
@property (nonatomic,strong) AVPlayerLayer *playerLayer;    //播放器对象Lyaer
@property (nonatomic, strong) UIView *controlView;          //控制view
@property (nonatomic, strong) UIButton *playOrPause;        //播放/暂停按钮
@property (nonatomic, strong) UIProgressView *progress;     //播放进度
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIButton *fullBtn;            //全屏按钮

@property (nonatomic,assign)   BOOL isShow;                 //控制栏是否显示
@property (nonatomic,assign)   NSInteger countTime;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation SQPlayer

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withUrl:(NSString*)url{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.url = url;
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.isShow = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toggleControl)];
    [self addGestureRecognizer:tap];
    
    _ivBg = [[UIImageView alloc]initWithFrame:CGRectZero];
    _ivBg.image = [UIImage imageNamed:@"bg_media_default"];
    [self addSubview:_ivBg];
    
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//视频填充模式
    [self.layer addSublayer:_playerLayer];
    
    _controlView = [[UIView alloc]initWithFrame:CGRectZero];
    _controlView.backgroundColor = [UIColor blackColor];
    [self addSubview:_controlView];
    
    _playOrPause = [[UIButton alloc]initWithFrame:CGRectZero];
    [_playOrPause setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_playOrPause addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    [_controlView addSubview:_playOrPause];
    
    _fullBtn = [[UIButton alloc]initWithFrame:CGRectZero];
    [_fullBtn setImage:[UIImage imageNamed:@"full"] forState:UIControlStateNormal];
    [_controlView addSubview:_fullBtn];
    
    _progress = [[UIProgressView alloc]initWithFrame:CGRectZero];
    _progress.trackTintColor= [UIColor whiteColor];
    _progress.progressTintColor= [UIColor redColor];
    _progress.progress = 0.0;
    _progress.hidden = YES;
    [_controlView addSubview:_progress];
    
    _slider = [[UISlider alloc]initWithFrame:CGRectZero];
    
    UIImage *image = [UIImage imageNamed:@"thumbImage"];
    [_slider setThumbImage:image forState:UIControlStateNormal];
    [_slider setThumbImage:image forState:UIControlStateHighlighted];
    _slider.userInteractionEnabled = TRUE;
    [_slider addTarget:self action:@selector(sliderAction) forControlEvents:UIControlEventTouchUpInside];
    [_slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [_controlView addSubview:_slider];
    [self addNotification];
}

- (void)sliderAction{
    self.countTime = 0;
}

- (void)sliderValueChange:(UISlider*)sender {
    self.countTime = 0;
    if (sender.value == 1) {
        sender.value = 0;
    }
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.duration) * sender.value;
    NSLog(@"时间：%f",currentTime);
    [self.player seekToTime:CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}


- (void)toggleControl{
    self.countTime = 0;
    if (!self.isShow) {
        [UIView animateWithDuration:0.3 animations:^{
            self.controlView.alpha = 1;
        }completion:^(BOOL finished) {
            self.controlView.hidden = NO;
            self.isShow = YES;
        }];
    }
}

- (void)layoutSubviews{
    CGRect r = self.playerLayer.frame;
    r.origin.x = 0;
    r.origin.y = 0;
    r.size.width = self.frame.size.width;
    r.size.height = self.frame.size.height;
    self.playerLayer.frame = r;
    
    r = self.ivBg.frame;
    r.origin.x = 0;
    r.origin.y = 0;
    r.size.width = self.frame.size.width;
    r.size.height = self.frame.size.height;
    self.ivBg.frame = r;
    
    r = self.controlView.frame;
    r.origin.x = 0;
    r.origin.y = self.frame.size.height - CONTROL_HEIGHT;
    r.size.width = self.frame.size.width;
    r.size.height = CONTROL_HEIGHT;
    self.controlView.frame = r;
    
    r = self.playOrPause.frame;
    r.origin.x = 0;
    r.origin.y = (self.controlView.frame.size.height - CONTROL_HEIGHT)/2.0;
    r.size.width = 50;
    r.size.height = r.size.width;
    self.playOrPause.frame = r;
    
    r = self.fullBtn.frame;
    r.size.width = 50;
    r.size.height = r.size.width;
    r.origin.x = self.frame.size.width - r.size.width;
    r.origin.y = (self.controlView.frame.size.height - CONTROL_HEIGHT)/2.0;
    self.fullBtn.frame = r;
    
    r = self.progress.frame;
    r.size.width = (self.fullBtn.frame.origin.x - 10) - (self.playOrPause.frame.origin.x + self.playOrPause.frame.size.width+10);
    r.size.height = self.playOrPause.frame.size.height;
    r.origin.x = self.playOrPause.frame.origin.x + self.playOrPause.frame.size.width + 10;
    r.origin.y = (self.controlView.frame.size.height - 5)/2.0;
    self.progress.frame = r;
    
    r = self.slider.frame;
    r.size.width = (self.fullBtn.frame.origin.x - 10) - (self.playOrPause.frame.origin.x + self.playOrPause.frame.size.width+10);
    r.size.height = 30;
    r.origin.x = self.playOrPause.frame.origin.x + self.playOrPause.frame.size.width + 10;
    r.origin.y = (self.controlView.frame.size.height - 30)/2.0;
    self.slider.frame = r;
}

#pragma mark - Event
- (IBAction)playClick:(UIButton *)sender {
    self.countTime = 0;
    if(self.player.rate == 0){ //说明时暂停
        [sender setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [self.player play];
    }else if(self.player.rate == 1){//正在播放
        [self.player pause];
        [sender setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}

- (void)hideControlView{
    if (self.isShow && self.player.rate == 1) {
        [UIView animateWithDuration:0.3 animations:^{
            self.controlView.alpha = 0;
        }completion:^(BOOL finished) {
            self.controlView.hidden = YES;
            self.isShow = NO;
        }];
        
    }
}

#pragma mark - 通知
/**
 *  添加播放器通知
 */
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)addProgressObserver{
    AVPlayerItem *playerItem = self.player.currentItem;
    UIProgressView *progress = self.progress;
    __weak typeof(self) safeSelf = self;
    //这里设置每秒执行一次
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(safeSelf.player.currentTime);
        float total = CMTimeGetSeconds([playerItem duration]);
        safeSelf.slider.value = current/total;
        [progress setProgress:(current/total) animated:YES];
        if (current) {
            [progress setProgress:(current/total) animated:YES];
        }
        
    }];
    
    self.timer=[NSTimer scheduledTimerWithTimeInterval:1
                                           target:self
                                         selector:@selector(timeWithHandle)
                                         userInfo:nil
                                          repeats:YES];
}

- (void)timeWithHandle{
    if (self.countTime < 5) {
        self.countTime++;
        NSLog(@"还有几秒:%zi",5-self.countTime);
    }else{
        [self hideControlView];
        self.countTime = 0;
    }
}

-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

/**
 *  通过KVO监控播放器状态
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        switch (status) {
            case AVPlayerStatusFailed:
                NSLog(@"播放失败");
                break;
            case AVPlayerStatusReadyToPlay:
                NSLog(@"AVPlayerStatusReadyToPlay");//CMTimeGetSeconds(playerItem.duration)
                break;
            default:
                NSLog(@"default:");
                break;
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f",totalBuffer);
    }
}

/**
 * 播放完成
 */
-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    self.slider.value = 0.01;
    [self sliderValueChange:self.slider];
    if (self.isLoop) {
        [self.player play];
        [self hideControlView];
        [self.playOrPause setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }else{
        [self.playOrPause setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self toggleControl];
    }
}

- (void)clear{
    [self removeObserverFromPlayerItem:self.player.currentItem];
    [self removeNotification];
    [self.timer invalidate];
    self.timer = nil;
}

-(AVPlayer *)player{
    if (!_player) {
        AVPlayerItem *playerItem = [self getPlayItem];
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        [self addProgressObserver];
        [self addObserverToPlayerItem:playerItem];
    }
    return _player;
}

-(AVPlayerItem *)getPlayItem{
    self.url =[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:self.url];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    return playerItem;
}

@end
