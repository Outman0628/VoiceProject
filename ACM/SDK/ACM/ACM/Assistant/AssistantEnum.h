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
};

#endif /* AssistantEnum_h */
