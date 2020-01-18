//
//  TtsFileTasks.m
//  ACM
//
//  Created by David on 2020/1/18.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TtsFileTasks.h"

@interface TtsFileTasks()
@property NSMutableArray *convertTaksk;     // 转换任务id, NSNumber (int)

@end

@implementation TtsFileTasks

-(id _Nullable )init
{
    if (self = [super init]) {
        
        self.convertTaksk = [NSMutableArray array];
    }
    return self;
}

-(void) AddTask: (NSInteger) taskId{
    //NSNumber* intNumber=[NSNumber numberWithInt:10];
    @synchronized(self) {
        for (int i=0; i<[_convertTaksk count]; i++) {
            NSNumber* num = _convertTaksk[i];
            if( num.integerValue == taskId )
            {
                return;
            }
        }
    
    
        NSNumber* intNumber=[NSNumber numberWithInteger:taskId];
        [_convertTaksk addObject:intNumber];
    }
}

-(NSInteger) taskCount
{
    return _convertTaksk.count;
}

-(BOOL) TaskFinish: (NSInteger) taskId FinishCode:(AssistantCode)code{
    @synchronized(self) {
        NSNumber* doneTask = nil;
        for (int i=0; i<[_convertTaksk count]; i++) {
            NSNumber* num = _convertTaksk[i];
            if( num.integerValue == taskId )
            {
                doneTask = num;
                break;
            }
        }
        
        if(doneTask != nil){
            [_convertTaksk removeObject:doneTask];
        }
    }
    
    return _convertTaksk.count == 0;
}

@end
