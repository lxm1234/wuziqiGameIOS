//
//  CGBoard.h
//  WuziQiGame
//
//  Created by lxm on 2017/12/14.
//  Copyright © 2017年 lixiaomeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GGMove.h"

static int const GRID_SIZE = 15;

typedef NS_ENUM(NSInteger,CGPieceType) {
    CGPieceTypeBlank,
    CGPieceTypeBlack,
    CGPieceTypeWhite
};

@interface CGBoard : NSObject{
    @protected CGPieceType _gird[GRID_SIZE][GRID_SIZE];
}
-(instancetype) init;
-(void)initBoard;
-(BOOL)isEmpty;
-(BOOL)canMoveAtPoint:(GGPoint)point;
-(void)makeMove:(GGMove*)move;
-(void)undoMove:(GGMove*)move;
- (GGMove *)getBestMove;
-(BOOL)checkWinAtPoint:(GGPoint)point;
@end
