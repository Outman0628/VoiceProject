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

@interface AnswerAssistant : NSObject

@property NSInteger speechVolume;           // 音量  (0-15)
@property NSInteger speechSpeed;            // 语速  (0-9)
@property NSInteger speechPich;             // 音调  (0-9)
@property NSInteger curSpeakerIndex;        // 当前播报人员(speakerCadidates 中的index)
@property BOOL enable;                      // 开关
//@property NSString *content;                // 文字格式  [[间隔秒数]]+段落文本+[[间隔秒数]]+段落文本+...
@property NSMutableArray *contents;         // 内容，放置 AssistantItem 对象

/*
 * 克隆
 */
-(AnswerAssistant *) clone;


@end

#endif /* AnswerAsistant_h */
