//
//  CGBroadViewController.h
//  WuziQiGame
//
//  Created by lxm on 2017/12/13.
//  Copyright © 2017年 lixiaomeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CGBroadView.h"


typedef NS_ENUM(NSInteger,GGMode)
{
    CGModeSingle,
    CGModeDouble,
    CGModeLAN
};

@interface CGBroadViewController : UIViewController<GGBoardViewDelegate>
@property (weak, nonatomic) IBOutlet CGBroadView *broadView;
@property (assign, nonatomic) enum GGMode gameMode;
@end
