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

-(void) TaskFinish: (NSInteger) taskId isError:(BOOL)error  errorCode:(NSError * _Nullable) subCode{
    
    NSNumber* doneTask = nil;
    
    if(error){
        
        // TASK 全部完成不用在回调 (比如之前已经出了错)
        if(_convertTaksk.count == 0){
            return;
            
        }
        @synchronized(self) {
            [_convertTaksk removeAllObjects];
        }
        if(self.callBack != nil)
        {
            self.callBack(AssistantErrorConvert, subCode);
        }
    }
    else{
    
        @synchronized(self) {
            
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
        
        if( _convertTaksk.count == 0 && self.callBack != nil)
        {
            self.callBack(AssistantOK, nil);
        }
    }
    
    
}

@end
