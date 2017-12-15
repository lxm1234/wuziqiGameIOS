
//
//  GGPacket.m
//  WuziQiGame
//
//  Created by lxm on 2017/12/15.
//  Copyright © 2017年 lixiaomeng. All rights reserved.
//

#import "GGPacket.h"

NSString * const GGPacketKeyData = @"data";
NSString * const GGPacketKeyType = @"type";
NSString * const GGPacketKeyAction = @"piece";

@implementation GGPacket
- (id)initWithData:(id)data type:(GGPacketType)type action:(GGPacketAction)action {
    self = [super init];
    
    if (self) {
        self.data = data;
        self.type = type;
        self.action = action;
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.data forKey:GGPacketKeyData];
    [coder encodeInteger:self.type forKey:GGPacketKeyType];
    [coder encodeInteger:self.action forKey:GGPacketKeyAction];
}
-(id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        [self setData:[decoder decodeObjectForKey:GGPacketKeyData]];
        [self setType:[decoder decodeIntegerForKey:GGPacketKeyType]];
        [self setAction:[decoder decodeIntegerForKey:GGPacketKeyAction]];
    }
    
    return self;
}
@end
