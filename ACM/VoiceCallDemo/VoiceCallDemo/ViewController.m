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

#ifdef AssistantDef
#import <ACM/Assistant.h>
#import <ACM/AssistantItem.h>
#import <ACM/AnswerAssistant.h>
#endif
#import "../VideoChat/VideoChatViewController.h"
#import <UIKit/UIKit.h>






#define hostUrl @"https://liu.enjoyst.com"

@interface ViewController ()  <IACMCallBack, IRTCCallBack>
@property NSDictionary *apnsMsg;
@property BOOL inited;
//@property (nonatomic, copy) NSString *answerChannelId;
//@property (nonatomic, copy) NSString *peerId;
@property Call* inComeCall;
@property Call* outComeCall;
@property NSInteger callTimerCount;
@property AVAudioPlayer* player;
@property VideoChatViewController * videoCallViewCtrl;
@property BOOL initedState;
@property AVPlayer *avplayer;

//@property (nonatomic, copy) NSString *dialChannelId;

@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *remoteUserIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *msgTextField;


@property (weak, nonatomic) IBOutlet UIButton *regBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendMsgBtn;
@property (weak, nonatomic) IBOutlet UIButton *callBtn;

@property (weak, nonatomic) IBOutlet UIButton *callRobotBtn;

@property (weak, nonatomic) IBOutlet UILabel *remoteMsgLabel;
@property (weak, nonatomic) IBOutlet UILabel *localMsgLabel;

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

@property (weak, nonatomic) IBOutlet UIButton *audioCallBtn;

@end

@implementation ViewController


- (void)viewDidLoad {
    _initedState = false;
    [super viewDidLoad];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.viewController = self;
    self.inited = false;
    _callTimerCount = 60;
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
    
    #if (TARGET_IPHONE_SIMULATOR)
    [ACM initManager:hostUrl apnsToken:@"simulatorToken" acmCallback:self completion:^(AcmInitErrorCode errorCode) {
        if(errorCode == AcmInitOk){
            [ACM updateDialingTimer:self.callTimerCount];
            [self autoLogin];
            _initedState = true;
        }else
        {
            [self showAlert:@"初始化SDK 错误"];
        }
    } ];
    
    #endif
    
    [self initControls];
    //[self showAlert:@"测试窗体"];
    
}

- (void) handleApnsToken: (nullable NSString *)token{
    if(token != nil)
    {
        [ACM initManager:hostUrl apnsToken:token acmCallback:self completion:^(AcmInitErrorCode errorCode) {
            if(errorCode == AcmInitOk){
                [ACM updateDialingTimer:self.callTimerCount];
                self.initedState = true;
                [self autoLogin];
                
            }else{
                [self showAlert:@"初始化SDK 错误"];
            }
        } ];
        
    }
    else
    {
        NSLog(@"获取推送token 失败!");
    }
}

- (BOOL) handleApnsMessage:(nonnull NSDictionary *)message{
    
    if(self.inited == YES)
    {
        BOOL ret;
        ret = [ACM handleApnsMessage:message];
        self.apnsMsg = nil;
        self.remoteMsgLabel.text = [NSString stringWithFormat:@"4已调用SDK 处理apns 消息:%@", ret ? @"True" : @"False" ];
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
       // [self userRegist:nil];
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
    if(self.initedState == true){
        if(self.userIdTextField.text.length == 0)
        {
            [self showAlert: @"请输入注册id"];
            return;
        }
        
        [self Login:self.userIdTextField.text];
    }else{
        [ACM initManager:hostUrl apnsToken:nil acmCallback:self completion:^(AcmInitErrorCode errorCode) {
            if(errorCode == AcmInitOk){
                [ACM updateDialingTimer:self.callTimerCount];
                self.initedState = true;
                [self autoLogin];
            }else{
                [self showAlert:@"初始化SDK 错误"];
            }
        } ];
    }
}

- (IBAction)dialVideoCall:(id)sender {
    

    
    if(!self.checkPhoneCallParameters)
    {
        return;
    }
    
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    self.videoCallViewCtrl = (VideoChatViewController*)[storyboard instantiateViewControllerWithIdentifier:@"VIDEO_CHAT_VIEW_CONTROLLER"];
    
    [self.navigationController pushViewController:self.videoCallViewCtrl animated:YES];
    
    self.videoCallViewCtrl.localVideo.hidden = false;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1000*1000*5), dispatch_get_main_queue(), ^{
        NSArray *peersList = [self.remoteUserIdTextField.text componentsSeparatedByString:@";"];
        VideoParam  videoParam;
        videoParam.bitrate  = AgoraVideoBitrateStandard;
        videoParam.frameRate = AgoraVideoFrameRateFps15;
        videoParam.size = AgoraVideoDimension640x360;
        videoParam.orientationMode = AgoraVideoOutputOrientationModeAdaptative;
        
        videoParam.localView = self.videoCallViewCtrl.localVideo;
        videoParam.renderMode = AgoraVideoRenderModeHidden;
        
        
        
        self.outComeCall = [ACM ringVideoCall:peersList VideoCallParam:videoParam ircmCallback:self];
        
        
        self.callPanel.hidden = false;
        self.remoteUserIdLabel.text = self.remoteUserIdTextField.text;
    });

}


- (void) dropTest{
    /*
    [ACM loggedInCheck:self.userIdTextField.text completion:^(BOOL alreadyLoggedin, AgoraRtmQueryPeersOnlineErrorCode errorCode) {
        if(errorCode == AgoraRtmQueryPeersOnlineErrorOk)
        {
            if(alreadyLoggedin)
            {
                [self showAlertWidthCancel:@"该账号已在其他设备登录，继续登录会使以登录设备强制下线！" Callback:^(BOOL isOK) {
                    if(isOK)
                    {
                        [self Login:self.userIdTextField.text];
                    }
                    
                }];
            }
            else
            {
                [self Login:self.userIdTextField.text];
            }
            
        }else{
            [self showAlert:@"检查登录状态失败"];
        }
        
    }];
     */
}

- (void) Login: (NSString *)uid{
    [ACM loginACM:uid completion:^(AcmLoginErrorCode errorCode) {
        if (errorCode != AcmRtmLoginErrorOk) {
            [self showAlert: [NSString stringWithFormat:@"login error: %ld", errorCode]];
            return;
        }
        else{
            
            self.inited = true;
            //[self showAlert: @"注册成功"];
            self.remoteMsgLabel.text = @"注册成功";
            
            if(self.apnsMsg != nil)
            {
                [ACM handleApnsMessage:self.apnsMsg];
                
                //[self showAlert: @"倒入push msg"];
                self.remoteMsgLabel.text = @"导入push msg";
            }
            [self saveUser:self.userIdTextField.text];
            self.userIdTextField.enabled = false;
            self.regBtn.enabled = false;
        }
    }];
}
- (IBAction)callRobot:(id)sender {
    
    /*
    [ACM ringRobotAudioCall];
    
    self.callPanel.hidden = false;
    self.remoteUserIdLabel.text = @"语音助手";
    */
    
    [self PlayFile];
}

- (IBAction)audioCall:(id)sender {
    
    
    if(!self.checkPhoneCallParameters)
    {
        return;
    }
    
    NSArray *peersList = [self.remoteUserIdTextField.text componentsSeparatedByString:@";"];
    self.outComeCall = [ACM ringGroupAudioCall:peersList ircmCallback:self];
    /*
    NSString *remoteUid = self.remoteUserIdTextField.text;
    self.outComeCall = [ACM ringAudioCall:remoteUid ircmCallback:self];
    */
   
    self.callPanel.hidden = false;
    self.remoteUserIdLabel.text = self.remoteUserIdTextField.text;
    
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
        if(self.inComeCall.callType == AudioCall){
            [ACM agreeCall:self.inComeCall.channelId ircmCallback:self VideoCallParam:nil];
        }else{
            
            NSString * storyboardName = @"Main";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
            self.videoCallViewCtrl = (VideoChatViewController*)[storyboard instantiateViewControllerWithIdentifier:@"VIDEO_CHAT_VIEW_CONTROLLER"];
            
            [self.navigationController pushViewController:self.videoCallViewCtrl animated:YES];
            
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1000*1000*5), dispatch_get_main_queue(), ^{
            VideoParam  videoParam;
            videoParam.bitrate  = AgoraVideoBitrateStandard;
            videoParam.frameRate = AgoraVideoFrameRateFps15;
            videoParam.size = AgoraVideoDimension640x360;
            videoParam.orientationMode = AgoraVideoOutputOrientationModeAdaptative;
            
            videoParam.localView = self.videoCallViewCtrl.localVideo;
            videoParam.renderMode = AgoraVideoRenderModeHidden;
            
            [ACM agreeCall:self.inComeCall.channelId ircmCallback:self VideoCallParam:&videoParam];
             });

        }
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
- (IBAction)answerAssistSetting:(id)sender {
    /*
    NSString * storyboardName = @"AnswerAssistant";
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UINavigationController * vc = (UINavigationController*)[storyboard instantiateViewControllerWithIdentifier:@"AnswerAssistant"];
    [self presentViewController:vc animated:YES completion:^{}];
     */
    /*
    UIViewController* nextVc=[self.storyboard instantiateViewControllerWithIdentifier:storyboardName];
    [self.navigationController pushViewController:nextVc animated:YES];
    */
}

- (void)auditAssistant{
    /*
    AnswerAssistant *ass = [[AnswerAssistant alloc]init];
    ass.enable = YES;
   // ass.content = @"你好中国";
    
    AssistanItem *item1 = [[AssistanItem alloc]init];
    item1.interval = 5;
    item1.content = [NSString stringWithFormat:@"你好中国"];
    
    AssistanItem *item2 = [[AssistanItem alloc]init];
    item2.interval = 3;
    item2.content = [NSString stringWithFormat:@"天气晴朗"];
    
    [ass.contents addObject:item1];
    [ass.contents addObject:item2];
    
*/
}

- (IBAction)enableSpeakphoneClicked:(id)sender {
    [ACM setEnableSpeakerphone:YES];
    [self showAlert:@"设置外放"];
}

- (IBAction)disableSpeakphoneClicked:(id)sender {
    [ACM setEnableSpeakerphone:NO];
    [self showAlert:@"取消外放"];
}

- (void)playAssistantFileTest{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = @"https://liu.enjoyst.com/media/recording/ch_9d08bm96wU/0_20200305101514192.aac";//[documentPath stringByAppendingPathComponent:@"tts.mp3"];
    NSURL *urlFile = [NSURL fileURLWithPath:filePath];
    NSError *error = nil;
    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:urlFile error:&error];
    if (error == nil) {
        [self.player prepareToPlay];
    }
    [self.player play];

}
-(void) PlayFile{
    

    NSString *filePath = @"https://liu.enjoyst.com/media/recording/ch_9d08bm96wU/0_20200305101514192.aac";//[documentPath stringByAppendingPathComponent:@"tts.mp3"];
    NSURL *urlFile = [NSURL URLWithString:filePath];
    self.player = [[AVPlayer alloc] initWithURL:urlFile];
    
    [self.player play];
   
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
    
    NSString *message = [NSString stringWithFormat:@"demo connection state changed: %ld", state];
    NSLog(@"%@",message);
    
    if(state == AgoraRtmConnectionStateAborted)
    {
        [self showAlert:@"该账号在其他设备登录，您已下线!"];
        self.regBtn.enabled = true;
        self.userIdTextField.enabled = true;
    }
    else if(state ==  AgoraRtmConnectionStateReconnecting){
        [self showAlert:@"断线重连中"];
    }
    
}



- (void)messageReceived:(NSString * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId{
    NSLog(@"Message received from %@: %@", message, peerId);
    
    self.remoteMsgLabel.text = [NSString stringWithFormat:@"p2p: %@", message];
    
}



- (void)onCallReceived:(nonnull Call *)call{
   
    self.inComeCall = call;
    
    self.answerCallBtn2.hidden = false;
    self.endCallBtn2.hidden = true;
    self.robotAnswerCallBtn.hidden = false;
    self.answerPanel.hidden = false;
    if(call.callType == AudioCall){
        self.remoteUserIdLabel2.text =  [NSString stringWithFormat:@"音:%@",call.callerId];
    }else if(call.callType == VideoCall){
        self.remoteUserIdLabel2.text =  [NSString stringWithFormat:@"视:%@",call.callerId];
    }
    self.rejectBtn.hidden = false;
    self.authorityBtn.hidden = true;
    
}

- (void)onCallEnd:(nonnull Call *)call endCode:(AcmMsgType)dialCode
{
    if(dialCode == AcmMsgDialEndTimeout)
    {
        [self showAlert:@"通话结束，超时未接听"];
    }
    else if( dialCode ==  AcmMsgDialEndByCaller)
    {
        [self showAlert:@"通话结束，拨号方取消"];
    }
    
    self.inComeCall = nil;
    self.answerPanel.hidden = true;
}

- (void) debugInfo:(nonnull NSString *) debugInfo{
    
    dispatch_async(dispatch_get_main_queue(),^{
        self.remoteMsgLabel.text = debugInfo;
    });
    
}


- (void)onRemoteLeaveCall:(NSString * _Nonnull)channel fromPeer:(NSString * _Nonnull)peerId{
   

    self.answerPanel.hidden = true;
    self.callPanel.hidden = true;
    [self showAlert: [NSString stringWithFormat:@"对方结束通话"]];
}

#pragma mark - IRTCCallBack

- (void)onlineMemberUpdated:(NSArray *_Nonnull) onlineMemberList{
    if(onlineMemberList != nil)
    {
        NSLog(@"频道在线人员:%@", onlineMemberList);
        
    }
}

- (AgoraRtcVideoCanvas *_Nullable) firstRemoteVideoDecodedOfUid:(NSString *_Nonnull)uid size: (CGSize)size elapsed:(NSInteger)elapsed{
    
    if(self.videoCallViewCtrl != nil){
        
        if (self.videoCallViewCtrl.remoteVideo.hidden) {
            self.videoCallViewCtrl.remoteVideo.hidden = NO;
        }
         
        AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
        
        videoCanvas.view = self.videoCallViewCtrl.remoteVideo;
        videoCanvas.renderMode = AgoraVideoRenderModeHidden;
        return videoCanvas;
    }else{
        return nil;
    }
}

// 拨号结果
- (void)didPhoneDialResult:(AcmDialCode)dialCode{
    switch (dialCode) {
        case AcmPrepareOnphoneStage:
            [self showAlert:@"对方同意接通，即将开始通话"];
            break;
        case AcmDialSucced:

            [self showAlert:@"进入通话频道，开始通话"];
            break;
        case AcmDialingTimeout:
            [self showAlert:@"超时未接听"];
            self.callPanel.hidden = true;
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
    NSLog(@"ASR local1. Text:%@ timeStamp:%f isFinished:%d", text,startTime,finished);
    self.localMsgLabel.text = [NSString stringWithFormat:@"asrLocal: %@", text];
}


- (void)onRemoteText: (nonnull NSString *)text remoteAccount:(nonnull NSString *)remoteUid timeStamp:(NSTimeInterval)startTime msgStamp:(NSTimeInterval)msgTimestamp isFinished:(BOOL) finished
{
    NSLog(@"ASR remote1. from:%@ Text:%@ timeStamp:%f msgTimeStamp:%f isFinished:%d", remoteUid,text,startTime,msgTimestamp, finished);
    self.remoteMsgLabel.text = [NSString stringWithFormat:@"asr from %@: %@", remoteUid, text];
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
