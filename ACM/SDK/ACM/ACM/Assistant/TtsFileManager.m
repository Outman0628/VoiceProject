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
#import <CommonCrypto/CommonDigest.h>

#define EnableFileCache

@interface TtsFileManager()
#ifdef EnableFileCache
@property NSMutableArray *cachFiles;
@property NSInteger maxCachedFilesCount;
#endif
@property NSMutableArray *ttsConvertTasks;
@end


@implementation TtsFileManager

+(nullable NSString *)generateFileName:(nonnull NSString*) content  fullName:(NSString**)filePath Config:(VoiceConfig *_Nullable)config{
    if(content == nil || content.length == 0)
    {
        return nil;
    }
    
    NSString *fileNameHashString = [NSString stringWithFormat:@"speechVolume:%ld speechSpeed:%ld speechPich:%ld curSpeakerIndex:%ld content:%@", (long)config.speechVolume, (long)config.speechSpeed, (long)config.speechPich, config.curSpeakerIndex, content];
    
    NSString *sha1 = [TtsFileManager sha1:fileNameHashString];
    NSString *md5 = [TtsFileManager md5:fileNameHashString];
    
    NSString *fileName = [NSString stringWithFormat:@"ttsvoice_%@%@.pcm",sha1,md5];
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *path = [documentPath stringByAppendingPathComponent:fileName];
    *filePath = path;
    return fileName;
}

+(NSString*_Nullable) sha1:(NSString*_Nullable)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+(NSString *_Nullable) md5:(NSString *_Nullable) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

-(id _Nullable )init{
    if (self = [super init]) {
#ifdef EnableFileCache
        _maxCachedFilesCount = 30;
        _cachFiles = [NSMutableArray array];
#endif
        _ttsConvertTasks = [NSMutableArray array];
    }
    return self;
}

-(void)prepareVoiceFiles:(nonnull NSArray *) contents ttsManager:(nonnull TtsManager *)ttsMgr Config:(VoiceConfig *_Nullable)config completionBlock: (AssistantBlock _Nullable )completionHandler{
    
    TtsFileTasks *task = [[TtsFileTasks alloc] init];
    task.callBack = ^(AssistantCode code, NSError * _Nullable subCode) {
        #ifdef EnableFileCache
        [self updateCacheFiles:contents Config:config];
        #endif
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
            
            NSString *fName = [TtsFileManager generateFileName:item.content fullName:&filePath Config:config];
#ifdef EnableFileCache
            if(![self isFileCached:fName])
#else
            if(![self isFileExist:fName])
#endif
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

#ifdef EnableFileCache
-(void) updateCacheFiles:(nonnull NSArray *) contents Config:(VoiceConfig *_Nullable)config{
    if( contents != nil && contents.count > 0 )
    {
        for (int i=0; i<[contents count]; i++) {
            AssistanItem *item = contents[i];
            if(![self isFileCached:item.content])
            {
               
                //NSString *fName = [NSString stringWithFormat:@"ttsvoice_%lu.mp3",(unsigned long)[item.content hash]];
                NSString *filePath = nil;
                
                NSString *fName = [TtsFileManager generateFileName:item.content fullName:&filePath Config:config];
                
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
        if([fileName isEqualToString: fName]  && [self isFileExist:fName]){
            return YES;
        }
    }
    
    // 如果没有换成则删除可能零时生成的文件
    [self removeFile:fName];
    
    return NO;
}
#endif

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

- (BOOL) isFileExist:(nonnull NSString *)fileName{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath])
    {
        return YES;
    }
    return  NO;
}

@end
