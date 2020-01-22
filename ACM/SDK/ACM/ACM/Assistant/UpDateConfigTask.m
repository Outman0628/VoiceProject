//
//  UpDateConfigTask.m
//  ACM
//
//  Created by David on 2020/1/20.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpDateConfigTask.h"
#import "AssistantItem.h"
#import "../Action/ActionManager.h"
#import "TtsFileManager.h"



@interface  UpDateConfigTask()
@property NSMutableArray* updateItems;
@property AssistantBlock callBack;
@property NSMutableArray *updatedContents;   // 上传完成后对象
@property VoiceConfig *voiceConfig;
@end

static NSString *FileUploadApi = @"/d/upload";
static NSString *UpdateAnswerAssistantApi = @"/dapi/account/reject-tone";

@implementation UpDateConfigTask

#define HTTP_CONTENT_BOUNDARY @"WANPUSH"

-(BOOL )updateConfig: (NSMutableArray *_Nonnull) contents Config:(VoiceConfig *)config completionBlock: (AssistantBlock _Nullable )completionHandler{
    
    _voiceConfig = config;
    _callBack = completionHandler;
    
    if(_updateItems == nil && contents != nil && contents.count > 0)
    {
        _updateItems = [NSMutableArray array];
        _updatedContents = [NSMutableArray array];
        
        for(int i = 0; i < contents.count; i++)
        {
            AssistanItem *item = [contents[i] clone];
            [_updateItems addObject:item];
            
        }
        
        [self UploadFiles];
        return YES;
    }
    
    return NO;
}

-(void)UploadFiles{
    if(_updateItems.count > 0)
    {
        AssistanItem *item = _updateItems[0];
        [_updateItems removeObject:item];
        
        ActionManager *actionMgr = [ActionManager instance];
        if(actionMgr == nil || actionMgr.userId == nil)
        {
            if(self.callBack != nil)
            {
                self.callBack(AssistantNotInited, nil);
            }
        }
        else{
            NSString *filePath = nil;
            [TtsFileManager generateFileName:item.content fullName:&filePath Config:_voiceConfig];
            
            
            NSString *stringUrl = [NSString stringWithFormat:@"%@%@",actionMgr.host, FileUploadApi];
            //[self httpUploadFile:stringUrl FilePath:filePath DataType:@"multipart/form-data"];
            [self httpUploadFile:stringUrl FilePath:filePath DataType:@"audio/mpeg" AssistantItem:item];
            
        }
    }
    else{
        //  上传完成，更新配置
        [self UpdateAnswerAssistantConfig];
    }
}

-(void)uploadFailed:(NSError *)error{
    
    [_updateItems removeAllObjects];
    
    if(self.callBack != nil)
    {
        dispatch_async(dispatch_get_main_queue(),^{
            self.callBack(AssistantErrorUdateSeverTTSfile, error);
        });
    }
                   
}

-(void)configFailed:(NSError *)error{
    
    [_updateItems removeAllObjects];
    
    if(self.callBack != nil)
    {
        dispatch_async(dispatch_get_main_queue(),^{
            self.callBack(AssistantErrorUdateSeverAssConfig, error);
        });
    }
}

-(void)configDone{
    
    if(self.callBack != nil)
    {
        dispatch_async(dispatch_get_main_queue(),^{
            self.callBack(AssistantOK, nil);});
    }
}

-(void)httpUploadFile:(NSString*)strUrl FilePath:(NSString*)filePath  DataType:(NSString*)dataType AssistantItem:(AssistanItem *)item{
   
    NSURL* url = [NSURL URLWithString:strUrl];
    NSString* fileName = [filePath lastPathComponent];

    
    
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    
    NSString* strBodyBegin = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n", HTTP_CONTENT_BOUNDARY, @"dataFile",  fileName, dataType];
    NSString* strBodyEnd = [NSString stringWithFormat:@"\r\n--%@--\r\n",HTTP_CONTENT_BOUNDARY];
    
    NSMutableData *httpBody = [NSMutableData data];
    [httpBody appendData:[strBodyBegin dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:data];
    [httpBody appendData:[strBodyEnd dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest* httpPutRequest = [[NSMutableURLRequest alloc] init];
    [httpPutRequest setURL:url];
    [httpPutRequest setHTTPMethod:@"POST"];
    [httpPutRequest setTimeoutInterval: 60000];
    [httpPutRequest setValue:[NSString stringWithFormat:@"%@", @(httpBody.length)] forHTTPHeaderField:@"Content-Length"];
    [httpPutRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",HTTP_CONTENT_BOUNDARY] forHTTPHeaderField:@"Content-Type"];
    httpPutRequest.HTTPBody = httpBody;
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:httpPutRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSInteger code = [(NSHTTPURLResponse *)response statusCode];
        NSLog(@"response code:%ldd", (long)code);
        
        if([(NSHTTPURLResponse *)response statusCode] == 200){
            
            if(!error) {
                NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
                NSArray *retFile = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                if(retFile != nil && retFile.count > 0)
                {
                   
                    NSString *fileName = retFile[0];
                    if(fileName != nil && fileName.length > 0){
                        // 添加文件记录
                        NSMutableDictionary *updatedContentItem = [[NSMutableDictionary alloc] initWithObjects:@[fileName, [NSNumber numberWithInteger:item.interval], item.content] forKeys:@[@"url", @"before_second", @"Content"]];
                        
                        [self.updatedContents addObject:updatedContentItem];
                        [self UploadFiles];
                        
                    }else{
                        NSLog(@"TTS error update tts file to server failed!");
                        [self uploadFailed:error];
                    }
                    
                }else{
                    NSLog(@"TTS error update tts file to server failed!");
                    [self uploadFailed:error];
                }
                
            } else {
                
                NSLog(@"TTS error update tts file to server failed!");
                [self uploadFailed:error];
            }
        }
        else{
            NSLog(@"TTS error server error!");
            [self uploadFailed:error];
        }
    }];
    [dataTask resume];
}


- (void) UpdateAnswerAssistantConfig{
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, UpdateAnswerAssistantApi];
    
    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithObjects:@[[ActionManager instance].userId, _updatedContents] forKeys:@[@"uid", @"tone_list"]];
    
    NSError *error;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:config options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.timeoutInterval = 5.0;
    
    request.HTTPMethod = @"POST";
    
    NSString *bodyString = jsonStr; //带一个参数key传给服务器
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger code = [(NSHTTPURLResponse *)response statusCode];
        NSLog(@"response code:%ldd", (long)code);
        if([(NSHTTPURLResponse *)response statusCode] == 200){
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            BOOL ret = dic[@"success"];
            
            
            if(ret == YES)
            {
                [self configDone];
            }
            else
            {

                [self configFailed:nil];
            }
        }
        else{
            [self configFailed:error];
        }
    }] resume];
}

@end
