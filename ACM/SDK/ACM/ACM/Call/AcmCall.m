//
//  AcmCall.m
//  ACM
//
//  Created by David on 2020/1/30.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../Message/RunTimeMsgManager.h"

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
