//
//  HttpUtil.m
//  ACM
//
//  Created by David on 2020/1/29.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpUtil.h"

#import "../Log/AcmLog.h"
#define HTTPUTILTAG  @"HTTP"

@interface HttpUtil()
@end

@implementation HttpUtil

+(void) HttpPost: (nonnull NSString*) stringUrl Param:(nonnull NSString *)param Callback:(HttpResponseCallback _Nullable )completionHandler{
    
    DebugLog(HTTPUTILTAG,@"http post to %@, param:%@",stringUrl,param);
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.timeoutInterval = 5.0;
    
    request.HTTPMethod = @"POST";
    
    request.HTTPBody = [param dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setValue:@"close" forHTTPHeaderField:@"Connection"];
    
    NSURLSession *session = [NSURLSession sharedSession];

    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSInteger code = [(NSHTTPURLResponse *)response statusCode];
        DebugLog(HTTPUTILTAG,@"req:%@ response code:%ld, error:%@", stringUrl, (long)code, error);
        if([(NSHTTPURLResponse *)response statusCode] == 200){
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            DebugLog(HTTPUTILTAG,@"req:%@ Resonpse data:%@", stringUrl, str);
        }
        
        if(completionHandler != nil){
            completionHandler(data, response,error);
        }
    }] resume];
}

@end
