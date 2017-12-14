//
//  GGMove.m
//  WuziQiGame
//
//  Created by lxm on 2017/12/14.
//  Copyright © 2017年 lixiaomeng. All rights reserved.
//

#import "GGMove.h"

@implementation GGMove
-(instancetype) initWithPlayer:(GGPlayerType) playerType point:(GGPoint)point {
    self = [super init];
    if(self) {
        _playerType = playerType;
        _point = point;
    }
    return self;
}
@end
