//
//  AcmAssistant.m
//  ACM
//
//  Created by David on 2020/2/19.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "AcmAssistant.h"
#import "../TTS/TtsManager.h"
#import "TtsFileManager.h"
#import "AssistantItem.h"
#import "../Action/ActionManager.h"

#import "VoiceConfig.h"

@interface AcmAssistant()
@property TtsManager *ttsMgr;
@property TtsFileManager *ttsFileMgr;
@property NSMutableArray *speakerCadidates;        // 播报候选人员
@property BOOL isWorking;                          // 是否有转换工作
@end

static AcmAssistant *instance = nil;

@implementation AcmAssistant

+(void)createInstanceIfNeeded{
    if(instance == nil)
    {
        instance = [[AcmAssistant alloc]init];
    }
}

+(NSArray *_Nullable)getCandidates{
    
    [AcmAssistant createInstanceIfNeeded];
    
    if(instance != nil)
    {
        return instance.speakerCadidates;
    }
    return nil;
}


+(void)textToAudioFile:(nonnull NSString*) text  VoiceConfig:(nonnull VoiceConfig*) config CallBack:(AcmAssistantTextToAudioBlock _Nonnull ) block{
    [AcmAssistant createInstanceIfNeeded];
    
    if(instance != nil)
    {
        [instance ttsTextToAudioFile:text VoiceConfig:config CallBack:block];
    }
    else{
        if(block != nil){
            block(AssistantNotInited,nil);
        }
    }
    
}

+ (void) addRobotDialPlan: ( nullable NSDate *)dateTime  PlanId:( NSInteger)planID  CallBack:(AcmAssistantDialPlanBlock _Nonnull ) block{
 
    if(block != nil){
        block(AssistantOK);
    }
}


+ (void) cancelRobotDialPlan: ( NSInteger)planID  CallBack:(AcmAssistantDialPlanBlock _Nonnull ) block{
    if(block != nil){
        block(AssistantOK);
    }
}


+ (void) audioFileToText: (nonnull NSString *)filePath  CallBack:(AcmAssistantAudioToTextBlock _Nonnull ) block{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath])
    {
        [[ActionManager instance].asrMgr audioFileToText:filePath CallBack:^(AudioToFileCode code, NSString * _Nullable text) {
            
                if(block != nil){
                    block(code,text);
                }
            
        }];
    }
    else{
        if(block != nil){
            block(AssistantErrorFileNotExist,nil);
        }
    }
   
}

+ (void) cancelAudioFileToText{
    [[ActionManager instance].asrMgr stopAudioFileToTextTask];
}

-(id _Nullable )init{
    if (self = [super init]) {
        [self initConfiguration];
    }
    return self;
}

-(void) initConfiguration{
    _ttsMgr = [[TtsManager alloc]init];
    _ttsFileMgr = [[TtsFileManager alloc]init];
    _speakerCadidates =[NSMutableArray array];
    
    NSString *BDS_SYNTHESIZER_SPEAKER_FEMALE = @"女声";
    NSString *BDS_SYNTHESIZER_SPEAKER_MALE = @"男声1";
    NSString *BDS_SYNTHESIZER_SPEAKER_MALE_2 = @"男声2";
    NSString *BDS_SYNTHESIZER_SPEAKER_MALE_3 = @"情感男生度逍遥";
    NSString *BDS_SYNTHESIZER_SPEAKER_DYY = @"度丫丫";
    
    [_speakerCadidates addObject:BDS_SYNTHESIZER_SPEAKER_FEMALE];
    [_speakerCadidates addObject:BDS_SYNTHESIZER_SPEAKER_MALE];
    [_speakerCadidates addObject:BDS_SYNTHESIZER_SPEAKER_MALE_2];
    [_speakerCadidates addObject:BDS_SYNTHESIZER_SPEAKER_MALE_3];
    [_speakerCadidates addObject:BDS_SYNTHESIZER_SPEAKER_DYY];
    
    self.isWorking = NO;
}

// 文本转文字
-(void)ttsTextToAudioFile:(nonnull NSString*) text  VoiceConfig:(nonnull VoiceConfig*) config CallBack:(AcmAssistantTextToAudioBlock _Nonnull ) block{
    
    if(self.isWorking)
    {
        if(block != nil){
            block(AssistantSettingBusy,nil);
        }
        
        return;
    }
    
    if([self checkTextToAudioParam:text VoiceConfig:config])
    {
        self.isWorking = YES;
        [_ttsMgr updateTTSConfig:config];
        
        NSMutableArray *contentList = [NSMutableArray array];
        AssistanItem *item = [[AssistanItem alloc] init];
        item.content = text;
        [contentList addObject:item];
        
        
        [_ttsFileMgr prepareVoiceFiles:contentList ttsManager:_ttsMgr Config:config completionBlock:^(AssistantCode code, NSError * _Nullable subCode) {
            
            if(code == AssistantOK){
                NSString *filePath = nil;
                [TtsFileManager generateFileName:text fullName:&filePath Config:config];
                if(block != nil){
                    block(AssistantOK, filePath);
                }
            }
            else
            {
                
                if(block != nil){
                    block(code, nil);
                }
            }
            self.isWorking = NO;
        }];
    }
    else
    {
        if(block != nil){
            block(AssistantErrorParam,nil);
        }
    }
}

-(BOOL)checkTextToAudioParam:(nonnull NSString*) text  VoiceConfig:(nonnull VoiceConfig*) config
{
    if(text == nil || config == nil || text.length == 0)
        return false;
    
    
    if(config.speechVolume > 15 || config.speechVolume < 0 ){
        return false;
    }
    if(config.speechSpeed > 9 || config.speechSpeed < 0){
        return false;
    }
    
    if(config.speechPich > 9 || config.speechPich < 0)
    {
        return false;
    }
    if(config.curSpeakerIndex < 0 || config.curSpeakerIndex >= self.speakerCadidates.count)
    {
        return false;
    }
    
    return YES;
}

@end
