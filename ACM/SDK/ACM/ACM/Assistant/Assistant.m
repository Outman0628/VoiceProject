//
//  Assistant.m
//  ACM
//
//  Created by David on 2020/1/17.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnswerAssistant.h"
#import "Assistant.h"
#import "../TTS/TtsManager.h"
#import "AssistantEnum.h"
#import "../TTS/BDSClientHeaders/TTS/BDSSpeechSynthesizer.h"
#import "AssistantItem.h"
#import "TtsFileManager.h"
#import "AuditTask.h"
#import "UpDateConfigTask.h"

@interface Assistant()
@property AnswerAssistant *answerAss;
@property TtsManager *ttsMgr;
@property TtsFileManager *ttsFileMgr;
@property AuditTask *auditTask;
@property UpDateConfigTask *updateConfigTask;
@property NSMutableArray *speakerCadidates;        // 播报候选人员
@property BOOL isWorking;                          // 是否有转换工作
@end

@implementation Assistant

static Assistant *instance = nil;

+(nullable AnswerAssistant *)getAnswerAsistant{
    [Assistant createInstanceIfNeeded];
    
    if(instance != nil)
    {
        return [instance.answerAss clone];
    }else
    {
        return nil;
    }
    
}


+(void)updateAnswerAssistantParam:(nonnull AnswerAssistant*) answerAssistant completionBlock: (AssistantBlock _Nullable )completionHandler{
    
    [Assistant createInstanceIfNeeded];
    
    if(instance != nil)
    {
        [instance updateAnserAssistant:answerAssistant completionBlock:completionHandler];
    }
    else
    {
        if(completionHandler != nil)
        {
            completionHandler(AssistantNotInited, nil);
        }
    }
    
    
}


+(void)auditionAnswerAssistant:(nonnull AnswerAssistant*) answerAssistant completionBlock: (AssistantBlock _Nullable )completionHandler{
    [Assistant createInstanceIfNeeded];
    
    if(instance != nil)
    {
        [instance auditAnswerAssistant:answerAssistant completionBlock:completionHandler];
    }
}


+(void)cancelAuditionAnswerAssistant:(nonnull AnswerAssistant*) answerAssistant{
    
    [Assistant createInstanceIfNeeded];
    
    if(instance != nil)
    {
        [instance cancelAuditAnswerAssistant:answerAssistant];
    }
}


// 获取音色名称表
 
+(NSArray *_Nullable)getCandidates
{
    [Assistant createInstanceIfNeeded];
    
    if(instance != nil)
    {
        return instance.speakerCadidates;
    }
    return nil;
}

+(void)createInstanceIfNeeded{
    if(instance == nil)
    {
        instance = [[Assistant alloc]init];
    }
}

-(id _Nullable )init{
    if (self = [super init]) {
        [self initConfiguration];
           }
    return self;
}
/*
-(AnswerAssistant *)cloneAnserAssistant:(nonnull AnswerAssistant *)ass{
    AnswerAssistant *clone = nil;
    if(ass != nil)
    {
        clone = [[AnswerAssistant alloc]init];
        clone.speechVolume = ass.speechVolume;
        clone.speechSpeed = ass.speechSpeed;
        clone.speechPich = ass.speechPich;
        clone.curSpeakerIndex = ass.curSpeakerIndex;
        if(ass.contents != nil && ass.contents.count > 0)
        {
            for (int i=0; i<[ass.contents count]; i++) {
                NSObject *item = ass.contents[i];
                
                if([item isMemberOfClass:[AssistanItem class]])
                {
                    
                }
                
            }
        }
    }
    return clone;
}
 */
-(void) initConfiguration{
    _ttsMgr = [[TtsManager alloc]init];
    
    _speakerCadidates =[NSMutableArray array];
    
    NSString *BDS_SYNTHESIZER_SPEAKER_FEMALE = @"女声";
    NSString *BDS_SYNTHESIZER_SPEAKER_MALE = @"男声";
    NSString *BDS_SYNTHESIZER_SPEAKER_MALE_2 = @"男声2";
    NSString *BDS_SYNTHESIZER_SPEAKER_MALE_3 = @"情感男生度逍遥";
    NSString *BDS_SYNTHESIZER_SPEAKER_DYY = @"度丫丫";
    
    [_speakerCadidates addObject:BDS_SYNTHESIZER_SPEAKER_FEMALE];
    [_speakerCadidates addObject:BDS_SYNTHESIZER_SPEAKER_MALE];
    [_speakerCadidates addObject:BDS_SYNTHESIZER_SPEAKER_MALE_2];
    [_speakerCadidates addObject:BDS_SYNTHESIZER_SPEAKER_MALE_3];
    [_speakerCadidates addObject:BDS_SYNTHESIZER_SPEAKER_DYY];
    
    
    // todo read answer ass from the local config file
    _answerAss = [[AnswerAssistant alloc]init];
    
    _ttsFileMgr = [[TtsFileManager alloc]init];
    self.isWorking = NO;
}
// 更新接听配置
-(void)updateAnserAssistant:(nonnull AnswerAssistant*) answerAssistant completionBlock: (AssistantBlock _Nullable )completionHandler{
    
    if([self checkAnswerAssistantParam:answerAssistant])
    {
        AnswerAssistant *updateAss = [answerAssistant clone];
        
        if(updateAss.enable  && updateAss.contents != nil && updateAss.contents.count > 0)
        {
             self.isWorking = YES;
            [_ttsFileMgr prepareVoiceFiles:updateAss.contents ttsManager:_ttsMgr completionBlock:^(AssistantCode code, NSError * _Nullable subCode) {
                
                if(code == AssistantOK){
                    // 获取语音文件成功，继续更新服务器配置
                     NSLog(@"TTS tts files are prepared, is going to update server config");
                    [self updateServerSetting:answerAssistant completionBlock:completionHandler];
                }
                else
                {
                     self.isWorking = NO;
                    completionHandler(code,subCode);
                }
                    
            }];
        }
        else
        {
            [self disableAnswerAssistant:self.answerAss completionBlock:completionHandler];
        }
    }
    else
    {
       if(completionHandler != nil)
       {
           completionHandler(AssistantErrorParam,nil);
       }
    }
}

-(void)updateServerSetting:(nonnull AnswerAssistant*) answerAssistant completionBlock: (AssistantBlock _Nullable )completionHandler{
    _updateConfigTask = [[UpDateConfigTask alloc] init];
    [_updateConfigTask updateConfig:answerAssistant.contents completionBlock:^(AssistantCode code, NSError * _Nullable subCode) {
        self.updateConfigTask = nil;
        self.isWorking = NO;
        if(completionHandler != nil)
        {
            completionHandler(code, subCode);
        }
        
    }];
}

// 试听
-(void)auditAnswerAssistant:(nonnull AnswerAssistant*) answerAssistant completionBlock: (AssistantBlock _Nullable )completionHandler{
    
    if([self checkAnswerAssistantParam:answerAssistant])
    {
        AnswerAssistant *updateAss = [answerAssistant clone];
        
        if( updateAss.contents != nil && updateAss.contents.count > 0)
        {
            self.isWorking = YES;
            [_ttsFileMgr prepareVoiceFiles:updateAss.contents ttsManager:_ttsMgr completionBlock:^(AssistantCode code, NSError * _Nullable subCode) {
                if(code == AssistantOK){
                    // 获取语音文件成功，继续更新服务器配置
                    NSLog(@"TTS tts files are prepared, is going to play them");
                    [self auditAnswerAssistantFiles:answerAssistant completionBlock:^(AssistantCode code, NSError * _Nullable subCode) {
                        self.isWorking = NO;
                        self.auditTask = nil;
                        if(completionHandler != nil)
                        {
                            completionHandler(code, subCode);
                        }
                    }];
                }
                else
                {
                    self.isWorking = NO;
                    completionHandler(code,subCode);
                }
                
            }];
        }
    }
    else
    {
        if(completionHandler != nil)
        {
            completionHandler(AssistantErrorParam,nil);
        }
    }
}

-(void)auditAnswerAssistantFiles:(nonnull AnswerAssistant*) answerAssistant completionBlock: (AssistantBlock _Nullable )completionHandler{
    _auditTask = [[AuditTask alloc]init];
    [_auditTask audit:answerAssistant.contents completionBlock:completionHandler];
}

// 取消试听
-(void)cancelAuditAnswerAssistant:(nonnull AnswerAssistant*) answerAssistant{
    
}


-(BOOL)checkAnswerAssistantParam:(nonnull AnswerAssistant *)ass
{
    if(ass == nil)
        return false;
    
    if(ass.speechVolume > 15 || ass.speechVolume < 0 ){
        return false;
    }
    if(ass.speechSpeed > 9 || ass.speechSpeed < 0){
        return false;
    }
        
    if(ass.speechPich > 9 || ass.speechPich < 0)
    {
        return false;
    }
    if(ass.curSpeakerIndex < 0 || ass.curSpeakerIndex >= self.speakerCadidates.count)
    {
        return false;
    }
    
    // contents 必须是 AssistanItem 类型
    if(ass.contents != nil)
    {
        for (int i=0; i<[ass.contents count]; i++) {
            NSObject *item = ass.contents[i];
            
            if(![item isMemberOfClass:[AssistanItem class]])
            {
                return false;
            }
            
        }
    }
    
    return true;
}

-(void)disableAnswerAssistant:(nonnull AnswerAssistant *)ass completionBlock: (AssistantBlock _Nullable )completionHandler
{
    // todo communicate with server
}
@end
