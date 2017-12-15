//
//  GGHostListTableViewController.m
//  WuziQiGame
//
//  Created by lxm on 2017/12/15.
//  Copyright © 2017年 lixiaomeng. All rights reserved.
//

#import "GGHostListTableViewController.h"
@import CocoaAsyncSocket;


@interface GGHostListTableViewController ()<NSNetServiceBrowserDelegate,NSNetServiceDelegate,GCDAsyncSocketDelegate>
@property (strong,nonatomic) NSMutableArray *services;
@property (strong,nonatomic) NSNetServiceBrowser* serviceBrowser;
@property (strong,nonatomic) GCDAsyncSocket* serviceSocket;
@property (strong, nonatomic) GCDAsyncSocket *clientSocket;
@property (strong,nonatomic) NSNetService* serverService;
@property (strong, nonatomic) UIAlertController *alertController;
- (IBAction)onClickBack:(id)sender;
- (IBAction)onClickCreate:(id)sender;
@end

@implementation GGHostListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startBrowsing];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    if ([pref objectForKey:@"LAN_mode_tip_showed"] == nil) {
        [pref setObject:@1 forKey:@"LAN_mode_tip_showed"];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"局域网对战" message:@"请确保您和对方的手机处于同一局域网下，以保证局域网联机顺利进行" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)startBrowsing {
    if (self.services) {
        [self.services removeAllObjects];
    } else {
        self.services = [[NSMutableArray alloc] init];
    }
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    self.serviceBrowser.delegate = self;
    [self.serviceBrowser searchForServicesOfType:@"_gomoku._tcp." inDomain:@"local."];
}
- (void)stopBrowsing {
    if (self.serviceBrowser) {
        [self.serviceBrowser stop];
        self.serviceBrowser.delegate = nil;
        self.serviceBrowser = nil;
    }
}
- (void)startBroadcast{
    self.serviceSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    if ([self.serviceSocket acceptOnPort:0 error:&error]) {
        self.serverService = [[NSNetService alloc] initWithDomain:@"local." type:@"_gomoku._tcp." name:@"" port:[self.serviceSocket localPort]];
        [self.serverService setDelegate:self];
        [self.serverService publish];
    } else {
        NSLog(@"Unable to create socket. Error %@ with user info %@.",error,[error userInfo]);
    }
}
- (void)stopBroadcast{
    if (self.serverService) {
        self.serverService.delegate = nil;
        [self.serverService stop];
        self.serverService = nil;
        [self.serviceSocket disconnect];
    }
}
- (BOOL)connectWithService:(NSNetService *)service {
    BOOL isConnected = NO;
    NSArray *addresses = [[service addresses] mutableCopy];
    if (!self.clientSocket || ![self.clientSocket isConnected]) {
        NSLog(@"Initializing socket");
        self.clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        while (!isConnected && [addresses count]) {
            NSData *address = [addresses objectAtIndex:0];
            NSError *error = nil;
            if ([self.clientSocket connectToAddress:address error:&error]) {
                isConnected = YES;
            }else if (error) {
                NSLog(@"Unable to connect to address. Error %@ with user info %@.", error, [error userInfo]);
            }
        }
    } else {
        isConnected = [self.clientSocket isConnected];
    }
    return isConnected;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.services.count;
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
     NSNetService* service = self.services[indexPath.row];
     cell.textLabel.text = service.name;
     return cell;
 }
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSNetService *service = self.services[indexPath.row];
    service.delegate = self;
    [service resolveWithTimeout:20];
}


#pragma mark - NSNetServiceBrowserDelegate
- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    if (![service.name isEqualToString:[UIDevice currentDevice].name]) {
        [self.services addObject:service];
    }
    if (!moreComing) {
        [self.services sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        [self.tableView reloadData];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    
    [self.services removeObject:service];
    if(!moreComing) {
        [self.tableView reloadData];
    }
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)serviceBrowser {
    [self stopBrowsing];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *,NSNumber *> *)errorDict {
    [self stopBrowsing];
}
- (void)netServiceDidPublish:(NSNetService *)service {
    NSLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
}
#pragma mark --NSNetServiceDelegate
- (void)netService:(NSNetService *)service didNotPublish:(NSDictionary *)errorDict {
    NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@", [service domain], [service type], [service name], errorDict);
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *,NSNumber *> *)errorDict {
    sender.delegate = nil;
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    if ([self connectWithService:sender]) {
        NSLog(@"Did Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [sender domain], [sender type], [sender name], (int)[sender port]);
    } else {
        NSLog(@"Unable to Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [sender domain], [sender type], [sender name], (int)[sender port]);
    }
}
#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)socket didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"Accepted New Socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
    
    [self stopBroadcast];
    [self.delegate controller:self didHostGameOnSocket:newSocket];
    
    [self.alertController dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"Socket Did Connect to Host: %@ Port: %hu", host, port);
    
    [self stopBrowsing];
    [self.delegate controller:self didJoinGameOnSocket:socket];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    
    if (self.serviceSocket == socket) {
        if (error) {
            NSLog(@"Server Socket Did Disconnect with Error %@ with User Info %@.", error, [error userInfo]);
        } else {
            NSLog(@"Server Socket Disconnect.");
        }
        [socket setDelegate:nil];
        self.serviceSocket = nil;
        self.serverService = nil;
    } else if (self.clientSocket == socket) {
        if (error) {
            NSLog(@"Client Socket Did Disconnect with Error %@ with User Info %@.", error, [error userInfo]);
        } else {
            NSLog(@"Client Socket Disconnect.");
        }
        [socket setDelegate:nil];
        self.clientSocket = nil;
    }
}

#pragma mark -- Click
- (IBAction)onClickBack:(id)sender {
    [self stopBrowsing];
    [self.clientSocket setDelegate:nil];
    [self.clientSocket disconnect];
    self.clientSocket = nil;
    [self.delegate shouldDismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onClickCreate:(id)sender {
    [self startBroadcast];
    if (_alertController == nil) {
        _alertController = [UIAlertController alertControllerWithTitle:@"正在等待其他玩家加入..." message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self stopBroadcast];
        }];
        
        [_alertController addAction:action];
    }
    [self presentViewController:_alertController animated:YES completion:nil];
}
@end
