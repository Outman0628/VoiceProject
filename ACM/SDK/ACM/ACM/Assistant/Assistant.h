//
//  Assistant.h
//  ACM
//
//  Created by David on 2020/1/12.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef Assistant_h
#define Assistant_h
#import "AssistantEnum.h"
#import "AssistantCallback.h"

@class AnswerAssistant;

typedef void (^AssistantBlock)(AssistantCode code, NSError * _Nullable subCode);

@interface Assistant : NSObject

/*
 * 获取本机语音应答助手配置
 */
+(nullable AnswerAssistant *)getAnswerAsistant;

/*
 * 设置或更新本机语音应答助手配置
 */
+(void)updateAnswerAssistantParam:(nonnull AnswerAssistant*) answerAssistant  CallBack:(id <AssistantCallBack> _Nullable)delegate;

/*
 * 预设文字试听,以配置中的参数进行试听
 */
+(void)auditionAnswerAssistant:(nonnull AnswerAssistant*) answerAssistant  CallBack:(id <AssistantCallBack> _Nullable)delegate;

/*
 * 取消试听
 */
+(void)cancelAuditionAnswerAssistant:(nonnull AnswerAssistant*) answerAssistant;

/*
 * 获取音色名称表
 */
+(NSArray *_Nullable)getCandidates;

@end

#endif /* Assistant_h */
