//
//  SQPlayer.h
//  SQPlayer
//
//  Created by zhouMR on 2017/3/23.
//  Copyright © 2017年 luowei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SQPlayer : UIView
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) BOOL isLoop;
- (instancetype)initWithFrame:(CGRect)frame withUrl:(NSString*)url;
- (void)clear;
@end
