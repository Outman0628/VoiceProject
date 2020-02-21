//
//  AcmAssistant.h
//  ACM
//
//  Created by David on 2020/2/19.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef AcmAssistant_h
#define AcmAssistant_h

#import "AssistantEnum.h"
#import "VoiceConfig.h"



/*
 文字转语音文件回调
 @param code 返回操作结果码
 @param filePath 文件在手机本地路径
*/
typedef void (^AcmAssistantTextToAudioBlock)(AssistantCode code, NSString * _Nullable filePath);


/*
 语音文件转文字
 @param code 返回操作结果码
 @param text 转换出来的文本
 */
typedef void (^AcmAssistantAudioToTextBlock)(AudioToFileCode code, NSString * _Nullable text);

/*
 机器人拨打计划回调
 @param code 返回操作结果码
 @param filePath 文件在手机本地路径
 */
typedef void (^AcmAssistantDialPlanBlock)(AssistantCode code);

@interface AcmAssistant : NSObject

/*
 * 获取音色名称表
 */
+(NSArray *_Nullable)getCandidates;


/*
 * 文字转换为音频文件，注意文件生成后需要调用方自行管理文件，SDK不会删除文件。
 @param text 转换文本
 @param config 语音配置选项
 @callback  block  转换结果回调callback, 详情参考 AcmAssistantTextToAudioBlock 定义
 */
+(void)textToAudioFile:(nonnull NSString*) text  VoiceConfig:(nonnull VoiceConfig*) config CallBack:(AcmAssistantTextToAudioBlock _Nonnull ) block;

/*
 * 添加机器人拨打计划
 @param dateTime 拨打日期
 @param planID 拨打计划ID
 @callback  block  添加计划结果回调callback, 详情参考 AcmAssistantDialPlanBlock 定义
 */
+ (void) addRobotDialPlan: ( nullable NSDate *)dateTime  PlanId:( NSInteger)planID  CallBack:(AcmAssistantDialPlanBlock _Nonnull ) block;


/*
 * 取消机器人拨打计划
 @param dateTime 拨打日期
 @param planID 拨打计划ID
 @callback  block  添加计划结果回调callback, 详情参考 AcmAssistantDialPlanBlock 定义
 */
+ (void) cancelRobotDialPlan: ( NSInteger)planID  CallBack:(AcmAssistantDialPlanBlock _Nonnull ) block;


/*
 * 语音转文字
 @param filePath 文件完整地址
 @callback  block 转换回调
 */
+ (void) audioFileToText: (nonnull NSString *)filePath  CallBack:(AcmAssistantAudioToTextBlock _Nonnull ) block;

/*
 * 取消转换
 */
+ (void) cancelAudioFileToText;

@end

#endif /* AcmAssistant_h */
