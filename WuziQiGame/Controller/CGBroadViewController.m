//
//  CGBroadViewController.m
//  WuziQiGame
//
//  Created by lxm on 2017/12/13.
//  Copyright © 2017年 lixiaomeng. All rights reserved.
//

#import "CGBroadViewController.h"
#import "GGPlayer.h"
#import "ViewController.h"
#import "GGHostListTableViewController.h"
#import "GGPacket.h"
@import CocoaAsyncSocket;

NSString * const INFO_YOUR_TURN = @"您的回合";
NSString * const INFO_OPPONENT_TURN = @"对方回合";

@interface CGBroadViewController ()<GGHostListControllerDelegate,GCDAsyncSocketDelegate>{
    CGBoard* board;
    GGPlayerType playerType;
    GGPlayer* AI;
    int timeSecBlack;
    int timeMinBlack;
    int timeSecWhite;
    int timeMinWhite;
    BOOL shouldDismiss;
    BOOL isHost;
    BOOL oppositeReset;
    NSTimer *timer;
    GGMove *whiteMove;
    GGMove *blackMove;
}
- (IBAction)onBackClick:(id)sender;
- (IBAction)onClick_btnReset:(id)sender;
- (IBAction)onClick_btnUndo:(id)sender;
@property (strong, nonatomic) UIAlertController *winAlertController;
@property (weak, nonatomic) IBOutlet UIButton *btnRest;
@property (weak, nonatomic) IBOutlet UIButton *btnUndo;
@property (weak, nonatomic) IBOutlet UILabel *blackTimer;
@property (weak, nonatomic) IBOutlet UILabel *whiteTimer;
@property (weak, nonatomic) IBOutlet UILabel *lblInformation;
@property (strong, nonatomic) UIAlertController *resetWaitAlertController;
@property (strong, nonatomic) UIAlertController *resetChooseAlertController;
@property (strong, nonatomic) UIAlertController *resetRejectAlertController;
@property (strong, nonatomic) UIAlertController *waitAlertController;
@property (strong, nonatomic) UIAlertController *undoWaitAlertController;
@property (strong, nonatomic) UIAlertController *undoChooseAlertController;
@property (strong, nonatomic) UIAlertController *undoRejectAlertController;
@property (strong, nonatomic) GCDAsyncSocket* socket;
@end

@implementation CGBroadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    board = [[CGBoard alloc] init];
    playerType = GGPlayerTypeBlack;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _broadView.delegate = self;
    _btnUndo.enabled = NO;
    if (self.gameMode == CGModeSingle){
        [self choosePlayerType];
    } else if(self.gameMode == CGModeDouble){
        [self startTimer];
    } else if(self.gameMode == CGModeLAN && shouldDismiss){
        [self dismissViewControllerAnimated:NO completion:nil];
    } else if(self.gameMode == CGModeLAN && _socket == nil) {
        [self performSegueWithIdentifier:@"findGame" sender:nil];
    } else if(self.gameMode == CGModeLAN && _socket != nil) {
        [self startGameInLANMode];
    }
}
- (void)startGameInLANMode {
    [self startTimer];
    if (!isHost) {
        _lblInformation.text = INFO_OPPONENT_TURN;
        self.waitAlertController = [UIAlertController alertControllerWithTitle:@"请等待对方先下" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:_waitAlertController animated:YES completion:nil];
    } else {
        _lblInformation.text = INFO_YOUR_TURN;
    }
    
}
- (void)startTimer {
    // initialize the timer label
    timeSecBlack = 0;
    timeMinBlack = 0;
    timeSecWhite = 0;
    timeMinWhite = 0;
    
    NSString* timeNow = [NSString stringWithFormat:@"%02d:%02d", timeMinBlack, timeSecBlack];
    
    _whiteTimer.text = timeNow;
    _blackTimer.text = timeNow;
    
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
}
-(void)shouldDismiss{
    shouldDismiss = YES;
}
- (void)controller:(GGHostListTableViewController *)controller didJoinGameOnSocket:(GCDAsyncSocket *)socket {
    self.socket = socket;
    [_socket setDelegate:self];
    _broadView.userInteractionEnabled = NO;
    isHost = NO;
    [_socket readDataWithTimeout:-1 tag:1];
}
- (void)controller:(GGHostListTableViewController *)controller didHostGameOnSocket:(GCDAsyncSocket *)socket {
    self.socket = socket;
    [self.socket setDelegate:self];
    isHost = YES;
    [_socket readDataWithTimeout:-1 tag:1];
    
}
- (void)timerTick:(NSTimer *)timer {
    if (playerType == GGPlayerTypeBlack) {
        timeSecBlack++;
        if (timeSecBlack == 60)
        {
            timeSecBlack = 0;
            timeMinBlack++;
        }
        //Format the string 00:00
        NSString* timeNow = [NSString stringWithFormat:@"%02d:%02d", timeMinBlack, timeSecBlack];
        _blackTimer.text= timeNow;
    } else {
        timeSecWhite++;
        if (timeSecWhite == 60)
        {
            timeSecWhite = 0;
            timeMinWhite++;
        }
        //Format the string 00:00
        NSString* timeNow = [NSString stringWithFormat:@"%02d:%02d", timeMinWhite, timeSecWhite];
        _whiteTimer.text= timeNow;
    }
}
- (void)stopTimer
{
    [timer invalidate];
    timer = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onBackClick:(id)sender {
    [timer invalidate];
    timer = nil;
    [_socket disconnect];
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void) handleReset{
    [self stopTimer];
    [board initBoard];
    _broadView.userInteractionEnabled = YES;
    playerType = GGPlayerTypeBlack;
    [_broadView reset];
    blackMove = nil;
    whiteMove = nil;
    _btnUndo.enabled = NO;
}

- (IBAction)onClick_btnReset:(id)sender {
    if (self.gameMode == CGModeSingle){
        [self handleReset];
        [self choosePlayerType];
    } else if(self.gameMode == CGModeDouble){
        [self handleReset];
        [self startTimer];
    } else if(self.gameMode == CGModeLAN){
        if (oppositeReset == YES) {
            [self handleReset];
            [self startGameInLANMode];
            
            oppositeReset = NO;
            NSString *data = @"reset";
            GGPacket *packet = [[GGPacket alloc] initWithData:data type:GGPacketTypeReset action:GGPacketActionUnknown];
            [self sendPacket:packet];
        } else {
            self.resetWaitAlertController = [UIAlertController alertControllerWithTitle:@"等待对方回应" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:_resetWaitAlertController animated:YES completion:nil];
            
            GGPacket *packet = [[GGPacket alloc] initWithData:nil type:GGPacketTypeReset action:GGPacketActionResetRequest];
            [self sendPacket:packet];
        }
    }
}

- (IBAction)onClick_btnUndo:(id)sender {
    if (self.gameMode == CGModeSingle){
        if (blackMove != nil && whiteMove != nil) {
            [board undoMove:blackMove];
            [board undoMove:whiteMove];
            [AI regret:blackMove];
            [AI regret:whiteMove];
            [_broadView removeImageWithCount:2];
            blackMove = nil;
            whiteMove = nil;
           _btnUndo.enabled = NO;
        }
    } else if(self.gameMode == CGModeDouble){
        if (playerType == GGPlayerTypeBlack) {
            [board undoMove:whiteMove];
            [_broadView removeImageWithCount:1];
            [self switchPlayer];
            _btnUndo.enabled = NO;
            whiteMove = nil;
        } else {
            [board undoMove:blackMove];
            [_broadView removeImageWithCount:1];
            [self switchPlayer];
            _btnUndo.enabled = NO;
            blackMove = nil;
        }
    } else if (_gameMode == CGModeLAN) {
        self.undoWaitAlertController = [UIAlertController alertControllerWithTitle:@"等待对方回应" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:_undoWaitAlertController animated:YES completion:nil];
        
        GGPacket *packet = [[GGPacket alloc] initWithData:nil type:GGPacketTypeUndo action:GGPacketActionUndoRequest];
        [self sendPacket:packet];
        
    }
}

- (void)boardView:(CGBroadView *)boardView didTapOnPoint:(GGPoint)point{
    [self moveAtPoint:point sendPacketInLAN:YES];
}
- (void)moveAtPoint:(GGPoint)point sendPacketInLAN:(BOOL)sendPacket{
    if ([board canMoveAtPoint:point]){
        if(_gameMode == CGModeDouble){
            _btnUndo.enabled = YES;
        }
        GGMove* move = [[GGMove alloc] initWithPlayer:playerType point:point];
        [_broadView insertPieceAtPoint:move.point playerType:move.playerType];
        [board makeMove:move];
        [self saveMove:move];
        ViewController* vc = (ViewController*)self.presentingViewController;
        [vc.moveSoundPlayer play];
        if([board checkWinAtPoint:move.point]){
            if (_gameMode == CGModeLAN && sendPacket == YES) {
                NSDictionary *data = @{ @"i" : @(point.i), @"j" : @(point.j) };
                GGPacket *packet = [[GGPacket alloc] initWithData:data type:GGPacketTypeMove action:GGPacketActionUnknown];
                [self sendPacket:packet];
            }
            [self handleWin];
        } else {
            
            [self switchPlayer];
            if(_gameMode == CGModeSingle){
                [self AIPlayWithMove:move];
            }else if (_gameMode == CGModeLAN && sendPacket == YES) {
                _btnUndo.enabled = NO;
                NSDictionary *data = @{ @"i" : @(point.i), @"j" : @(point.j) };
                GGPacket *packet = [[GGPacket alloc] initWithData:data type:GGPacketTypeMove action:GGPacketActionUnknown];
                [self sendPacket:packet];
                _broadView.userInteractionEnabled = NO;
            } else if (_gameMode == CGModeLAN && sendPacket == NO) {
                _broadView.userInteractionEnabled = YES;
            }
        }
    }
}
- (void)AIPlayWithMove:(GGMove*)move{
    _btnRest.enabled = NO;
    _btnUndo.enabled = NO;
    _broadView.userInteractionEnabled = NO; dispatch_async(dispatch_get_global_queue(DISPATCH_TARGET_QUEUE_DEFAULT, 0), ^{
        [AI update:move];
        GGMove* AImove = [AI getMove];
        [board makeMove:AImove];
        [self saveMove:AImove];
        dispatch_async(dispatch_get_main_queue(), ^{
            _btnRest.enabled = YES;
            if (blackMove != nil && whiteMove != nil) {
                _btnUndo.enabled = YES;
            }
            [_broadView insertPieceAtPoint:AImove.point playerType:AImove.playerType];
            if ([board checkWinAtPoint:AImove.point]){
                [self handleWin];
            } else {
                [self switchPlayer];
                _broadView.userInteractionEnabled = YES;
            }
        });
    });
}

- (void)switchPlayer {
    if (playerType == GGPlayerTypeBlack) {
        playerType = GGPlayerTypeWhite;
    } else {
        playerType = GGPlayerTypeBlack;
    }
    if (_lblInformation.text == INFO_YOUR_TURN) {
        _lblInformation.text = INFO_OPPONENT_TURN;
    } else if (_lblInformation.text == INFO_OPPONENT_TURN) {
        _lblInformation.text = INFO_YOUR_TURN;
    }
}
- (void)choosePlayerType{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"请选择先后手" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* actionBlack = [UIAlertAction actionWithTitle:@"先手" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self startTimer];
        AI = [[GGPlayer alloc] initWithPlayer:GGPlayerTypeWhite difficulty:GGDifficultyEasy];
        _lblInformation.text = INFO_YOUR_TURN;
    }];
    UIAlertAction* actionWhite = [UIAlertAction actionWithTitle:@"后手" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self startTimer];
        AI = [[GGPlayer alloc] initWithPlayer:GGPlayerTypeBlack difficulty:GGDifficultyEasy];
        [self AIPlayWithMove:nil];
        _lblInformation.text = INFO_OPPONENT_TURN;
    }];
    [alert addAction:actionBlack];
    [alert addAction:actionWhite];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void) handleWin{
    NSString *alertTitle;
    if (playerType == GGPlayerTypeBlack) {
        alertTitle = @"黑方获胜!";
    } else {
        alertTitle = @"白方获胜!";
    }
    [self dismissAlertControllers];
    self.winAlertController = [UIAlertController alertControllerWithTitle:alertTitle message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [_winAlertController addAction:action];
    [self presentViewController:_winAlertController animated:YES completion:nil];
    _broadView.userInteractionEnabled = NO;
    _btnRest.enabled = YES;
    _btnUndo.enabled = NO;
    [self stopTimer];
}

- (void)saveMove:(GGMove *)move {
    if (playerType == GGPlayerTypeBlack) {
        blackMove = move;
    } else {
        whiteMove = move;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *destinationNavigationController = segue.destinationViewController;
    GGHostListTableViewController *targetController = (GGHostListTableViewController *)(destinationNavigationController.topViewController);
    targetController.delegate = self;
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)socket didReadData:(NSData *)data withTag:(long)tag {
    [self parseData:data];
    [socket readDataWithTimeout:-1 tag:1];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {
    if (error) {
        NSLog(@"Socket Did Disconnect with Error %@ with User Info %@.", error, [error userInfo]);
    } else {
        NSLog(@"Socket Disconnect.");
    }
    
    if (_socket == socket) {
        _socket.delegate = nil;
        _socket = nil;
    }
    [self stopTimer];
    
    [self dismissAlertControllers];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"对方已经断开连接" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)parseData:(NSData*)data{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    GGPacket* packet = [unarchiver decodeObjectForKey:@"packet"];
    [unarchiver finishDecoding];
    if ([packet type] == GGPacketTypeMove) {
        NSNumber *i = [(NSDictionary *)[packet data] objectForKey:@"i"];
        
        NSNumber *j = [(NSDictionary *)[packet data] objectForKey:@"j"];
        
        GGPoint point;
        point.i = i.intValue;
        point.j = j.intValue;
        
        if (_waitAlertController != nil) {
            [_waitAlertController dismissViewControllerAnimated:YES completion:nil];
            self.waitAlertController = nil;
        }
        
        [self moveAtPoint:point sendPacketInLAN:NO];
        if (blackMove != nil && whiteMove != nil && ![board checkWinAtPoint:point]) {
            _btnUndo.enabled = YES;
        }
    } else if ([packet type] == GGPacketTypeReset) {
        if ([packet action] == GGPacketActionResetRequest) {
            
            [self dismissAlertControllers];
            
            self.resetChooseAlertController = [UIAlertController alertControllerWithTitle:@"对方请求重开" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionAgree = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                GGPacket *packet = [[GGPacket alloc] initWithData:nil type:GGPacketTypeReset action:GGPacketActionResetAgree];
                [self sendPacket:packet];
                [self handleReset];
                [self startGameInLANMode];
            }];
            
            UIAlertAction *actionReject = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                GGPacket *packet = [[GGPacket alloc] initWithData:nil type:GGPacketTypeReset action:GGPacketActionResetReject];
                [self sendPacket:packet];
            }];
            
            [_resetChooseAlertController addAction:actionAgree];
            [_resetChooseAlertController addAction:actionReject];
            [self presentViewController:_resetChooseAlertController animated:YES completion:nil];
            
        } else if ([packet action] == GGPacketActionResetAgree) {
            [self dismissAlertControllers];
            
            [self handleReset];
            [self startGameInLANMode];
            
        } else if ([packet action] == GGPacketActionResetReject) {
            [self dismissAlertControllers];
            
            self.resetRejectAlertController = [UIAlertController alertControllerWithTitle:@"对方拒绝了你的请求" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            
            [_resetRejectAlertController addAction:action];
            [self presentViewController:_resetRejectAlertController animated:YES completion:nil];
        }
        
    } else if (packet.type == GGPacketTypeUndo) {
        if (packet.action == GGPacketActionUndoRequest) {
            [self dismissAlertControllers];
            
            self.undoChooseAlertController = [UIAlertController alertControllerWithTitle:@"对方请求悔棋" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionAgree = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                GGPacket *packet = [[GGPacket alloc] initWithData:nil type:GGPacketTypeUndo action:GGPacketActionUndoAgree];
                [self sendPacket:packet];
                [board undoMove:blackMove];
                [board undoMove:whiteMove];
                [_broadView removeImageWithCount:2];
                blackMove = nil;
                whiteMove = nil;
                _btnUndo.enabled = NO;
            }];
            
            UIAlertAction *actionReject = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                GGPacket *packet = [[GGPacket alloc] initWithData:nil type:GGPacketTypeUndo action:GGPacketActionUndoReject];
                [self sendPacket:packet];
            }];
            
            [_undoChooseAlertController addAction:actionAgree];
            [_undoChooseAlertController addAction:actionReject];
            [self presentViewController:_undoChooseAlertController animated:YES completion:nil];
        } else if (packet.action == GGPacketActionUndoAgree) {
            [self dismissAlertControllers];
            
            [board undoMove:blackMove];
            [board undoMove:whiteMove];
            [_broadView removeImageWithCount:2];
            blackMove = nil;
            whiteMove = nil;
            _btnUndo.enabled = NO;
        } else if (packet.action == GGPacketActionUndoReject) {
            [self dismissAlertControllers];
            
            self.undoRejectAlertController = [UIAlertController alertControllerWithTitle:@"对方拒绝了你的请求" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            
            [_undoRejectAlertController addAction:action];
            [self presentViewController:_undoRejectAlertController animated:YES completion:nil];
        }
    }
}
- (void)sendPacket:(GGPacket *)packet {
    NSMutableData* packetData = [[NSMutableData alloc] init];
    NSKeyedArchiver* keyedArchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:packetData];
    [keyedArchiver encodeObject:packet forKey:@"packet"];
    [keyedArchiver finishEncoding];
    NSMutableData* buffer = [[NSMutableData alloc] init];
    [buffer appendBytes:packetData.bytes length:packetData.length];
    [_socket writeData:buffer withTimeout:-1.0 tag:0];
}
- (void) dismissAlertControllers {
    [_winAlertController dismissViewControllerAnimated:YES completion:nil];
    [_waitAlertController dismissViewControllerAnimated:YES completion:nil];
    [_resetWaitAlertController dismissViewControllerAnimated:YES completion:nil];
    [_resetChooseAlertController dismissViewControllerAnimated:YES completion:nil];
    [_resetRejectAlertController dismissViewControllerAnimated:YES completion:nil];
    [_undoWaitAlertController dismissViewControllerAnimated:YES completion:nil];
    [_undoChooseAlertController dismissViewControllerAnimated:YES completion:nil];
    [_undoRejectAlertController dismissViewControllerAnimated:YES completion:nil];
    
    self.winAlertController = nil;
    self.waitAlertController = nil;
    self.resetWaitAlertController = nil;
    self.resetChooseAlertController = nil;
    self.resetRejectAlertController = nil;
    self.undoWaitAlertController = nil;
    self.undoChooseAlertController = nil;
    self.undoRejectAlertController = nil;
}

@end
