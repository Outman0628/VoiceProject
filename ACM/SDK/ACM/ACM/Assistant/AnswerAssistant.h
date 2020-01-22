//
//  AnswerAsistant.h
//  ACM
//
//  Created by David on 2020/1/12.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef AnswerAssistant_h
#define AnswerAssistant_h

/*
 *AnswerAsistant 语音接收器
 */

@class VoiceConfig;

@interface AnswerAssistant : NSObject

@property VoiceConfig *config;              // 声音设置
@property BOOL enable;                      // 开关
@property NSMutableArray *contents;         // 内容，放置 AssistantItem 对象

/*
 * 克隆
 */
-(AnswerAssistant *) clone;


@end

#endif /* AnswerAsistant_h */
