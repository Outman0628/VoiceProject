//
//  AcmCall.m
//  ACM
//
//  Created by David on 2020/1/30.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Message/RunTimeMsgManager.h"
#import "../Action/EventData.h"
#import "../Action/ActionManager.h"

#import "AcmCall.h"

@interface AcmCall() <AgoraRtmChannelDelegate>

// 通话事件同步通道
@property AgoraRtmChannel *eventSyncChannel;  

@end

@implementation AcmCall

-(id _Nullable )init
{
    if (self = [super init]) {
        self.eventSyncChannel = nil;
    }
    return self;
}



-(BOOL)joinEventSyncChannel:(AgoraRtmJoinChannelBlock _Nullable)completionBlock{
    if(_eventSyncChannel == nil){
        _eventSyncChannel = [RunTimeMsgManager createChannel:self.channelId Delegate:self];
    }
    
    if(_eventSyncChannel != nil){
        
        [_eventSyncChannel joinWithCompletion:^(AgoraRtmJoinChannelErrorCode errorCode) {
            if(completionBlock != nil){
                completionBlock(errorCode);
                
            }
        }];
        
        return YES;
    }
    return NO;
}


-(void)CallEnd{
    if(_eventSyncChannel != nil){
        [_eventSyncChannel leaveWithCompletion:^(AgoraRtmLeaveChannelErrorCode errorCode) {
            [RunTimeMsgManager destroyChannelWithId:self.channelId];
        }];
        
        _eventSyncChannel = nil;
    }
}

- (void)broadcastAsrData: (nonnull NSString *)text timeStamp:(NSTimeInterval)startTime isFinished:(BOOL) finished{
    
    if(_eventSyncChannel == nil){
        return;
    }
        
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval msgStamp=[dat timeIntervalSince1970];
    NSNumber *asrTimeStamp = [NSNumber numberWithDouble:startTime];
    NSNumber *msgTimeStamp = [NSNumber numberWithDouble:msgStamp];
    
    NSDictionary * rtmNotifyBean =
    @{@"title":@"ASRSync",
      @"accountSender": self.selfId,
      @"channel":  self.channelId,
      @"asrData": text,
      @"timeStamp": asrTimeStamp,
      @"isFinished": (finished == TRUE ? @"true" : @"false"),
      @"msgTimeStamp": msgTimeStamp,
      };
    
    NSError *error;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:rtmNotifyBean options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    AgoraRtmMessage *rtmMessage = [[AgoraRtmMessage alloc] initWithText:jsonStr];
    
    [_eventSyncChannel sendMessage:rtmMessage completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
        
        
        //sent((int)errorCode);
        if(errorCode != AgoraRtmSendPeerMessageErrorOk)
        {
            NSString *errNote =  [[NSString alloc] initWithString:[NSString stringWithFormat:@"Send asr data failed:%d", (int)errorCode]];
            
            NSLog(@"%@",errNote);
        }
        
    }];
}

- (void) broadcastLeaveCall{
    // 不用发送broadcast 退出后，事件频道会收到 memberLeft 事件
    /*
    NSDictionary * rtmNotifyBean =
    @{@"title":@"leave",
      @"accountSender": self.selfId,
      };
    
    NSError *error;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:rtmNotifyBean options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    AgoraRtmMessage *rtmMessage = [[AgoraRtmMessage alloc] initWithText:jsonStr];
    
    [_eventSyncChannel sendMessage:rtmMessage completion:^(AgoraRtmSendChannelMessageErrorCode errorCode) {
        
        
        //sent((int)errorCode);
        if(errorCode != AgoraRtmSendPeerMessageErrorOk)
        {
            NSString *errNote =  [[NSString alloc] initWithString:[NSString stringWithFormat:@"Send leave event failed:%d", (int)errorCode]];
            
            NSLog(@"%@",errNote);
        }
        
    }];
     */
}



/////////////////////////////////////////AgoraRtmChannelDelegate
/**
 Occurs when a user joins the channel.
 
 When a remote user calls the [joinWithCompletion]([AgoraRtmChannel joinWithCompletion:]) method and successfully joins the channel, the local user receives this callback.
 
 **Note**
 
 This callback is disabled when the number of the channel members exceeds 512.
 
 @param channel The channel that the user joins. See AgoraRtmChannel.
 @param member The user joining the channel. See AgoraRtmMember.
 */
- (void)channel:(AgoraRtmChannel * _Nonnull)channel memberJoined:(AgoraRtmMember * _Nonnull)member{

}

/**
 Occurs when a channel member leaves the channel.
 
 When a remote channel member calls the [leaveWithCompletion]([AgoraRtmChannel leaveWithCompletion:]) method and successfully leaves the channel, the local user receives this callback.
 
 **Note**
 
 This callback is disabled when the number of the channel members exceeds 512.
 
 @param channel The channel that the user leaves. See AgoraRtmChannel.
 @param member The channel member that leaves the channel. See AgoraRtmMember.
 */
- (void)channel:(AgoraRtmChannel * _Nonnull)channel memberLeft:(AgoraRtmMember * _Nonnull)member{
    EventData eventData = {EventRtmLeaveCall, 0,0,0,member.userId,self};
    [[ActionManager instance] HandleEvent:eventData];
}

/**
 Occurs when receiving a channel message.
 
 When a remote channel member calls the [sendMessage]([AgoraRtmChannel sendMessage:completion:]) method and successfully sends out a channel message, the local user receives this callback.
 
 @param channel The channel, to which the local user belongs. See AgoraRtmChannel.
 @param message The received channel message. See AgoraRtmMessage.
 
 **NOTE** Ensure that you check the `type` property when receiving the message instance: If the message type is `AgoraRtmMessageTypeRaw`, you need to downcast the received instance from AgoraRtmMessage to AgoraRtmRawMessage. See AgoraRtmMessageType.
 
 @param member The message sender. See AgoraRtmMember.
 */
- (void)channel:(AgoraRtmChannel * _Nonnull)channel messageReceived:(AgoraRtmMessage * _Nonnull)message fromMember:(AgoraRtmMember * _Nonnull)member{
    NSLog(@"event channel Message received from %@: %@", message.text, member.userId);
    NSData *jsonData = [message.text dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    NSString *title = dic[@"title"];
    /*
    if( [title isEqualToString:@"reject"] )
    {
        EventData eventData = {EventRtmRejectAudioCall, 0,0,0,dic[@"channel"],peerId,acmCallBack};
        [actionMgr HandleEvent:eventData];
    }
    
    else
     */
     if([title isEqualToString:@"ASRSync"])
    {
        EventData eventData = {  EventRemoeAsrResult, 0,0,0,dic,self};
        [[ActionManager instance] HandleEvent:eventData];
    }
    /*
     else if( [title isEqualToString:@"leave"] )
     {
         EventData eventData = {EventRtmLeaveCall, 0,0,0,dic[@"accountSender"],self};
         [[ActionManager instance] HandleEvent:eventData];
     }
    
    else if([title isEqualToString:@"agreeCall"])
    {
        EventData eventData = {EventRtmAgreeAudioCall, 0,0,0,dic[@"channel"]};
        [actionMgr HandleEvent:eventData];
    }
    else if([title isEqualToString:@"robotAnswerCall"])
    {
        EventData eventData = {EventRTMRobotAnser, 0,0,0,dic[@"channel"]};
        [actionMgr HandleEvent:eventData];
    }
     */
     }


/**
 Occurs when channel attributes are updated, and returns all attributes of the channel.
 
 **NOTE**
 
 This callback is enabled only when the user, who updates the attributes of the channel, sets [enableNotificationToChannelMembers]([AgoraRtmChannelAttributeOptions enableNotificationToChannelMembers]) as YES. Also note that this flag is valid only within the current channel attribute method call.
 
 @param channel The channel, to which the local user belongs. See AgoraRtmChannel.
 @param attributes An array of AgoraRtmChannelAttribute. See AgoraRtmChannelAttribute.
 */
- (void)channel:(AgoraRtmChannel * _Nonnull)channel attributeUpdate:(NSArray< AgoraRtmChannelAttribute *> * _Nonnull)attributes{
    
}


/**
事件更新频道人员更新回调
 */
- (void)channel:(AgoraRtmChannel * _Nonnull)channel memberCount:(int)count{
    /*
    EventData eventData = {EventEventChannelMemberCountUpdated, count,0,0,self};
    [[ActionManager instance] HandleEvent:eventData];
*/
}



@end
