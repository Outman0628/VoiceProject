//
//  AuditTask.m
//  ACM
//
//  Created by David on 2020/1/20.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuditTask.h"
#import "AssistantItem.h"
#import "TtsFileManager.h"
#import <AVFoundation/AVFoundation.h>

#import "../Log/AcmLog.h"
#define AuditTaskTag  @"AuditTask"

@interface  AuditTask() <AVAudioPlayerDelegate>
@property NSMutableArray* auditContent;
@property AssistantBlock callBack;
@property AVAudioPlayer *player;
@property VoiceConfig *voiceConfig;
@end


@implementation AuditTask

-(BOOL )audit: (NSMutableArray *_Nonnull) contents Config:(VoiceConfig *_Nullable)config completionBlock: (AssistantBlock _Nullable )completionHandler{
    
    _callBack = completionHandler;
    _voiceConfig = config;
    
    if(_auditContent == nil && contents != nil && contents.count > 0)
    {
        _auditContent = [NSMutableArray array];
        
        for(int i = 0; i < contents.count; i++)
        {
            AssistanItem *item = [contents[i] clone];
            [_auditContent addObject:item];
            
        }
        
        [self auditItem];
        return YES;
    }
    return NO;
}

-(void)auditItem {
   if(_auditContent.count > 0)
   {
       AssistanItem *item = _auditContent[0];
       [_auditContent removeObject:item];
       if(item.interval > 0)
       {
           // 延时
           [NSTimer scheduledTimerWithTimeInterval:item.interval repeats:NO block:^(NSTimer * _Nonnull timer) {
               [self playContent:item.content];
            }];
       }
       else{
           [self playContent:item.content];
       }
   }else{
       if(_callBack != nil){
           _callBack(AssistantOK, nil);
       }
   }
    
}

-(void)playContent:(nonnull NSString *) content{
    
    dispatch_async(dispatch_get_main_queue(),^{
    NSString *filePath = nil;
    [TtsFileManager generateFileName:content fullName:&filePath Config:_voiceConfig];
    
    if(filePath != nil)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:filePath]){
            
            NSError *error = nil;
            NSURL *urlFile = [NSURL fileURLWithPath:filePath];
            self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:urlFile error:&error];
            self.player.delegate = self;
            
            if (error == nil) {
            
                    BOOL ret = NO;
                    ret = [self.player prepareToPlay];
                    InfoLog(AuditTaskTag,@"play prepareToPlay result:%@", ret ? @"YES" : @"NO");
                    ret = [self.player play];
                    InfoLog(AuditTaskTag,@"play result:%@", ret ? @"YES" : @"NO");
           
            }
            else
            {
                [self auditItem];
            }
        }
        else
        {
            [self auditItem];
        }
    }
    else
    {
        [self auditItem];
    }
         });
}

/////////////////// player delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
     [self auditItem];
}


- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
     [self auditItem];
}

@end
