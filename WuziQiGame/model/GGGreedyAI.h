//
//  GGGreedyAI.h
//  WuziQiGame
//
//  Created by lxm on 2017/12/14.
//  Copyright © 2017年 lixiaomeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CGBoard.h"

@interface GGGreedyAI : CGBoard

- (instancetype)initWithPlayer:(GGPlayerType)playerType;
- (int)getScoreWithPoint:(GGPoint)point;

@end
