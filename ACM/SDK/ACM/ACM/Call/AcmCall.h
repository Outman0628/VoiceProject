//
//  AcmCall.h
//  ACM
//
//  Created by David on 2020/1/30.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef AcmCall_h
#define AcmCall_h

#import "Call.h"
#import <AgoraRtmKit/AgoraRtmKit.h>

@class AgoraRtmChannel;

@interface AcmCall : Call 

/*
 *生成通话内部同步信息通道
 */
-(BOOL)joinEventSyncChannel:(AgoraRtmJoinChannelBlock _Nullable)completionBlock;

@end

#endif /* AcmCall_h */
