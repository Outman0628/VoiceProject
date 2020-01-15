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
#import "AppDelegate.h"



@interface ViewController ()  <IACMCallBack, IRTCCallBack>
@property NSDictionary *apnsMsg;
@property BOOL inited;
//@property (nonatomic, copy) NSString *answerChannelId;
//@property (nonatomic, copy) NSString *peerId;
@property Call* inComeCall;
@property Call* outComeCall;

//@property (nonatomic, copy) NSString *dialChannelId;

@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *remoteUserIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *msgTextField;


@property (weak, nonatomic) IBOutlet UIButton *regBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendMsgBtn;
@property (weak, nonatomic) IBOutlet UIButton *callBtn;

@property (weak, nonatomic) IBOutlet UIButton *callRobotBtn;

@property (weak, nonatomic) IBOutlet UILabel *remoteMsgLabel;

@property (weak, nonatomic) IBOutlet UILabel *remoteUserIdLabel;

@property (weak, nonatomic) IBOutlet UIButton *endCallBtn;

@property (weak, nonatomic) IBOutlet UIView *callPanel;

@property (weak, nonatomic) IBOutlet UIView *answerPanel;

@property (weak, nonatomic) IBOutlet UIButton *endCallBtn2;

@property (weak, nonatomic) IBOutlet UIButton *rejectBtn;

@property (weak, nonatomic) IBOutlet UIButton *answerCallBtn2;

@property (weak, nonatomic) IBOutlet UIButton *robotAnswerCallBtn;

@property (weak, nonatomic) IBOutlet UILabel *remoteUserIdLabel2;

@property (weak, nonatomic) IBOutlet UIButton *authorityBtn;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.viewController = self;
    self.inited = false;
   /*
    NSString *token=[[NSUserDefaults standardUserDefaults] valueForKey:@"APNSToken"];
    if(token != nil)
    {
         [ACM initManager:@"bc6642a5ce2c423c8419c20e2e9e239f" backendHost:@"http://voice.enjoyst.com/" apnsToken:token acmCallback:self ];
    
        [self handleApnsToken:token];
    }
    else
    {
        NSLog(@"获取推送token 失败!");
    }
   */
    [self initControls];
}

- (void) handleApnsToken: (nullable NSString *)token{
    if(token != nil)
    {
        [ACM initManager:@"bc6642a5ce2c423c8419c20e2e9e239f" backendHost:@"http://voice.enjoyst.com" apnsToken:token acmCallback:self ];
        [self autoLogin];
    }
    else
    {
        NSLog(@"获取推送token 失败!");
    }
}

- (BOOL) handleApnsMessage:(nonnull NSDictionary *)message{
    
    if(self.inited == YES)
    {
        [ACM handleApnsMessage:message];
        self.apnsMsg = nil;
    }
    else
    {
        self.apnsMsg = message;
    }
    return YES;
}

- (void) initControls{
    self.callPanel.hidden = true;
    self.answerPanel.hidden = true;
    self.userIdTextField.returnKeyType =UIReturnKeyDone;
    self.remoteUserIdTextField.returnKeyType =UIReturnKeyDone;
    self.msgTextField.returnKeyType =UIReturnKeyDone;
}

- (void) autoLogin{
    NSString *uid = [self readParam];
    if(uid != nil && uid.length > 0)
    {
        self.userIdTextField.text = uid;
        [self userRegist:nil];
    }
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
    
    [ACM loginACM:self.userIdTextField.text completion:^(AcmLoginErrorCode errorCode) {
        if (errorCode != AcmRtmLoginErrorOk) {
            [self showAlert: [NSString stringWithFormat:@"login error: %ld", errorCode]];
            return;
        }
        else{
            
            self.inited = true;
            [self showAlert: @"注册成功"];
            
            if(self.apnsMsg != nil)
            {
                [ACM handleApnsMessage:self.apnsMsg];
                
                [self showAlert: @"倒入push msg"];
            }
            [self saveUser:self.userIdTextField.text];
            self.userIdTextField.enabled = false;
            self.regBtn.enabled = false;
        }
    }];
}
- (IBAction)callRobot:(id)sender {
    
    [ACM ringRobotAudioCall];
    
    self.callPanel.hidden = false;
    self.remoteUserIdLabel.text = @"语音助手";
    
}

- (IBAction)audioCall:(id)sender {
    if(!self.checkPhoneCallParameters)
    {
        return;
    }
    
    NSString *remoteUid = self.remoteUserIdTextField.text;
    //self.dialChannelId = [ACM ringAudioCall:remoteUid ircmCallback:nil];
    self.outComeCall = [ACM ringAudioCall:remoteUid ircmCallback:self];

   
    self.callPanel.hidden = false;
    self.remoteUserIdLabel.text = remoteUid;
    
}

- (IBAction)endCall:(id)sender {
    if(self.outComeCall != nil)
    {
        [ACM leaveCall:self.outComeCall];
        self.callPanel.hidden = true;

       
    }
}

- (IBAction)endCall2:(id)sender {
    //[ACM leaveCall:nil];
    if(self.inComeCall != nil)
    {
        [ACM leaveCall:self.inComeCall];
        self.answerPanel.hidden = true;
    }
}

- (IBAction)answerCall:(id)sender {
    if(self.inComeCall != nil)
    {
        [ACM agreeCall:self.inComeCall.channelId ircmCallback:self];
        self.answerCallBtn2.hidden = true;
        self.endCallBtn2.hidden = false;
        self.answerPanel.hidden = false;
        self.robotAnswerCallBtn.hidden = true;
        self.rejectBtn.hidden = true;
    }
}
- (IBAction)robotAnserCall:(id)sender {
    if(self.inComeCall != nil)
    {
        [ACM robotAnswerCall:self.inComeCall.channelId ircmCallback:self];
        self.answerCallBtn2.hidden = true;
        self.endCallBtn2.hidden = false;
        self.answerPanel.hidden = false;
        self.robotAnswerCallBtn.hidden = true;
        self.rejectBtn.hidden = true;
        self.authorityBtn.hidden = false;
    }
}

- (IBAction)rejectCall:(id)sender {
    if(self.inComeCall != nil)
    {
        [ACM rejectCall:self.inComeCall.channelId];
        self.inComeCall = nil;
        self.answerPanel.hidden = true;
    }
}

- (IBAction)getAuthority:(id)sender {
    if(self.inComeCall != nil)
    {
        [ACM getPhoneAuthority:self.inComeCall.channelId completion:^(AcmPhoneCallCode errorCode) {
            if(errorCode == AcmPhoneCallOK)
            {
                [self showAlert:@"话语权切换成功"];
            }
            else
            {
                [self showAlert: [NSString stringWithFormat:@"话语权切换失败:%ld",(long)errorCode]];
            }
        }];
    }
}


- (void)saveUser: (nonnull NSString *) uid{
    // 要保存的数据
    NSDictionary *dict = [NSDictionary dictionaryWithObject:uid forKey:@"uid"];
    
    // 获取路径.
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"loginToken.plist"];
    
    // 写入数据
    [dict writeToFile:filePath atomically:YES];
}

- (nullable NSString *)readParam{
    // 文件路径
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"loginToken.plist"];
    
    // 解析数据
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSString *result = dict[@"uid"];
    NSLog(@"token: %@", result);
    return result;
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



- (void)onCallReceived:(nonnull Call *)call{
   
    self.inComeCall = call;
    
    self.answerCallBtn2.hidden = false;
    self.endCallBtn2.hidden = true;
    self.robotAnswerCallBtn.hidden = false;
    self.answerPanel.hidden = false;
    self.remoteUserIdLabel2.text = call.callerId;
    self.rejectBtn.hidden = false;
    self.authorityBtn.hidden = true;
    
}


- (void)onRemoteLeaveCall:(NSString * _Nonnull)channel fromPeer:(NSString * _Nonnull)peerId{
   

    self.answerPanel.hidden = true;
    self.callPanel.hidden = true;
    [self showAlert: [NSString stringWithFormat:@"对方结束通话"]];
}

#pragma mark - IRTCCallBack

// 拨号结果
- (void)didPhoneDialResult:(AcmDialCode)dialCode{
    switch (dialCode) {
        case AcmDialSucced:

            [self showAlert:@"拨号接通，开始通话"];
            break;
        case AcmDialConnectTimeout:
            [self showAlert:@"超时未接听"];
            break;
        case AcmDialRemoteReject:
           
            self.callPanel.hidden = true;
            [self showAlert:@"对方拒接电话"];
            break;
        case AcmDialRobotAnswered:
            [self showAlert:@"机器人代接成功"];
            break;
            
        case AcmDialErrorApplyCall:
            [self showAlert:@"拨号失败：请求拨号通话服务失败，请检查配置和网路"];
            break;
        case AcmDialErrorWrongApplyCallResponse:
            [self showAlert:@"拨号失败：服务器返回错误通话配置"];
             self.callPanel.hidden = true;
            break;
        case AcmDialErrorWrongApplyAnswerCallResponse:
            [self showAlert:@"应答电话申请,服务器返回错误配置"];
            self.answerPanel.hidden = true;
            break;
        case AcmDialRequestSendSucceed:
            NSLog(@"拨号成功");
            break;
        default:
            break;
    }
}

- (void)didPhoneCallResult:(AcmPhoneCallCode)endCode
{
    self.answerPanel.hidden = true;
    self.callPanel.hidden = true;
    [self showAlert: [NSString stringWithFormat:@"通话结束:%ld", (long)endCode]];
}

- (void)onLocalText: (nonnull NSString *)text timeStamp:(NSTimeInterval)startTime isFinished:(BOOL) finished
{
   // NSLog(@"ASR local. Text:%@ timeStamp:%f isFinished:%d", text,startTime,finished);
}


/*
 远端语音转文字信息
 @param text 文本信息
 @param remoteUid 远端uid
 @startTime 文本开始的时间戳, 同一句话的startTime 是相同的
 @msgStamp 远端发送消息时的时间戳
 @finished false 翻译中的文字， true 翻译完成的文字
 */
- (void)onRemoteText: (nonnull NSString *)text remoteAccount:(nonnull NSString *)remoteUid timeStamp:(NSTimeInterval)startTime msgStamp:(NSTimeInterval)msgTimestamp isFinished:(BOOL) finished
{
    //NSLog(@"ASR remote. from:%@ Text:%@ timeStamp:%f msgTimeStamp:%f isFinished:%d", remoteUid,text,startTime,msgTimestamp, finished);
}


// 通话中warning 发生时回调
- (void)didPhonecallOccurWarning:(AgoraWarningCode)warningCode
{
    NSLog(@"通话服务警告:%ldd", (long)warningCode);
}

//  通话中error 发生时回调
 - (void)didOccurError:(AgoraErrorCode)errorCode
{
    NSLog(@"通话服务错误:%ldd", (long)errorCode);
}


- (void)didJoinChannel:(NSString * _Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed
{
    NSLog(@"用户:%lu加入通话",(unsigned long)uid);
}


@end
