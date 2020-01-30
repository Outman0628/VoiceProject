//
//  Call.m
//  ACM
//
//  Created by David on 2020/1/9.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AcmCall.h"
#import "../Action/ActionManager.h"
#import <AgoraRtmKit/AgoraRtmKit.h>

@interface Call() <AgoraRtmChannelDelegate>
@property NSTimer *dialTimer;      // 拨号，拨号应答超时器
// 在线人员列表
@property NSMutableArray *  _Nonnull onlineMemberList;
@end

@implementation Call

-(id _Nullable )init
{
    if (self = [super init]) {
        self.localMuteState = false;
        self.remoteMuteState = false;
        self.subscriberList = [NSMutableArray array];
        self.onlineMemberList = [NSMutableArray array];
        self.dialTimer = nil;
    }
    return self;
}

-(void)addSubscriber: (nonnull NSString *) subscriberId
{
    BOOL isDuplicate = NO;
    for (int i=0; i<[self.subscriberList count]; i++) {
        NSString *subId = self.subscriberList[i];
        if([subId isEqualToString:subscriberId])
        {
            isDuplicate = YES;
            break;
        }
        
    }
    
    if(isDuplicate == NO)
    {
        [self.subscriberList addObject:subscriberId];
    }
}

-(void)updateStage: (CallStage) stage{
   // self.stage = stage;
    _stage = stage;
    if(_stage == Dialing)
    {
        if(_dialTimer == nil)
        {
            _dialTimer = [NSTimer scheduledTimerWithTimeInterval:[ActionManager instance].dialingTimetout repeats:NO block:^(NSTimer * _Nonnull timer) {
                 [self dialringTimeout];
            }];
        }
    }
    else
    {
        if(_dialTimer != nil)
        {
            [_dialTimer invalidate];
        }
    }
}

-(void)dialringTimeout{
    EventData eventData = {EventDialingTimeout,0,0,0,self};
    [[ActionManager instance] HandleEvent:eventData];
}

-(void)endObserverMode
{
    if(self.role == Observer)
    {
        if([self.selfId isEqualToString:self.callerId])
        {
            self.role = Originator;
        }
        else
        {
            self.role = Subscriber;
        }
    }
}

-(void)updateOnlineMember: (nonnull NSString *)uid Online:(BOOL)isOnline{
    for(int i = 0; i < _onlineMemberList.count ; i++){
        
        if([uid isEqualToString:_onlineMemberList[i]]){
            
            if(isOnline){
                    return;
                }
            else{
                [_onlineMemberList removeObjectAtIndex:i];
                return;
            }
        }
    }
    
    if(isOnline){
        [_onlineMemberList addObject:uid];
    }
        
}

- (NSArray *_Nonnull)getOnlineMembers{
    return _onlineMemberList;
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
 Occurs when the number of the channel members changes, and returns the new number.
 
 **NOTE**
 
 - When the number of channel members &le; 512, the SDK returns this callback when the number changes and at a MAXIMUM speed of once per second.
 - When the number of channel members exceeds 512, the SDK returns this callback when the number changes and at a MAXIMUM speed of once every three seconds.
 - You will receive this callback when successfully joining an RTM channel, so we recommend implementing this callback to receive timely updates on the number of the channel members.
 
 @param channel The channel, to which the local user belongs. See AgoraRtmChannel.
 @param count Member count of this channel.
 */
- (void)channel:(AgoraRtmChannel * _Nonnull)channel memberCount:(int)count{
    
}

@end
