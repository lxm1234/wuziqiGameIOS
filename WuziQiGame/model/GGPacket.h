//
//  GGPacket.h
//  WuziQiGame
//
//  Created by lxm on 2017/12/15.
//  Copyright © 2017年 lixiaomeng. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString * const GGPacketKeyData;
extern NSString * const GGPacketKeyType;
extern NSString * const GGPacketKeyAction;

typedef NS_ENUM(NSInteger, GGPacketType) {
    GGPacketTypeUnknown,
    GGPacketTypeMove,
    GGPacketTypeReset,
    GGPacketTypeUndo
};

typedef NS_ENUM(NSInteger, GGPacketAction) {
    GGPacketActionUnknown,
    GGPacketActionResetRequest,
    GGPacketActionResetAgree,
    GGPacketActionResetReject,
    GGPacketActionUndoRequest,
    GGPacketActionUndoAgree,
    GGPacketActionUndoReject
};
@interface GGPacket : NSObject
@property (strong, nonatomic) id data;
@property (assign, nonatomic) GGPacketType type;
@property (assign, nonatomic) GGPacketAction action;

- (id)initWithData:(id)data type:(GGPacketType)type action:(GGPacketAction)piece;
@end
