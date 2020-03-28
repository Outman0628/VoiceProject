//
//  AsrManager.m
//  ACM
//
//  Created by David on 2020/1/14.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsrManager.h"
#import "BDSClientHeaders/ASR/BDSEventManager.h"
#import "BDSClientHeaders/ASR/BDSASRDefines.h"
#import "BDSClientHeaders/ASR/BDSASRParameters.h"
#import "ASRInputStream.h"
#import "../Action/ActionManager.h"

#import "../Log/AcmLog.h"
#define AsrMgrTag  @"AsrMgr"

/*
NSString* ASR_APP_ID = @"18259540";
NSString* ASR_API_KEY = @"gDYzkmc12uPVjUK6YLyPGLSC";
NSString* ASR_SECRET_KEY = @"6st1dOmHOrlCmBWKEdgoVwBlrlUxy1v3";
 */

@interface AsrManager() <BDSClientASRDelegate>
@property (strong, nonatomic) BDSEventManager *asrEventManager;
@property NSTimeInterval timestamp;
@property BOOL onAsr;
@property BOOL onFileAsr;
@property AudioFileToTextBlock fileAsrCallback;
@end

@implementation AsrManager


-(id _Nullable )init
{
    if (self = [super init]) {
        
        [self initMgr];
    }
    return self;
}

- (void)initMgr{
    self.asrEventManager = [BDSEventManager createEventManagerWithName:BDS_ASR_NAME];
    InfoLog(AsrMgrTag,@"ASR SDK version: %@", [self.asrEventManager libver]);
    self.onAsr = false;
    self.onFileAsr = false;
    self.fileAsrCallback = nil;
    [self.asrEventManager setDelegate:self];
    [self configVoiceRecognitionClient];
}

- (void)configVoiceRecognitionClient {
    //设置DEBUG_LOG的级别
    //[self.asrEventManager setParameter:@(EVRDebugLogLevelFatal) forKey:BDS_ASR_DEBUG_LOG_LEVEL];
    //配置API_KEY 和 SECRET_KEY 和 APP_ID
    /*
    [self.asrEventManager setParameter:@[ASR_API_KEY, ASR_SECRET_KEY] forKey:BDS_ASR_API_SECRET_KEYS];
    [self.asrEventManager setParameter:ASR_APP_ID forKey:BDS_ASR_OFFLINE_APP_CODE];
     */
    
    [self.asrEventManager setParameter:@[[ActionManager instance].baiduApiKey, [ActionManager instance].baiduSecrectKey] forKey:BDS_ASR_API_SECRET_KEYS];
    [self.asrEventManager setParameter:[ActionManager instance].baiduAppId forKey:BDS_ASR_OFFLINE_APP_CODE];
    
    [self.asrEventManager setParameter:@"1537" forKey:BDS_ASR_PRODUCT_ID];
    
    //配置端点检测（二选一）
    [self configModelVAD];
    //    [self configDNNMFE];
    
    //    [self.asrEventManager setParameter:@"15361" forKey:BDS_ASR_PRODUCT_ID];
    // ---- 语义与标点 -----
    //    [self enableNLU];
    //    [self enablePunctuation];
    // ------------------------
    
    //---- 语音自训练平台 ----
    //        [self configSmartAsr];
}

- (void)configModelVAD {
    NSString *modelVAD_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_basic_model" ofType:@"dat"];
    [self.asrEventManager setParameter:modelVAD_filepath forKey:BDS_ASR_MODEL_VAD_DAT_FILE];
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_MODEL_VAD];
}

- (BOOL)startAsr
{
    
    if(self.onFileAsr){
        self.onFileAsr = false;
        [self.asrEventManager sendCommand:BDS_ASR_CMD_CANCEL];
        if(self.fileAsrCallback != nil){
            dispatch_async(dispatch_get_main_queue(),^{
                self.fileAsrCallback(AudioToFileCodeInterrupt,nil);
            });
        }
    }
    
    if(self.onAsr || self.asrEventManager == nil ){
        return false;
        
    }
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_EARLY_RETURN];
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_LOCAL_VAD];
    self.onAsr = true;
    
    [self repeatAsr];
    
    return true;
}

- (void)stopAsr
{
    if(self.onAsr){
        InfoLog(AsrMgrTag,@"Stop Asr");
        [self.asrEventManager sendCommand:BDS_ASR_CMD_CANCEL];
        self.onAsr = false;
    }
}

- (void)repeatAsr{
    if(self.onAsr)
    {
        DebugLog(AsrMgrTag,@"Asr repeat again");
        ASRInputStream *stream = [[ASRInputStream alloc] init];
        [self.asrEventManager setParameter:stream forKey:BDS_ASR_AUDIO_INPUT_STREAM];
        [self.asrEventManager setParameter:@"" forKey:BDS_ASR_AUDIO_FILE_PATH];
        [self.asrEventManager setDelegate:self];
        [self.asrEventManager sendCommand:BDS_ASR_CMD_START];
    }
}

-(void)audioFileToText:(nonnull NSString*) filePath  CallBack:(AudioFileToTextBlock _Nonnull ) block{
    DebugLog(AsrMgrTag,@"---> audioFileToText");
    if(self.onAsr || self.onFileAsr){
        InfoLog(AsrMgrTag,@"Ass is busy!");
        if(block != nil){
            block(AudioToFileCodeBusy,nil);
        }
        return;
    }
    self.onFileAsr = true;
    self.fileAsrCallback = block;
    [self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_ENABLE_EARLY_RETURN];
    [self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_ENABLE_LOCAL_VAD];
    [self.asrEventManager setParameter:nil forKey:BDS_ASR_AUDIO_INPUT_STREAM];
    [self.asrEventManager setParameter:filePath forKey:BDS_ASR_AUDIO_FILE_PATH];
    [self.asrEventManager setDelegate:self];
    [self.asrEventManager sendCommand:BDS_ASR_CMD_START];
}

-(void)stopAudioFileToTextTask{
    if(self.onFileAsr){
        [self.asrEventManager sendCommand:BDS_ASR_CMD_CANCEL];
    }
}

- (void)VoiceRecognitionClientWorkStatus:(int)workStatus obj:(id)aObj{
    //NSLog(@"---> VoiceRecognitionClientWorkStatus:%d", workStatus);
    switch (workStatus) {
        case EVoiceRecognitionClientWorkStatusNewRecordData: {
            //[self.fileHandler writeData:(NSData *)aObj];
            break;
        }
            
        case EVoiceRecognitionClientWorkStatusStartWorkIng: {
            /*
            NSDictionary *logDic = [self parseLogToDic:aObj];
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: start vr, log: %@\n", logDic]];
            [self onStartWorking];
             */
            break;
        }
        case EVoiceRecognitionClientWorkStatusStart: {
            
            //[self printLogTextView:@"CALLBACK: detect voice start point.\n"];
            DebugLog(AsrMgrTag,@"ASR detect voice start point");
            NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
            self.timestamp=[dat timeIntervalSince1970];
            break;
        }
        case EVoiceRecognitionClientWorkStatusEnd: {
            //[self printLogTextView:@"CALLBACK: detect voice end point.\n"];
            DebugLog(AsrMgrTag,@"ASR detect voice end point");
            break;
        }
        case EVoiceRecognitionClientWorkStatusFlushData: {
            //[self printLogTextView:[NSString stringWithFormat:@"CALLBACK: partial result - %@.\n\n", [self getDescriptionForDic:aObj]]];
            
            if(self.onFileAsr)
            {
                break;
            }
            
            @try
            {
                NSDictionary *retDic = aObj;
                if(retDic != nil && retDic[@"results_recognition"])
                {
                    NSArray *array = retDic[@"results_recognition"];
                    NSString *result = nil;
                    if(array && array.count > 0)
                    {
                        result = array[0];
                    }
                   // NSString *result =  [self getDescriptionForDic:retDic[@"results_recognition"]];
                    
                    
                    if(result != nil && result.length > 0)
                    {
                        EventData asrData = {EventASRRealTimeResult,0,0,self.timestamp,result};
                        dispatch_async(dispatch_get_main_queue(),^{
                            [[ActionManager instance] HandleEvent:asrData];
                        });
                    }
                }
            }
            @catch(NSException *exception)
            {
                ErrLog(AsrMgrTag,@"Asr error Parse flush data failed!");
            }
            break;
        }
        case EVoiceRecognitionClientWorkStatusFinish: {
            @try
            {
                if(self.onFileAsr){
                    NSString *result = nil;
                    NSDictionary *retDic = aObj;
                    if(retDic != nil && retDic[@"results_recognition"])
                    {
                        NSArray *array = retDic[@"results_recognition"];
                        
                        if(array && array.count > 0)
                        {
                            result = array[0];
                        }
                    }
                    
                    if(self.fileAsrCallback != nil){
                        dispatch_async(dispatch_get_main_queue(),^{
                            self.fileAsrCallback(AudioToFileCodeOK,result);
                        });
                    }
                    
                    self.onFileAsr = NO;
                    
                }else{
                    NSDictionary *retDic = aObj;
                    if(retDic != nil && retDic[@"results_recognition"])
                    {
                        NSArray *array = retDic[@"results_recognition"];
                        NSString *result = nil;
                        if(array && array.count > 0)
                        {
                            result = array[0];
                        }
                        // NSString *result =  [self getDescriptionForDic:retDic[@"results_recognition"]];
                        
                        if(result != nil && result.length > 0)
                        {
                            NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
                            NSTimeInterval endTimestamp =[dat timeIntervalSince1970];
                            
                            EventData asrData = {EventASRFinalResult,0,0,self.timestamp,result,0,0,0,0,endTimestamp};
                            dispatch_async(dispatch_get_main_queue(),^{
                                [[ActionManager instance] HandleEvent:asrData];
                            });
                        }
                    }
                    
                }
            }
            @catch(NSException *exception)
            {
                ErrLog(AsrMgrTag,@"Asr error Parse flush data failed!");
            }
            [self repeatAsr];
            break;
        }
        case EVoiceRecognitionClientWorkStatusMeterLevel: {
            break;
        }
        case EVoiceRecognitionClientWorkStatusCancel: {
            /*
            [self printLogTextView:@"CALLBACK: user press cancel.\n"];
            [self onEnd];
             */
            
            if( self.onFileAsr ){
                if(self.fileAsrCallback != nil){
                    dispatch_async(dispatch_get_main_queue(),^{
                        self.fileAsrCallback(AudioToFileCodeCancel,nil);
                    });
                }
                
                self.onFileAsr = false;
            }
            
            [self repeatAsr];
            break;
        }
        case EVoiceRecognitionClientWorkStatusError: {
            /*
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: encount error - %@.\n", (NSError *)aObj]];
            [self onEnd];
             */
            ErrLog(AsrMgrTag,@"ASR error:%@", [NSString stringWithFormat:@"CALLBACK: encount error - %@.\n", (NSError *)aObj]);
            if( self.onFileAsr ){
                if(self.fileAsrCallback != nil){
                    dispatch_async(dispatch_get_main_queue(),^{
                        self.fileAsrCallback(AudioToFileCodeError,nil);
                    });
                }
                
                self.onFileAsr = false;
            }
            [self repeatAsr];
            break;
        }
        case EVoiceRecognitionClientWorkStatusLoaded: {
            //[self printLogTextView:@"CALLBACK: offline engine loaded.\n"];
            InfoLog(AsrMgrTag,@"ASRoffline engine loaded");
            break;
        }
        case EVoiceRecognitionClientWorkStatusUnLoaded: {
            //[self printLogTextView:@"CALLBACK: offline engine unLoaded.\n"];
            InfoLog(AsrMgrTag, @"ASRoffline engine unloaded");
            break;
        }
        case EVoiceRecognitionClientWorkStatusChunkThirdData: {
            //[self printLogTextView:[NSString stringWithFormat:@"CALLBACK: Chunk 3-party data length: %lu\n", (unsigned long)[(NSData *)aObj length]]];
            break;
        }
        case EVoiceRecognitionClientWorkStatusChunkNlu: {
           // NSString *nlu = [[NSString alloc] initWithData:(NSData *)aObj encoding:NSUTF8StringEncoding];
            //[self printLogTextView:[NSString stringWithFormat:@"CALLBACK: Chunk NLU data: %@\n", nlu]];
            //NSLog(@"%@", nlu);
            break;
        }
        case EVoiceRecognitionClientWorkStatusChunkEnd: {
           /*
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK: Chunk end, sn: %@.\n", aObj]];
            if (!self.longSpeechFlag) {
                [self onEnd];
            }
            */
            break;
        }
        case EVoiceRecognitionClientWorkStatusFeedback: {
            /*
            NSDictionary *logDic = [self parseLogToDic:aObj];
            [self printLogTextView:[NSString stringWithFormat:@"CALLBACK Feedback: %@\n", logDic]];
            */
             break;
        }
        case EVoiceRecognitionClientWorkStatusRecorderEnd: {
            //[self printLogTextView:@"CALLBACK: recorder closed.\n"];
            break;
        }
        case EVoiceRecognitionClientWorkStatusLongSpeechEnd: {
            /*
            [self printLogTextView:@"CALLBACK: Long Speech end.\n"];
            [self onEnd];
             */
            break;
        }
        default:
            break;
    }
}

- (NSString *)getDescriptionForDic:(NSDictionary *)dic {
    if (dic) {
        return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic
                                                                              options:NSJSONWritingPrettyPrinted
                                                                                error:nil] encoding:NSUTF8StringEncoding];
    }
    return nil;
}
@end
