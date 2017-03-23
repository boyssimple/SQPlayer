//
//  ViewController.m
//  SQPlayer
//
//  Created by zhouMR on 2017/3/23.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import "ViewController.h"
#import "SQPlayer.h"

@interface ViewController ()
@property (nonatomic, strong) SQPlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _player = [[SQPlayer alloc]initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200) withUrl:@"http://w5.dwstatic.com/8/6/1551/380767-100-1450416171.mp4"];
    _player.isLoop = YES;
    [self.view addSubview:_player];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
