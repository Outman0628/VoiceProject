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
#import "../Message/HttpUtil.h"
#import "../Action/ActionManager.h"
#import "DialAssistant.h"

@interface VoiceConfig ()

@end

@implementation VoiceConfig

-(id _Nullable )init
{
    if (self = [super init]) {
        self.speechPich = 5;
        self.speechSpeed = 5;
        self.speechVolume = 5;
        self.curSpeakerIndex = 0;
    }
    return self;
}

@end



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

+(void)getAnswerAsistant:(AnswerAssistantBlock _Nonnull ) block{
    [Assistant createInstanceIfNeeded];
    
    if(instance != nil)
    {
        
        [instance getAnswerAsistant:block];
        
    }else if(block != nil)
    {
        block(nil, AssistantNotInited);
    }
    
}


+(void)updateAnswerAssistantParam:(nonnull AnswerAssistant*) answerAssistant  CallBack:(id <AssistantCallBack> _Nullable)delegate{
    
    [Assistant createInstanceIfNeeded];
    
    if(instance != nil)
    {
        [instance updateAnserAssistant:answerAssistant CallBack:delegate];
    }
    else
    {
        if(delegate != nil)
        {
            [delegate updateAnswerAssistantResult:AssistantNotInited Error:nil];
        }
    }
    
    
}


+(void)auditionAnswerAssistant:(nonnull AnswerAssistant*) answerAssistant CallBack:(id <AssistantCallBack> _Nullable)delegate{
    
    [Assistant createInstanceIfNeeded];
    
    if(instance != nil)
    {
        [instance auditAnswerAssistant:answerAssistant CallBack:delegate];
    }
    else
    {
        if(delegate != nil)
        {
            [delegate auditResult:AssistantNotInited Error:nil];
        }
    }
}


+(void)cancelAuditionAnswerAssistant:(nonnull AnswerAssistant*) answerAssistant{
    
    [Assistant createInstanceIfNeeded];
    
    if(instance != nil)
    {
        [instance cancelAuditAnswerAssistant:answerAssistant];
    }
}


+(void)getDialAsistant:(DialAssistantBlock _Nonnull ) block{
    [Assistant createInstanceIfNeeded];
    
    if(instance != nil)
    {
        [instance getDialAssistantsFromServer:block];
    }
}

+(void)updateDialAssistantParam:(nonnull DialAssistant*) dialAssistant  CallBack:(id <AssistantCallBack> _Nullable)delegate{
    [Assistant createInstanceIfNeeded];
    
    if(instance != nil)
    {
        [instance updateDialAssistant:dialAssistant CallBack:delegate];
    }
    else
    {
        if(delegate != nil)
        {
            [delegate updateDialAssistantResult:AssistantNotInited Error:nil];
        }
    }
}


+(void)auditionDialAssistant:(nonnull DialAssistant*) dialAssistant  CallBack:(id <AssistantCallBack> _Nullable)delegate{
    [Assistant createInstanceIfNeeded];
    
    if(instance != nil)
    {
        [instance auditDialAssistant:dialAssistant CallBack:delegate];
    }
    else
    {
        if(delegate != nil)
        {
            [delegate auditResult:AssistantNotInited Error:nil];
        }
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
    NSString *BDS_SYNTHESIZER_SPEAKER_MALE = @"男声1";
    NSString *BDS_SYNTHESIZER_SPEAKER_MALE_2 = @"男声2";
    NSString *BDS_SYNTHESIZER_SPEAKER_MALE_3 = @"情感男生度逍遥";
    NSString *BDS_SYNTHESIZER_SPEAKER_DYY = @"度丫丫";
    
    [_speakerCadidates addObject:BDS_SYNTHESIZER_SPEAKER_FEMALE];
    [_speakerCadidates addObject:BDS_SYNTHESIZER_SPEAKER_MALE];
    [_speakerCadidates addObject:BDS_SYNTHESIZER_SPEAKER_MALE_2];
    [_speakerCadidates addObject:BDS_SYNTHESIZER_SPEAKER_MALE_3];
    [_speakerCadidates addObject:BDS_SYNTHESIZER_SPEAKER_DYY];
    
    
    // todo read answer ass from the local config file
    _answerAss = nil;//[[AnswerAssistant alloc]init];
    
    _ttsFileMgr = [[TtsFileManager alloc]init];
    self.isWorking = NO;
}

-(void)getAnswerAsistant:(AnswerAssistantBlock _Nonnull ) block{
    AnswerAssistant *ass = nil;
    if(instance.answerAss != nil)
    {
        ass = [instance.answerAss clone];
        if(block != nil){
            block(ass,AssistantOK);
        }
    }else{
        [self getAnswerAssistantFromServer:^(AnswerAssistant * _Nullable answerAssistant, AssistantCode code) {
            if(code == AssistantOK && answerAssistant != nil){
                self.answerAss = answerAssistant;
            }
            
            if( block != nil ){
                block(answerAssistant,code);
            }
        }];
    }
    
    
}

-(void)getAnswerAssistantFromServer:(AnswerAssistantBlock _Nonnull ) block{
    
    ActionManager *actionMgr = [ActionManager instance];
    if(actionMgr == nil || actionMgr.userId == nil){
        if(block != nil)
        {
            block(nil, AssistantNotInited);
        }
        return;
    }
    
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",actionMgr.host, AnswerAssistantSettingApi];
    
    
    NSDictionary * phoneCallParam =
    @{@"uid": [ActionManager instance].userId,
      };
    
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:phoneCallParam options:NSJSONWritingPrettyPrinted error:&error];
    NSString *param = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    [HttpUtil HttpPost:stringUrl Param:param Callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if([(NSHTTPURLResponse *)response statusCode] == 200){
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            BOOL ret = dic[@"success"];
            
            if(ret == YES)
            {
                @try{
                    NSArray *assList = dic[@"data"];
                    
                    AnswerAssistant *ansswerAss = [[AnswerAssistant alloc] init];
                    VoiceConfig *voiceConfig = nil;
                    
                    if(assList != nil){
                        for(int i = 0; i < assList.count; i++)
                        {
                            
                            AssistanItem *assItem = [[AssistanItem alloc] init];
                            NSNumber *num = assList[0][@"before_second"];
                            assItem.interval = num.integerValue;
                            assItem.content = assList[0][@"Content"];
                            
                            if(voiceConfig == nil){
                                NSDictionary *configDic = assList[0][@"voiceConfig"];
                                if( configDic != nil ){
                                    voiceConfig = [[VoiceConfig alloc] init];
                                    voiceConfig.speechVolume = ((NSNumber *)configDic[@"speechVolume"]).integerValue;
                                    voiceConfig.speechSpeed = ((NSNumber *)configDic[@"speechSpeed"]).integerValue;
                                    voiceConfig.speechPich = ((NSNumber *)configDic[@"speechPich"]).integerValue;
                                    voiceConfig.curSpeakerIndex = ((NSNumber *)configDic[@"curSpeakerIndex"]).integerValue;
                                    
                                    ansswerAss.config = voiceConfig;
                                }
                            }
                            
                            [ansswerAss.contents addObject:assItem];
                        }
                    }
                    
                    if(block != nil){
                        dispatch_async(dispatch_get_main_queue(),^{
                            block(ansswerAss,AssistantOK);
                        });
                    }
                    
                } @catch (NSException *exception){
                    if(block != nil){
                        dispatch_async(dispatch_get_main_queue(),^{
                            block(nil,AssistantErrorIncorrectAnswerAssistantContent);
                        });
                    }
                }
            }
            else
            {
                // 通知错误发生
                if(block != nil){
                    dispatch_async(dispatch_get_main_queue(),^{
                        block(nil,AssistantErrorIncorrectAnswerAssistantContent);
                    });
                }
            }
        }
        else{
            // 通知错误发生
            if(block != nil){
                dispatch_async(dispatch_get_main_queue(),^{
                    block(nil,AssistantErrorServer);
                });
            }
        }
    }];
    
}

-(void)getDialAssistantsFromServer:(DialAssistantBlock _Nonnull ) block{
    
    NSMutableArray *dialAssList = [NSMutableArray array];
    
    ActionManager *actionMgr = [ActionManager instance];
    if(actionMgr == nil || actionMgr.userId == nil){
        if(block != nil)
        {
            block(nil, AssistantNotInited);
        }
        return;
    }
    
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",actionMgr.host, DialAssistantSettingApi];
    
    
    NSDictionary * phoneCallParam =
    @{@"uid": [ActionManager instance].userId,
      };
    
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:phoneCallParam options:NSJSONWritingPrettyPrinted error:&error];
    NSString *param = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    [HttpUtil HttpPost:stringUrl Param:param Callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if([(NSHTTPURLResponse *)response statusCode] == 200){
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            BOOL ret = dic[@"success"];
            
            if(ret == YES)
            {
                @try{
                    NSDictionary *data = dic[@"data"];
                    if(data != nil){
                        NSArray *rows = data[@"rows"];
                        if(rows != nil){
                            for(int i = 0; i < rows.count; i++){
                                
                                    DialAssistant *daa = [[DialAssistant alloc] init];
                                    daa.assId = rows[i][@"id"];
                                    daa.subscribers = rows[i][@"dst_uid"];
                                    
                                   
                                    //设置转换格式
                                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
                                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                    //NSString转NSDate
                                    daa.dialDateTime=[formatter dateFromString:rows[i][@"call_time"]];
                                    
                                    [self parseToneList:daa ToneList:rows[i][@"tone_list"]];
                                    
                                    [dialAssList addObject:daa];
                                
                            }
                            
                            dispatch_async(dispatch_get_main_queue(),^{
                                block(dialAssList,AssistantOK);
                            });
                            
                        }else{
                            if(block != nil){
                                dispatch_async(dispatch_get_main_queue(),^{
                                    block(nil,AssistantErrorIncorrectDialAssistantContent);
                                });
                            }
                        }
                    }else{
                        if(block != nil){
                            dispatch_async(dispatch_get_main_queue(),^{
                                block(nil,AssistantErrorIncorrectDialAssistantContent);
                            });
                        }
                    }

                } @catch (NSException *exception){
                    if(block != nil){
                        dispatch_async(dispatch_get_main_queue(),^{
                            block(nil,AssistantErrorIncorrectDialAssistantContent);
                        });
                    }
                }
            }
            else
            {
                // 通知错误发生
                if(block != nil){
                    dispatch_async(dispatch_get_main_queue(),^{
                        block(nil,AssistantErrorIncorrectDialAssistantContent);
                    });
                }
            }
        }
        else{
            // 通知错误发生
            if(block != nil){
                dispatch_async(dispatch_get_main_queue(),^{
                    block(nil,AssistantErrorServer);
                });
            }
        }
    }];
    
}

- (void) parseToneList:(DialAssistant *)dAss ToneList:(NSArray *)toneList{
    
    if(toneList != nil && toneList.count > 0)
    {
        VoiceConfig *voiceConfig = nil;
        
            for(int i = 0; i < toneList.count; i++)
            {
                
                AssistanItem *assItem = [[AssistanItem alloc] init];
                NSNumber *num = toneList[0][@"before_second"];
                assItem.interval = num.integerValue;
                assItem.content = toneList[0][@"Content"];
                
                if(voiceConfig == nil){
                    NSDictionary *configDic = toneList[0][@"voiceConfig"];
                    if( configDic != nil ){
                        voiceConfig = [[VoiceConfig alloc] init];
                        voiceConfig.speechVolume = ((NSNumber *)configDic[@"speechVolume"]).integerValue;
                        voiceConfig.speechSpeed = ((NSNumber *)configDic[@"speechSpeed"]).integerValue;
                        voiceConfig.speechPich = ((NSNumber *)configDic[@"speechPich"]).integerValue;
                        voiceConfig.curSpeakerIndex = ((NSNumber *)configDic[@"curSpeakerIndex"]).integerValue;
                        
                        dAss.config = voiceConfig;
                    }
                }
                
                [dAss.contents addObject:assItem];
            }
        }
}

// 更新接听配置
-(void)updateAnserAssistant:(nonnull AnswerAssistant*) answerAssistant CallBack:(id <AssistantCallBack> _Nullable)delegate{
    
    if(self.isWorking)
    {
        if(delegate != nil){
            [delegate updateAnswerAssistantResult:AssistantSettingBusy Error:nil];
        }
        
        return;
    }
    
    if([self checkAnswerAssistantParam:answerAssistant])
    {
        AnswerAssistant *updateAss = [answerAssistant clone];
        
        if(updateAss.enable  && updateAss.contents != nil && updateAss.contents.count > 0)
        {
             self.isWorking = YES;
            [_ttsMgr updateTTSConfig:answerAssistant.config];
            [_ttsFileMgr prepareVoiceFiles:updateAss.contents ttsManager:_ttsMgr Config:answerAssistant.config completionBlock:^(AssistantCode code, NSError * _Nullable subCode) {
                
                if(code == AssistantOK){
                    // 获取语音文件成功，继续更新服务器配置
                     NSLog(@"TTS tts files are prepared, is going to update server config");
                    [self updateAAssServerSetting:answerAssistant completionBlock:^(AssistantCode code, NSError * _Nullable subCode) {
                        if(delegate != nil)
                        {
                            [delegate updateAnswerAssistantResult:code Error:subCode];
                        }
                        self.isWorking = NO;
                        self.updateConfigTask = nil;
                    }];
                }
                else
                {
                    self.isWorking = NO;
                    if(delegate != nil){
                        [delegate updateAnswerAssistantResult:code Error:subCode];
                    }
                }
                    
            }];
        }
        else
        {
            [self disableAnswerAssistant:self.answerAss completionBlock:^(AssistantCode code, NSError * _Nullable subCode) {
                
            }];
        }
    }
    else
    {
        if(delegate != nil){
            [delegate updateAnswerAssistantResult:AssistantErrorParam Error:nil];
        }
    }
}

// 更新拨打计划
-(void)updateDialAssistant:(nonnull DialAssistant*) dialAssistant CallBack:(id <AssistantCallBack> _Nullable)delegate{
    
    if(self.isWorking)
    {
        if(delegate != nil){
            [delegate updateDialAssistantResult:AssistantSettingBusy Error:nil];
        }
        
        return;
    }
    
    if([self checkDialAssistantParam:dialAssistant])
    {
        DialAssistant *updateAss = [dialAssistant copy];
        
        if( updateAss.contents != nil && updateAss.contents.count > 0)
        {
            self.isWorking = YES;
            [_ttsMgr updateTTSConfig:dialAssistant.config];
            [_ttsFileMgr prepareVoiceFiles:updateAss.contents ttsManager:_ttsMgr Config:dialAssistant.config completionBlock:^(AssistantCode code, NSError * _Nullable subCode) {
                
                if(code == AssistantOK){
                    // 获取语音文件成功，继续更新服务器配置
                    NSLog(@"TTS tts files are prepared, is going to update server config");
                    [self updateDAssServerSetting:dialAssistant completionBlock:^(AssistantCode code, NSError * _Nullable subCode) {
                        if(delegate != nil)
                        {
                            [delegate updateDialAssistantResult:code Error:subCode];
                        }
                        self.isWorking = NO;
                        self.updateConfigTask = nil;
                    }];
                }
                else
                {
                    self.isWorking = NO;
                    if(delegate != nil){
                        [delegate updateDialAssistantResult:code Error:subCode];
                    }
                }
                
            }];
        }
        else
        {
            [self disableAnswerAssistant:self.answerAss completionBlock:^(AssistantCode code, NSError * _Nullable subCode) {
                
            }];
        }
    }
    else
    {
        if(delegate != nil){
            [delegate updateDialAssistantResult:AssistantErrorParam Error:nil];
        }
    }
}

-(void)updateAAssServerSetting:(nonnull AnswerAssistant*) answerAssistant completionBlock: (AssistantBlock _Nullable )completionHandler{
    _updateConfigTask = [[UpDateConfigTask alloc] init];
    [_updateConfigTask updateAnswerAssistantConfig:answerAssistant completionBlock:completionHandler];
}

-(void)updateDAssServerSetting:(nonnull DialAssistant*) dialAssistant completionBlock: (AssistantBlock _Nullable )completionHandler{
    _updateConfigTask = [[UpDateConfigTask alloc] init];
    [_updateConfigTask updateDialAssistantConfig:dialAssistant completionBlock:completionHandler];
}

// 试听
-(void)auditAnswerAssistant:(nonnull AnswerAssistant*) answerAssistant CallBack:(id <AssistantCallBack> _Nullable)delegate{
    
    if(self.isWorking)
    {
        if(delegate != nil){
            [delegate auditResult:AssistantSettingBusy Error:nil];
        }
        
        return;
    }
    
    if([self checkAnswerAssistantParam:answerAssistant])
    {
        AnswerAssistant *updateAss = [answerAssistant clone];
        
        if( updateAss.contents != nil && updateAss.contents.count > 0)
        {
            self.isWorking = YES;
            [_ttsMgr updateTTSConfig:answerAssistant.config];
            [_ttsFileMgr prepareVoiceFiles:updateAss.contents ttsManager:_ttsMgr Config:answerAssistant.config completionBlock:^(AssistantCode code, NSError * _Nullable subCode) {
                if(code == AssistantOK){
                    // 获取语音文件成功，继续更新服务器配置
                    NSLog(@"TTS tts files are prepared, is going to play them");
                    [self auditAssistantFiles:answerAssistant.contents VoiceSetting:answerAssistant.config completionBlock:^(AssistantCode code, NSError * _Nullable subCode) {
                        if(delegate != nil)
                        {
                            [delegate auditResult:code Error:subCode];
                        }
                        self.isWorking = NO;
                        self.auditTask = nil;
                    }];
                }
                else
                {
                    self.isWorking = NO;
                    if(delegate != nil)
                    {
                        [delegate auditResult:code Error:subCode];
                    }
                }
                
            }];
        }
    }
    else
    {
        if(delegate != nil)
        {
            [delegate auditResult:AssistantErrorParam Error:nil];
        }
    }
}

// 试听
-(void)auditDialAssistant:(nonnull DialAssistant*) dialAssistant CallBack:(id <AssistantCallBack> _Nullable)delegate{
    
    if(self.isWorking)
    {
        if(delegate != nil){
            [delegate auditResult:AssistantSettingBusy Error:nil];
        }
        
        return;
    }
    
    if([self checkDialAssistantParam:dialAssistant])
    {
        DialAssistant *updateDAss = [dialAssistant copy];
        
        if( updateDAss.contents != nil && updateDAss.contents.count > 0)
        {
            self.isWorking = YES;
            [_ttsMgr updateTTSConfig:dialAssistant.config];
            [_ttsFileMgr prepareVoiceFiles:dialAssistant.contents ttsManager:_ttsMgr Config:dialAssistant.config completionBlock:^(AssistantCode code, NSError * _Nullable subCode) {
                if(code == AssistantOK){
                    // 获取语音文件成功，继续更新服务器配置
                    NSLog(@"TTS tts files are prepared, is going to play them");
                    [self auditAssistantFiles:dialAssistant.contents VoiceSetting:dialAssistant.config completionBlock:^(AssistantCode code, NSError * _Nullable subCode) {
                        if(delegate != nil)
                        {
                            [delegate auditResult:code Error:subCode];
                        }
                        self.isWorking = NO;
                        self.auditTask = nil;
                    }];
                }
                else
                {
                    self.isWorking = NO;
                    if(delegate != nil)
                    {
                        [delegate auditResult:code Error:subCode];
                    }
                }
                
            }];
        }
    }
    else
    {
        if(delegate != nil)
        {
            [delegate auditResult:AssistantErrorParam Error:nil];
        }
    }
}

/*
-(void)auditAnswerAssistantFiles:(nonnull AnswerAssistant*) answerAssistant completionBlock: (AssistantBlock _Nullable )completionHandler{
    _auditTask = [[AuditTask alloc]init];
    [_auditTask audit:answerAssistant.contents  Config:answerAssistant.config completionBlock:completionHandler];
}
 */

-(void)auditAssistantFiles:(nonnull NSMutableArray*) contents VoiceSetting:(VoiceConfig *) config completionBlock: (AssistantBlock _Nullable )completionHandler{
    _auditTask = [[AuditTask alloc]init];
    [_auditTask audit:contents  Config:config completionBlock:completionHandler];
}

// 取消试听
-(void)cancelAuditAnswerAssistant:(nonnull AnswerAssistant*) answerAssistant{
    
}


-(BOOL)checkAnswerAssistantParam:(nonnull AnswerAssistant *)ass
{
    if(ass == nil)
        return false;
    
    if(ass.config.speechVolume > 15 || ass.config.speechVolume < 0 ){
        return false;
    }
    if(ass.config.speechSpeed > 9 || ass.config.speechSpeed < 0){
        return false;
    }
        
    if(ass.config.speechPich > 9 || ass.config.speechPich < 0)
    {
        return false;
    }
    if(ass.config.curSpeakerIndex < 0 || ass.config.curSpeakerIndex >= self.speakerCadidates.count)
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

-(BOOL)checkDialAssistantParam:(nonnull DialAssistant *)ass
{
    if(ass == nil)
        return false;
    
    if(ass.config.speechVolume > 15 || ass.config.speechVolume < 0 ){
        return false;
    }
    if(ass.config.speechSpeed > 9 || ass.config.speechSpeed < 0){
        return false;
    }
    
    if(ass.config.speechPich > 9 || ass.config.speechPich < 0)
    {
        return false;
    }
    if(ass.config.curSpeakerIndex < 0 || ass.config.curSpeakerIndex >= self.speakerCadidates.count)
    {
        return false;
    }
    
    if(ass.dialDateTime == nil ){
        return false;
    }
    
    NSDate *now = [[NSDate alloc] init];
    
    if([now timeIntervalSince1970] > [ass.dialDateTime timeIntervalSince1970] ){
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
