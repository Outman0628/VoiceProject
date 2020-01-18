//
//  TtsFileManager.m
//  ACM
//
//  Created by David on 2020/1/17.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TtsFileManager.h"
#import "AssistantItem.h"
#import "../TTS/TtsManager.h"
#import "TtsFileTasks.h"

@interface TtsFileManager()
@property NSMutableArray *cachFiles;
@end


@implementation TtsFileManager

-(id _Nullable )init{
    if (self = [super init]) {
        _cachFiles = [NSMutableArray array];
    }
    return self;
}

-(void)prepareVoiceFiles:(nonnull NSArray *) contents ttsManager:(nonnull TtsManager *)ttsMgr completionBlock: (AssistantBlock _Nullable )completionHandler{
    
    TtsFileTasks *task = [[TtsFileTasks alloc] init];
    task.callBack = completionHandler;
    
    if( contents != nil && contents.count > 0 )
    {
        for (int i=0; i<[contents count]; i++) {
            AssistanItem *item = contents[i];
            if(![self isFileCached:item.content])
            {
               NSError* err = nil;
                NSInteger taskId = [ttsMgr SynthesizeTTsText: contents[i] withError:&err];
                if(err != nil){
                    if(completionHandler != nil){
                        completionHandler(AssistantErrorCreatConverter, err);
                        return;
                    }
                }
                
                [task AddTask:taskId];
            }
        }
        
        // 当前文件全部有本地缓存
        if(task.taskCount == 0)
        {
            completionHandler(AssistantOK,nil);
        }
    }
    else
    {
        completionHandler(AssistantErrorParam, nil);
    }
}

-(BOOL) isFileCached:(nonnull NSString *)content{
    for (int i=0; i<[_cachFiles count]; i++) {
        NSString *fileName = _cachFiles[i];
        if([fileName isEqualToString: [NSString stringWithFormat:@"%lu",(unsigned long)[content hash]]]){
            return YES;
        }
    }
    return NO;
}

@end
