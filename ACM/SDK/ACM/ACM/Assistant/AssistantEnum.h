//
//  AssistantEnum.h
//  ACM
//
//  Created by David on 2020/1/17.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef AssistantEnum_h
#define AssistantEnum_h


/*
 通话结束类型
 */

typedef NS_ENUM(NSInteger, AssistantCode) {
    /**
     无错误
     */
    AssistantOK = 0,
    
    /**
     未初始化
     */
    AssistantNotInited = -1,
    
    /**
     参数错误
     */
    AssistantErrorParam = -2,
    
    /**
     服务器异常
     */
    AssistantErrorServer = -3,
    
    /**
     网络异常
     */
    AssistantErrorNetwork = -4,
    
    /**
     文音转换创建任务错误
     */
    AssistantErrorCreatConverter = -5,
    
    /**
     文音转换错误
     */
    AssistantErrorConvert = -6,
    
    /**
     更新服务器文音文件错误
     */
    AssistantErrorUdateSeverTTSfile = -7,
    
    /**
     更新语音助手机器人配置错误
     */
    AssistantErrorUdateSeverAssConfig = -8,
    
    /**
     语音助手繁忙，有正在执行的试听或是设置更新行为
     */
    AssistantSettingBusy = -9,
    
    /**
     服务器返回接听助手错误配置数据
     */
    AssistantErrorIncorrectAnswerAssistantContent = -10,
    
    /**
     服务器返回拨打助手错误配置数据
     */
    AssistantErrorIncorrectDialAssistantContent = -11,

    /**
     文件已经存在
     */
    AssistantFileAlreadyExist = -12,
    
    /**
     音文转换失败
     */
    AssistantErrorAudioToTextFailed = -13,
    
    /**
     转换为wav 文件失败
     */
    AssistantErrorTransToWavFileFailed = -14,
};

typedef NS_ENUM(NSInteger, AudioToFileCode) {
    // 转换完成
    AudioToFileCodeOK = 0,
    // 取消转换
    AudioToFileCodeCancel = 1,
    // 转换错误
    AudioToFileCodeError = -1,
    // 转换中断
    AudioToFileCodeInterrupt = -2,
    // Busy
    AudioToFileCodeBusy= -3,
    
    // 文件不存在
    AssistantErrorFileNotExist = -4,
};

#endif /* AssistantEnum_h */
