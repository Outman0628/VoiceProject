//
//  TtsFileTasks.h
//  ACM
//
//  Created by David on 2020/1/18.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef TtsFileTasks_h
#define TtsFileTasks_h

#import "Assistant.h"

@interface TtsFileTasks : NSObject

@property AssistantBlock _Nullable callBack;    // 任务结束回调

-(void) AddTask: (NSInteger) taskId;

-(NSInteger) taskCount;

-(void) TaskFinish: (NSInteger) taskId isError:(BOOL)error  errorCode:(NSError * _Nullable) subCode;

@end

#endif /* TtsFileTasks_h */
