//
//  AssistantCallback.h
//  ACM
//
//  Created by David on 2020/1/22.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef AssistantCallback_h
#define AssistantCallback_h

#import <ACM/AssistantEnum.h>

/**
 语音助手设置Callback
 */
@protocol AssistantCallBack <NSObject>
@optional

/**
 试听结果
 
 @param code 试听结果，参见AssistantCode.
 @param subCode 出错项对应的具体错误
 
 */
- (void)auditResult:(AssistantCode) code Error:(NSError * _Nullable) subCode;

/**
 更新接听助手结果回调
 
 @param code 试听结果，参见AssistantCode.
  @param subCode 出错项对应的具体错误
 */
- (void)updateAnswerAssistantResult:(AssistantCode) code Error:(NSError * _Nullable) subCode;

/**
 更新拨打助手结果回调
 
 @param code 试听结果，参见AssistantCode.
 @param subCode 出错项对应的具体错误
 */
- (void)updateDialAssistantResult:(AssistantCode) code Error:(NSError * _Nullable) subCode;


@end

#endif /* AssistantCallback_h */
