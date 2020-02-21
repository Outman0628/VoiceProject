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
#import "VoiceConfig.h"

@class AnswerAssistant;
@class DialAssistant;

typedef void (^AssistantBlock)(AssistantCode code, NSError * _Nullable subCode);
typedef void (^AnswerAssistantBlock)( AnswerAssistant *_Nullable answerAssistant, AssistantCode code);
typedef void (^DialAssistantBlock)( NSArray *_Nullable dialAssistantList, AssistantCode code);




@interface Assistant : NSObject

/*
 * 获取本机语音应答助手配置
 * 如果本地没有缓存，将会从服务器拉取配置，服务器也没有配置，则block 中 answerAssistant 为空
 */
+(void)getAnswerAsistant:(AnswerAssistantBlock _Nonnull ) block;

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
 * 获取本机拨打助手配置
 */
+(void)getDialAsistant:(DialAssistantBlock _Nonnull ) block;


/*
 * 预设文字试听,以配置中的参数进行试听
 */
+(void)auditionDialAssistant:(nonnull DialAssistant*) dialAssistant  CallBack:(id <AssistantCallBack> _Nullable)delegate;

/*
 * 设置或更新本机语音应答助手配置
 */
+(void)updateDialAssistantParam:(nonnull DialAssistant*) dialAssistant  CallBack:(id <AssistantCallBack> _Nullable)delegate;

/*
 * 获取音色名称表
 */
+(NSArray *_Nullable)getCandidates;


@end

#endif /* Assistant_h */
