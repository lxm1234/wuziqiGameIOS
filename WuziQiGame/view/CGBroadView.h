//
//  CGBroadView.h
//  WuziQiGame
//
//  Created by lxm on 2017/12/13.
//  Copyright © 2017年 lixiaomeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GGMove.h"

@protocol GGBoardViewDelegate;

@interface CGBroadView : UIView

@property (nonatomic,weak) id<GGBoardViewDelegate> delegate;

- (GGPoint)findPointWithLocation:(CGPoint)location;
- (void)insertPieceAtPoint:(GGPoint)point playerType:(GGPlayerType)playerType;
- (void)removeImageWithCount:(int)count;
- (void)reset;
@end

@protocol GGBoardViewDelegate<NSObject>

- (void)boardView:(CGBroadView *)boardView didTapOnPoint:(GGPoint)point;

@end
