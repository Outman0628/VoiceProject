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

@property AssistantBlock callBack;    // 任务结束回调

-(void) AddTask: (NSInteger) taskId;

-(NSInteger) taskCount;

// return YES 所有task 完成
-(BOOL) TaskFinish: (NSInteger) taskId FinishCode:(AssistantCode)code;

@end

#endif /* TtsFileTasks_h */
