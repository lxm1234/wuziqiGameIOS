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

NSString * const INFO_YOUR_TURN = @"您的回合";
NSString * const INFO_OPPONENT_TURN = @"对方回合";

@interface CGBroadViewController (){
    CGBoard* board;
    GGPlayerType playerType;
    GGPlayer* AI;
    int timeSecBlack;
    int timeMinBlack;
    int timeSecWhite;
    int timeMinWhite;
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
    }
}

- (void)boardView:(CGBroadView *)boardView didTapOnPoint:(GGPoint)point{
    [self moveAtPoint:point sendPacketInLAN:YES];
}
- (void)moveAtPoint:(GGPoint)point sendPacketInLAN:(BOOL)send{
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
            [self handleWin];
        } else {
            
            [self switchPlayer];
            if(_gameMode == CGModeSingle){
                [self AIPlayWithMove:move];
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
@end
