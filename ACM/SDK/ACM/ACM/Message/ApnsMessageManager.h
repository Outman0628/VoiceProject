//
//  ApnsMessageManager.h
//  ACM
//
//  Created by David on 2020/1/9.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef ApnsMessageManager_h
#define ApnsMessageManager_h

#import "../Action/ActionManager.h"


@interface ApnsMessageManager : NSObject
/*
 处理APNS 推送消息
 
 @param message apns 推送消息
 @param actionMgr 事件调度器
 @return YES 需要弹出本地提示消息， NO 该消息不需要弹出本地消息
 */

+ (BOOL) handleApnsMessage:(nonnull NSDictionary *)message actionManager:(nonnull ActionManager *)actionMgr;

@end

#endif /* ApnsMessageManager_h */
