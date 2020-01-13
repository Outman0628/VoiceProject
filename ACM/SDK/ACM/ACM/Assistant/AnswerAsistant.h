//
//  AnswerAsistant.h
//  ACM
//
//  Created by David on 2020/1/12.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef AnswerAsistant_h
#define AnswerAsistant_h

/*
 *AnswerAsistant 语音接收器
 */

@interface AnswerAsistant : NSObject

@property NSInteger speechVolume;           // 音量
@property NSInteger speechSpeed;            // 语速
@property NSInteger speechPich;             // 音调
@property NSString *curSpeaker;             // 当前播报人员
@property NSArray *speakerCadidates;        // 播报候选人员
@property BOOL enable;                      // 开关
@property NSString *content;                // 文字格式  [[间隔秒数]]+段落文本+[[间隔秒数]]+段落文本+...

@end

#endif /* AnswerAsistant_h */
