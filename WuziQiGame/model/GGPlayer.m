//
//  GGPlayer.m
//  WuziQiGame
//
//  Created by lxm on 2017/12/14.
//  Copyright © 2017年 lixiaomeng. All rights reserved.
//

#import "GGPlayer.h"

@interface GGPlayer(){
    GGPlayerType _playerType;
    CGBoard* _board;
}
@end

@implementation GGPlayer
- (instancetype)initWithPlayer:(GGPlayerType)playerType difficulty:(GGDifficulty)difficulty {
    self = [super init];
    if (self) {
        _playerType = playerType;
        switch (difficulty) {
                case GGDifficultyEasy:
                _board = [[GGGreedyAI alloc] initWithPlayer:playerType];
                break;
                case GGDifficultyMedium:
                break;
                case GGDifficultyHard:
                break;
            default:
                break;
        }
    }
    return self;
}
- (void)update:(GGMove *)move {
    if (move != nil) {
        [_board makeMove:move];
    }
}
- (GGMove *)getMove {
    if ([_board isEmpty]) {
        GGPoint point;
        point.i = 7;
        point.j = 7;
        GGMove* move = [[GGMove alloc] initWithPlayer:_playerType point:point];
        [self update:move];
        return move;
    } else {
        GGMove* move = [_board getBestMove];
        return move;
    }
}
- (void)regret:(GGMove *)move {
    if (move != nil){
        [_board undoMove:move];
    }
}
@end
