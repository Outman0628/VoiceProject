//
//  Assistant.h
//  ACM
//
//  Created by David on 2020/1/12.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef Assistant_h
#define Assistant_h

#import "AnswerAsistant.h"

@interface Asistant : NSObject

/*
 * 获取本机语音应答助手配置
 */
+(nullable AnswerAsistant *)getAnswerAsistant;

/*
 * 设置或更新本机语音应答助手配置
 */
+(BOOL)updateAnserAsistantParam:(nonnull AnswerAsistant*) answerAsistant;

/*
 * 预设文字试听,以配置中的参数进行试听
 */
+(void)auditionAnswerSistant:(nonnull AnswerAsistant*) answerAsistant;

/*
 * 取消试听
 */
+(void)cancelAuditionAnswerSistant:(nonnull AnswerAsistant*) answerAsistant;


@end

#endif /* Assistant_h */
