//
//  AcmLog.h
//  ACM
//
//  Created by David on 2020/3/10.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef AcmLog_h
#define AcmLog_h

#define LOG_NONE 0   // 关闭日志
#define ERR_LOG 1 /* 应用程序无法正常完成操作，比如网络断开，内存分配失败等 */
#define WARN_LOG 2 /* 进入一个异常分支，但并不会引起程序错误 */
#define INFO_LOG 3 /* 日常运行提示信息，比如登录、退出日志 */
#define DEBUG_LOG 4 /* 调试信息，打印比较频繁，打印内容较多的日志 */

#include "LogManager.h"


//#define LLog(module,level,...) [[LogManager sharedInstance] logInfo:module LogEvel:level logStr:__VA_ARGS__,nil]
#define ErrLog(module,...) [[LogManager sharedInstance] logInfo:module LogEvel:ERR_LOG LogFormat:__VA_ARGS__,nil]
#define WarnLog(module,...) [[LogManager sharedInstance] logInfo:module LogEvel:WARN_LOG LogFormat:__VA_ARGS__,nil]
#define InfoLog(module,...) [[LogManager sharedInstance] logInfo:module LogEvel:INFO_LOG LogFormat:__VA_ARGS__,nil]
#define DebugLog(module,...) [[LogManager sharedInstance] logInfo:module LogEvel:DEBUG_LOG LogFormat:__VA_ARGS__,nil]

#endif /* AcmLog_h */
