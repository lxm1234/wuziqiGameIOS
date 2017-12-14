//
//  GGPlayer.h
//  WuziQiGame
//
//  Created by lxm on 2017/12/14.
//  Copyright © 2017年 lixiaomeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GGGreedyAI.h"

typedef NS_ENUM(NSInteger,GGDifficulty){
    GGDifficultyEasy,
    GGDifficultyMedium,
    GGDifficultyHard
};

@interface GGPlayer : NSObject
- (instancetype)initWithPlayer:(GGPlayerType)playerType difficulty:(GGDifficulty)difficulty;
- (void)update:(GGMove *)move;
- (GGMove *)getMove;
- (void)regret:(GGMove *)move;
@end
