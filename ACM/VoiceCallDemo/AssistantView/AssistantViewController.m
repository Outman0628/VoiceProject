//
//  AssistantViewController.m
//  VoiceCallDemo
//
//  Created by David on 2020/2/20.
//  Copyright © 2020 genetek. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AssistantViewController.h"
#import <ACM/AcmAssistant.h>
#import <AVKit/AVKit.h>"

@interface AssistantViewController()
@property (nonatomic, strong) IBOutlet UIButton *textToAudioBtn;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UIButton *addDialPlan;
@property (nonatomic, strong) IBOutlet UIButton *cancelDialPlan;
@property (nonatomic, strong) IBOutlet UIButton *startAudioToTextBtn;
@property (nonatomic, strong) IBOutlet UIButton *cancelAudioToTextBtn;
@property (nonatomic, strong) IBOutlet UITextView *audioToTextResultView;
@property (nonatomic, strong) IBOutlet UIView *rootView;

@property AVAudioPlayer* player;

@end

@implementation AssistantViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initControls];
}

- (void) initControls{
    
    //self.textView.returnKeyType =UIReturnKeyDone;
    //self.audioToTextResultView.returnKeyType =UIReturnKeyDone;
    
    UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    
    [_rootView addGestureRecognizer:tapGesturRecognizer];
    
   
}

-(void)tapAction:(id)tap
{
    for(UIView *subView in _rootView.subviews)
    {
        [subView resignFirstResponder];
    }
}

- (IBAction)textConvertToAudio:(id)sender {
    VoiceConfig *config = [[VoiceConfig alloc] init];
    if(self.textView.text.length != 0){
        self.textToAudioBtn.enabled = NO;
        [AcmAssistant textToAudioFile:self.textView.text VoiceConfig:config CallBack:^(AssistantCode code, NSString * _Nullable filePath) {
            if(code == AssistantOK){
                [self showAlert: [NSString stringWithFormat:@"转换成功：文件名字:%@", filePath] ];
                NSURL *urlFile = [NSURL fileURLWithPath:filePath];
                NSError *error = nil;
                self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:urlFile error:&error];
                if (error == nil) {
                    [self.player prepareToPlay];
                    [self.player play];
                }
                
            }else{
                [self showAlert:[NSString stringWithFormat:@"转换失败:%ld",(long)code]];
            }
             self.textToAudioBtn.enabled = YES;
        }];
        
    }else{
        [self showAlert:@"文本内容不能为空"];
    }
}

- (IBAction)createDialPlan:(id)sender {
    NSDate *planDate = [[NSDate alloc] init];
    [AcmAssistant addRobotDialPlan:planDate PlanId:@"test id" CallBack:^(AssistantCode code) {
        if(code == AssistantOK){
             [self showAlert:@"添加拨打计划成功"];
        }else{
             [self showAlert:[NSString stringWithFormat:@"添加拨打计划失败:%ld",(long)code]];
        }
    }];
}

- (IBAction)cancelDialPlan:(id)sender {
    NSDate *planDate = [[NSDate alloc] init];
    [AcmAssistant addRobotDialPlan:planDate PlanId:@"test id" CallBack:^(AssistantCode code) {
        if(code == AssistantOK){
            [self showAlert:@"取消拨打计划成功"];
        }else{
            [self showAlert:[NSString stringWithFormat:@"添加拨打计划失败:%ld",(long)code]];
        }
    }];
    
    [AcmAssistant cancelRobotDialPlan:@"test id" CallBack:^(AssistantCode code) {
        if(code == AssistantOK){
            [self showAlert:@"取消拨打计划成功"];
        }else{
            [self showAlert:[NSString stringWithFormat:@"取消拨打计划失败:%ld",(long)code]];
        }
    }];
}


- (IBAction)audioFileToText:(id)sender {
    //16k_test.pcm
    self.startAudioToTextBtn.enabled = NO;
    self.audioToTextResultView.text = @"转换中";
    
    //NSString* testFile = [[NSBundle mainBundle] pathForResource:@"16k_test" ofType:@"pcm"];
    NSString* testFile = [[NSBundle mainBundle] pathForResource:@"16k_test60s" ofType:@"pcm"];
    
    [AcmAssistant audioFileToText:testFile CallBack:^(AudioToFileCode code, NSString * _Nullable text) {
        if(code == AudioToFileCodeOK){
            self.audioToTextResultView.text = text;
            [self showAlert:@"转换成功"];
        }else{
            self.audioToTextResultView.text = @"转换失败";
            [self showAlert:[NSString stringWithFormat:@"转换失败:%ld", (long)code]];
        }
        
        self.startAudioToTextBtn.enabled = YES;
    }];
    
}

- (IBAction)cancelAudioFileToText:(id)sender {
    [AcmAssistant cancelAudioFileToText];
}




@end
