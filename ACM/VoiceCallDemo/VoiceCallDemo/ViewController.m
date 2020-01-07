//
//  ViewController.m
//  VoiceCallDemo
//
//  Created by David on 2020/1/3.
//  Copyright © 2020 genetek. All rights reserved.
//

#import "ViewController.h"
#import <AgoraRtmKit/AgoraRtmKit.h>
#import <ACM/ACM.h>

@interface ViewController ()  <IACMCallBack>

@property (nonatomic, copy) NSString *answerChannelId;

@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *remoteUserIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *msgTextField;


@property (weak, nonatomic) IBOutlet UIButton *regBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendMsgBtn;
@property (weak, nonatomic) IBOutlet UIButton *callBtn;

@property (weak, nonatomic) IBOutlet UILabel *remoteMsgLabel;

@property (weak, nonatomic) IBOutlet UILabel *remoteUserIdLabel;

@property (weak, nonatomic) IBOutlet UIButton *endCallBtn;

@property (weak, nonatomic) IBOutlet UIView *callPanel;

@property (weak, nonatomic) IBOutlet UIView *answerPanel;

@property (weak, nonatomic) IBOutlet UIButton *endCallBtn2;

@property (weak, nonatomic) IBOutlet UIButton *answerCallBtn2;

@property (weak, nonatomic) IBOutlet UILabel *remoteUserIdLabel2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[[AgoraRtmKit alloc] initWithAppId:@"appId" delegate:nil];
    [ACM initManager:@"bc6642a5ce2c423c8419c20e2e9e239f" acmCallback:self];
    [self initControls];
}

- (void) initControls{
    self.callPanel.hidden = true;
    self.answerPanel.hidden = true;
    self.userIdTextField.returnKeyType =UIReturnKeyDone;
    self.remoteUserIdTextField.returnKeyType =UIReturnKeyDone;
    self.msgTextField.returnKeyType =UIReturnKeyDone;
}

- (Boolean)checkParameters {
    /*
    if(GenetekMgr.status == LoginStatusOffline)
    {
        [self showAlert: @"用户未注册，请先注册!"];
        return false;
    }
     */
    
    NSString *remoteUid = self.remoteUserIdTextField.text;
    if(remoteUid == nil || remoteUid.length == 0)
    {
        [self showAlert: @"请输消息接收用户ID!"];
        return false;
    }
    
    NSString *msg = self.msgTextField.text;
    if(msg == nil || msg.length == 0)
    {
        [self showAlert: @"消息不能为空！"];
        return false;
    }
    
    return true;
}

- (Boolean)checkPhoneCallParameters {
    /*
    if(GenetekMgr.status == LoginStatusOffline)
    {
        [self showAlert: @"用户未注册，请先注册!"];
        return false;
    }
     */
    
    NSString *remoteUid = self.remoteUserIdTextField.text;
    if(remoteUid == nil || remoteUid.length == 0)
    {
        [self showAlert: @"请输入接收用户ID!"];
        return false;
    }
    
    return true;
}

- (IBAction)endingEdit:(UITextField *)sender {
    [sender resignFirstResponder];
}



- (IBAction)sendMsg:(id)sender {
    
    if(!self.checkParameters)
    {
        return;
    }
    
    NSString *msg = self.msgTextField.text;
    NSString *remoteUid = self.remoteUserIdTextField.text;
    
    
    [ACM sendP2PMessage:msg peerId:remoteUid completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
        //sent((int)errorCode);
        if(errorCode == AgoraRtmSendPeerMessageErrorOk)
        {
            [self showAlert: @"消息已发送!"];
            NSLog(@"Send msg succeed!");
        }
        else
        {
            
            NSString *errNote =  [[NSString alloc] initWithString:[NSString stringWithFormat:@"消息发送失败:%d", (int)errorCode]];
            //[self showAlert: errNote];
            NSLog(@"%@",errNote);
            
            [self showAlert: errNote];
        }
        
    }];
}



- (IBAction)userRegist:(id)sender {
    if(self.userIdTextField.text.length == 0)
    {
        [self showAlert: @"请输入注册id"];
        return;
    }
    
    [ACM loginACM:self.userIdTextField.text completion:^(AgoraRtmLoginErrorCode errorCode) {
        if (errorCode != AgoraRtmLoginErrorOk) {
            [self showAlert: [NSString stringWithFormat:@"login error: %ld", errorCode]];
            return;
        }
        else{
            [self showAlert: @"注册成功"];
            self.userIdTextField.enabled = false;
            self.regBtn.enabled = false;
        }
    }];
}

- (IBAction)audioCall:(id)sender {
    if(!self.checkPhoneCallParameters)
    {
        return;
    }
    
    NSString *remoteUid = self.remoteUserIdTextField.text;
    [ACM ringAudioCall:remoteUid];
    
    self.callPanel.hidden = false;
    self.remoteUserIdLabel.text = remoteUid;
}

- (IBAction)endCall:(id)sender {
    [ACM leaveCall:nil];
    self.callPanel.hidden = true;
}

- (IBAction)endCall2:(id)sender {
    [ACM leaveCall:nil];
    self.answerPanel.hidden = true;
}

- (IBAction)answerCall:(id)sender {
    if(self.answerChannelId != nil)
    {
        [ACM agreeCall:self.answerChannelId];
        self.answerCallBtn2.hidden = true;
        self.endCallBtn2.hidden = false;
        self.answerPanel.hidden = false;
    }
}

#pragma mark - IACMCallBack
- (void)connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason{
    
    NSString *message = [NSString stringWithFormat:@"connection state changed: %ld", state];
    NSLog(@"%@",message);
    
}



- (void)messageReceived:(NSString * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId{
    NSLog(@"Message received from %@: %@", message, peerId);
    
    self.remoteMsgLabel.text = message;
    
}



- (void)onCallReceived:(NSString * _Nonnull)channel fromPeer:(NSString * _Nonnull)peerId{
    self.answerChannelId = channel;
    self.answerCallBtn2.hidden = false;
    self.endCallBtn2.hidden = true;
    self.answerPanel.hidden = false;
    self.remoteUserIdLabel2.text = peerId;
    
}


@end
