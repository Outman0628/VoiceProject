//
//  DialAssistant.h
//  ACM
//
//  Created by David on 2020/2/6.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef DialAssistant_h
#define DialAssistant_h

/*
 *语音拨打机器人配置
 */

@class VoiceConfig;

@interface DialAssistant : NSObject

@property (readonly) NSString *assId;             // 记录ID，由服务器生成
@property VoiceConfig *config;              // 声音设置
@property NSDate *dialDateTime;                 // 定时拨打时间
@property NSMutableArray *contents;         // 内容，放置 AssistantItem 对象
@property NSMutableArray *subscribers;      // 接听人员列表

@end
#endif /* DialAssistant_h */
