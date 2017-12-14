//
//  CGBoard.m
//  WuziQiGame
//
//  Created by lxm on 2017/12/14.
//  Copyright © 2017年 lixiaomeng. All rights reserved.
//

#import "CGBoard.h"

@implementation CGBoard
-(instancetype) init {
    self = [super init];
    if (self) {
        [self initBoard];
    }
    return self;
}
-(void)initBoard {
    for(int i = 0 ; i < GRID_SIZE ; ++i) {
        for(int j = 0; j < GRID_SIZE;++j) {
            _gird[i][j] = CGPieceTypeBlank;
        }
    }
}
-(BOOL)isEmpty {
    for(int i = 0 ; i < GRID_SIZE ; ++i) {
        for(int j = 0; j < GRID_SIZE;++j) {
            if (_gird[i][j] != CGPieceTypeBlank){
                return NO;
            }
        }
    }
    return YES;
}
-(BOOL)canMoveAtPoint:(GGPoint)point {
    return _gird[point.i][point.j] == CGPieceTypeBlank;
}
-(void)makeMove:(GGMove*)move {
    GGPoint point = move.point;
    if ([self canMoveAtPoint:point]){
        if(move.playerType == GGPlayerTypeBlack){
            _gird[point.i][point.j] = CGPieceTypeBlack;
        } else {
            _gird[point.i][point.j] = CGPieceTypeWhite;
        }
    }
}
- (GGMove *)getBestMove {
    return nil;
}
-(BOOL)checkWinAtPoint:(GGPoint)point {
    int count = 1;
    int i = point.i;
    int j = point.j;
    
    // Horizontal
    for (j++; j < GRID_SIZE; j++) {
        if (_gird[i][j] == _gird[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    j = point.j;
    for (j--; j >= 0; j--) {
        if (_gird[i][j] == _gird[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        count = 1;
    }
    
    // Vertical
    i = point.i;
    j = point.j;
    for (i++; i < GRID_SIZE; i++) {
        if (_gird[i][j] == _gird[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    i = point.i;
    for (i--; i >= 0; i--) {
        if (_gird[i][j] == _gird[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        count = 1;
    }
    
    // Oblique up
    i = point.i + 1;
    j = point.j + 1;
    for (; i < GRID_SIZE && j < GRID_SIZE; i++, j++) {
        if (_gird[i][j] == _gird[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    i = point.i - 1;
    j = point.j - 1;
    for (; i >= 0 && j >= 0; i--, j--) {
        if (_gird[i][j] == _gird[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        count = 1;
    }
    
    // Oblique down
    i = point.i + 1;
    j = point.j - 1;
    for (; i < GRID_SIZE && j >= 0; i++, j--) {
        if (_gird[i][j] == _gird[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    i = point.i - 1;
    j = point.j + 1;
    for (; i >= 0 && j < GRID_SIZE; i--, j++) {
        if (_gird[i][j] == _gird[point.i][point.j]) {
            count++;
        } else {
            break;
        }
    }
    if (count >= 5) {
        return YES;
    } else {
        return NO;
    }
}
-(void)undoMove:(GGMove*)move {
    GGPoint point = move.point;
    _gird[point.i][point.j] = CGPieceTypeBlank;
}
@end
