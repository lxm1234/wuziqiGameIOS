//
//  CGBroadView.m
//  WuziQiGame
//
//  Created by lxm on 2017/12/13.
//  Copyright © 2017年 lixiaomeng. All rights reserved.
//

#import "CGBroadView.h"
@interface CGBroadView(){
    CGFloat margin;
    CGFloat interval;
    NSMutableArray *imageViews;
    UIImageView *indicatorView;
}
@end

@implementation CGBroadView

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tap];
    indicatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"indicator"]];
    imageViews = [NSMutableArray array];
    return self;
}
- (void)drawRect:(CGRect)rect {
    UIImage* image = [UIImage imageNamed:@"board2"];
    [image drawInRect:rect];
    CGRect CGBorderRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    UIBezierPath* borderPath = [UIBezierPath bezierPathWithRoundedRect:CGBorderRect cornerRadius:0];
    borderPath.lineWidth = 8;
    [[UIColor blackColor] setStroke];
    [borderPath stroke];
    margin = 15;
    interval = (self.bounds.size.width - margin * 2) / 14;
    CGFloat borderLineWidth = 2;
    CGFloat insideLineWidth = 1;
    for (int i = 0 ; i < 15; ++i){
        UIBezierPath* horizontalLine = [[UIBezierPath alloc] init];
        UIBezierPath* verticalLine = [[UIBezierPath alloc] init];
        if (i == 0 || i == 14) {
            [horizontalLine moveToPoint:CGPointMake(margin - 1, margin + interval * i)];
            [horizontalLine addLineToPoint:CGPointMake(margin + interval * 14 + 1, margin + interval * i)];
            [verticalLine moveToPoint:CGPointMake(margin + interval * i, margin)];
            [verticalLine addLineToPoint:CGPointMake(margin + interval * i, margin + interval * 14)];
            horizontalLine.lineWidth = borderLineWidth;
            verticalLine.lineWidth = borderLineWidth;
        } else {
            [horizontalLine moveToPoint:CGPointMake(margin, margin + interval * i)];
            [horizontalLine addLineToPoint:CGPointMake(margin + interval * 14, margin + interval * i)];
            [verticalLine moveToPoint:CGPointMake(margin + interval * i, margin)];
            [verticalLine addLineToPoint:CGPointMake(margin + interval * i, margin + interval * 14)];
            horizontalLine.lineWidth = insideLineWidth;
            verticalLine.lineWidth = insideLineWidth;
        }
        [[UIColor blackColor] setStroke];
        [horizontalLine stroke];
        [verticalLine stroke];
        CGFloat dotRadius = 3;
        int dotList[5][2] = {{3,3},{3,11},{7,7},{11,3},{11,11}};
        for (int i = 0; i < 5; ++i) {
            CGFloat centerX = dotList[i][0] * interval + margin;
            CGFloat centerY = dotList[i][1] * interval + margin;
            CGRect rect = CGRectMake(centerX - dotRadius, centerY - dotRadius, dotRadius * 2, dotRadius * 2);
            UIBezierPath* dot = [UIBezierPath bezierPathWithOvalInRect:rect];
            [[UIColor blackColor] setFill];
            [dot fill];
        }
    }
}

- (GGPoint)findPointWithLocation:(CGPoint)location{
    int row = (int)((location.y - margin)/interval);
    CGFloat modY = (location.y - margin)/interval - row;
    if (modY > 0.5 && row < 14){
        row++;
    }
    int clomn = (int)((location.x - margin)/interval);
    CGFloat modX = (location.x - margin)/interval - clomn;
    if (modX > 0.5 && clomn < 14){
        clomn++;
    }
    GGPoint point;
    point.i = row;
    point.j = clomn;
    NSLog(@"%d, %d", row, clomn);
    return point;
}

- (void)insertPieceAtPoint:(GGPoint)point playerType:(GGPlayerType)playerType {
    NSString* imageName;
    if (playerType == GGPlayerTypeBlack){
        imageName = @"piece_black";
    } else {
        imageName = @"piece_white";
    }
    CGFloat imageSize = interval;
    
    CGFloat originX = point.j * interval + margin - imageSize/2;
    CGFloat originY = point.i * interval + margin - imageSize/2;
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.frame = CGRectMake(originX, originY, imageSize, imageSize);
    [self addSubview:imageView];
    [imageViews addObject:imageView];
    indicatorView.frame = imageView.frame;
    if (indicatorView.superview != self) {
        [self addSubview:indicatorView];
    }
}

- (void) handleTap:(UITapGestureRecognizer *)tapGestureRecognizer{
    CGPoint location = [tapGestureRecognizer locationInView:self];
    GGPoint point = [self findPointWithLocation:location];
    [self.delegate boardView:self didTapOnPoint:point];
}
- (void)removeImageWithCount:(int)count {
    for (int i = 0; i < count; i++) {
        UIImageView* imageView = (UIImageView*)[imageViews lastObject];
        [imageView removeFromSuperview];
        imageView = nil;
        [imageViews removeLastObject];
    }
    UIImageView *imageView = [imageViews lastObject];
    if (imageView != nil) {
        indicatorView.frame = imageView.frame;
    } else {
        [indicatorView removeFromSuperview];
    }

}
- (void)reset {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [imageViews removeAllObjects];
}

@end
