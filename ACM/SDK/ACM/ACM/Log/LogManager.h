//
//  LogManager.h
//  ACM
//
//  Created by David on 2020/3/10.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef LogManager_h
#define LogManager_h

#import <Foundation/Foundation.h>

@interface LogManager : NSObject

/**
 *  获取单例实例
 *
 *  @return 单例实例
 */
+ (instancetype) sharedInstance;

/**
 日志相关接口
 @param logLevel 日志等级，参见AcmLogLevel
 */
+ (void) setAcmLogConfig:(NSInteger) logLevel;

#pragma mark - Method

/**
 *  写入日志
 *
 *  @param module 模块名称
 *  @param logLevel 日志等级
 *  @param logFormat 日志格式，与NSString fromat 相同
 */
- (void)logInfo:(NSString*)module LogEvel:(NSInteger)logLevel LogFormat:(NSString*)logFormat, ...;

/**
 *  清空过期的日志
 */
- (void)clearExpiredLog;

/**
 *  检测日志是否需要上传
 */
- (void)checkLogNeedUpload;

@end

#endif /* LogManager_h */
