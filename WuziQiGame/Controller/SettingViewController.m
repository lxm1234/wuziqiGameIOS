//
//  SettingViewController.m
//  WuziQiGame
//
//  Created by lxm on 2017/12/13.
//  Copyright © 2017年 lixiaomeng. All rights reserved.
//

#import "SettingViewController.h"
#import "ViewController.h"

@interface SettingViewController ()
- (IBAction)soundSwitch:(id)sender;
- (IBAction)musicSwitch:(id)sender;
- (IBAction)back:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *musicSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_musicSwitch setOn:[[NSUserDefaults standardUserDefaults] integerForKey:@"music"]];
    [_soundSwitch setOn:[[NSUserDefaults standardUserDefaults] integerForKey:@"sound"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)soundSwitch:(id)sender {
    UISwitch* swi = (UISwitch*)sender;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:@(swi.on).integerValue forKey:@"sound"];
    [defaults synchronize];
    ViewController* vc = (ViewController*)self.presentingViewController;
    if(swi.isOn){
        vc.moveSoundPlayer.volume = 1;
    } else {
        vc.moveSoundPlayer.volume = 0;
    }
}

- (IBAction)musicSwitch:(id)sender {
    UISwitch* swi = (UISwitch*)sender;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:@(swi.on).integerValue forKey:@"music"];
    [defaults synchronize];
    ViewController* vc = (ViewController*)self.presentingViewController;
    if(swi.isOn){
        [vc.musicPlayer play];
    } else {
        [vc.musicPlayer pause];
        vc.musicPlayer.currentTime = 0;
    }
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
