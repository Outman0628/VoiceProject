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
@property NSString *outputFilePath;
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


+(void)textToAudioFile:(nonnull NSString*) text FilePath:( NSString*_Nullable) filePath VoiceConfig:(nonnull VoiceConfig*) config CallBack:(AcmAssistantTextToAudioBlock _Nonnull ) block{
    [AcmAssistant createInstanceIfNeeded];
    
    if(instance != nil)
    {
        [instance ttsTextToAudioFile:text FilePath:filePath VoiceConfig:config CallBack:block];
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
    NSLog(@"audio file to text");
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
        NSLog(@"file not exist!");
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
-(void)ttsTextToAudioFile:(nonnull NSString*) text FilePath:( NSString*_Nullable) filePath  VoiceConfig:(nonnull VoiceConfig*) config CallBack:(AcmAssistantTextToAudioBlock _Nonnull ) block{
    
    if(self.isWorking)
    {
        if(block != nil){
            block(AssistantSettingBusy,nil);
        }
        
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath])
    {
        if(block != nil){
            block(AssistantFileAlreadyExist,nil);
        }
        return;
    }
    
    self.outputFilePath = filePath;
    
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
                NSString *wavFilePath = [self pcmToWav:filePath];
                
                if(block != nil){
                    if(wavFilePath == nil){
                        block(AssistantErrorTransToWavFileFailed, nil);
                    }else{
                        block(AssistantOK, wavFilePath);
                        
                    }
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

- (NSString *) pcmToWav:(NSString *)filePath
{
    NSString *wavFilePath = nil;
    
    if(self.outputFilePath == nil || _outputFilePath.length == 0){
        wavFilePath = [NSString stringWithFormat:@"%@.wav",filePath];
    }
    else{
        wavFilePath = self.outputFilePath;
    }
    
    
    NSLog(@"PCM file path : %@",filePath); //pcm文件的路径
    
    FILE *fout;
    
    short NumChannels = 1;       //录音通道数
    short BitsPerSample = 16;    //线性采样位数
    int SamplingRate = 16000;     //录音采样率(Hz)
    int numOfSamples = (int)[[NSData dataWithContentsOfFile:filePath] length];
    
    int ByteRate = NumChannels*BitsPerSample*SamplingRate/8;
    short BlockAlign = NumChannels*BitsPerSample/8;
    int DataSize = NumChannels*numOfSamples*BitsPerSample/8;
    int chunkSize = 16;
    int totalSize = 46 + DataSize;
    short audioFormat = 1;
    
    if((fout = fopen([wavFilePath cStringUsingEncoding:1], "w")) == NULL)
    {
        printf("Error opening out file ");
        return nil;
    }
    
    fwrite("RIFF", sizeof(char), 4,fout);
    fwrite(&totalSize, sizeof(int), 1, fout);
    fwrite("WAVE", sizeof(char), 4, fout);
    fwrite("fmt ", sizeof(char), 4, fout);
    fwrite(&chunkSize, sizeof(int),1,fout);
    fwrite(&audioFormat, sizeof(short), 1, fout);
    fwrite(&NumChannels, sizeof(short),1,fout);
    fwrite(&SamplingRate, sizeof(int), 1, fout);
    fwrite(&ByteRate, sizeof(int), 1, fout);
    fwrite(&BlockAlign, sizeof(short), 1, fout);
    fwrite(&BitsPerSample, sizeof(short), 1, fout);
    fwrite("data", sizeof(char), 4, fout);
    fwrite(&DataSize, sizeof(int), 1, fout);
    
    fclose(fout);
    
    NSMutableData *pamdata = [NSMutableData dataWithContentsOfFile:filePath];
    NSFileHandle *handle;
    handle = [NSFileHandle fileHandleForUpdatingAtPath:wavFilePath];
    [handle seekToEndOfFile];
    [handle writeData:pamdata];
    [handle closeFile];
    
    return wavFilePath;
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
