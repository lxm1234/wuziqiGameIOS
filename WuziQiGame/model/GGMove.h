//
//  GGMove.h
//  WuziQiGame
//
//  Created by lxm on 2017/12/14.
//  Copyright © 2017年 lixiaomeng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,GGPlayerType) {
    GGPlayerTypeBlack,
    GGPlayerTypeWhite
};

typedef struct {
    int i;
    int j;
} GGPoint;

@interface GGMove : NSObject
@property (nonatomic,readonly) GGPlayerType playerType;
@property (nonatomic,readonly) GGPoint point;
-(instancetype) initWithPlayer:(GGPlayerType) playerType point:(GGPoint)point;
@end
