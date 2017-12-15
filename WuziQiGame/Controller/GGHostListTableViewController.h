//
//  GGHostListTableViewController.h
//  WuziQiGame
//
//  Created by lxm on 2017/12/15.
//  Copyright © 2017年 lixiaomeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GCDAsyncSocket;
@protocol GGHostListControllerDelegate;

@interface GGHostListTableViewController : UITableViewController
@property (weak, nonatomic) id<GGHostListControllerDelegate> delegate;


@end
@protocol GGHostListControllerDelegate

- (void)controller:(GGHostListTableViewController *)controller didJoinGameOnSocket:(GCDAsyncSocket *)socket;
- (void)controller:(GGHostListTableViewController *)controller didHostGameOnSocket:(GCDAsyncSocket *)socket;
- (void)shouldDismiss;
@end
