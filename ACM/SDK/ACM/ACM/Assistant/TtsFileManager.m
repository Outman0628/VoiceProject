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
@property NSMutableArray *ttsConvertTasks;
@property NSInteger maxCachedFilesCount;
@end


@implementation TtsFileManager

+(nullable NSString *)generateFileName:(nonnull NSString*) content  fullName:(NSString**)filePath{
    if(content == nil || content.length == 0)
    {
        return nil;
    }
    
    NSString *fileName = [NSString stringWithFormat:@"ttsvoice_%lu.mp3",(unsigned long)[content hash]];
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *path = [documentPath stringByAppendingPathComponent:fileName];
    *filePath = path;
    return fileName;
}

-(id _Nullable )init{
    if (self = [super init]) {
        _maxCachedFilesCount = 30;
        _cachFiles = [NSMutableArray array];
        _ttsConvertTasks = [NSMutableArray array];
    }
    return self;
}

-(void)prepareVoiceFiles:(nonnull NSArray *) contents ttsManager:(nonnull TtsManager *)ttsMgr completionBlock: (AssistantBlock _Nullable )completionHandler{
    
    TtsFileTasks *task = [[TtsFileTasks alloc] init];
    task.callBack = ^(AssistantCode code, NSError * _Nullable subCode) {        
        [self updateCacheFiles:contents];
        if(completionHandler != nil){
            completionHandler(code,subCode);
        }
    };
    //completionHandler;
    
    if( contents != nil && contents.count > 0 )
    {
        for (int i=0; i<[contents count]; i++) {
            AssistanItem *item = contents[i];
            
            NSString *filePath = nil;
            
            
            //NSString *fName = [NSString stringWithFormat:@"ttsvoice_%lu.mp3",(unsigned long)[item.content hash]];
            
            NSString *fName = [TtsFileManager generateFileName:item.content fullName:&filePath];
            
            if(![self isFileCached:fName])
            {
               
                NSError* err = nil;
                NSInteger taskId = [ttsMgr SynthesizeTTsText: item.content fileName:fName ttsTask:task withError:&err];
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
        else{
            [_ttsConvertTasks addObject:task];
        }
    }
    else
    {
        completionHandler(AssistantErrorParam, nil);
    }
}

-(void) updateCacheFiles:(nonnull NSArray *) contents{
    if( contents != nil && contents.count > 0 )
    {
        for (int i=0; i<[contents count]; i++) {
            AssistanItem *item = contents[i];
            if(![self isFileCached:item.content])
            {
               
                //NSString *fName = [NSString stringWithFormat:@"ttsvoice_%lu.mp3",(unsigned long)[item.content hash]];
                NSString *filePath = nil;
                
                NSString *fName = [TtsFileManager generateFileName:item.content fullName:&filePath];
                
                [_cachFiles addObject:fName];
                if(_cachFiles.count > _maxCachedFilesCount)
                {
                    NSString *dropFile = _cachFiles[0];
                    [_cachFiles removeObject:dropFile];
                    [self removeFile:dropFile];
                }
            }
        }
        
       
    }
}

-(BOOL) isFileCached:(nonnull NSString *)fName{
    for (int i=0; i<[_cachFiles count]; i++) {
        NSString *fileName = _cachFiles[i];
        if([fileName isEqualToString: fName]){
            return YES;
        }
    }
    
    // 如果没有换成则删除可能零时生成的文件
    [self removeFile:fName];
    
    return NO;
}

-(void) removeFile:(nonnull NSString *)fileName{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath])
    {
        NSError *err;
        [fileManager removeItemAtPath:filePath error:&err];
    }
}

@end
