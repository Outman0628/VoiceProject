//
//  TtsManager.m
//  ACM
//
//  Created by David on 2020/1/17.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TtsManager.h"
#import "BDSClientHeaders/TTS/BDSSpeechSynthesizer.h"
#import <AVFoundation/AVFoundation.h>

NSString* APP_ID = @"18259540";
NSString* API_KEY = @"gDYzkmc12uPVjUK6YLyPGLSC";
NSString* SECRET_KEY = @"6st1dOmHOrlCmBWKEdgoVwBlrlUxy1v3";

@interface  TtsManager() <BDSSpeechSynthesizerDelegate>
@property BOOL isSpeek;
@property (nonatomic,strong)NSMutableArray* synthesisTexts;
@end

@implementation TtsManager

-(id _Nullable )init
{
    if (self = [super init]) {
        
        [self initMgr];
    }
    return self;
}

- (void)initMgr{
    _isSpeek = YES;
    [self configureSDK];
    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(BDS_SYNTHESIZER_AUDIO_ENCODE_MP3_8K) forKey:BDS_SYNTHESIZER_PARAM_AUDIO_ENCODING];
    
    self.synthesisTexts = [[NSMutableArray alloc] init];
}




-(void)configureSDK{
    NSLog(@"TTS version info: %@", [BDSSpeechSynthesizer version]);
    [BDSSpeechSynthesizer setLogLevel:BDS_PUBLIC_LOG_VERBOSE];
    [[BDSSpeechSynthesizer sharedInstance] setSynthesizerDelegate:self];
    [self configureOnlineTTS];
    //[self configureOfflineTTS];
    
}

-(void)configureOnlineTTS{
    
    [[BDSSpeechSynthesizer sharedInstance] setApiKey:API_KEY withSecretKey:SECRET_KEY];
    
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(BDS_SYNTHESIZER_SPEAKER_FEMALE) forKey:BDS_SYNTHESIZER_PARAM_SPEAKER];
    //    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(10) forKey:BDS_SYNTHESIZER_PARAM_ONLINE_REQUEST_TIMEOUT];
    
}

- (void)SynthesizeText:(nonnull NSString *)text {
        NSInteger sentenceID;
        NSError* err = nil;
    
        NSAttributedString* string = [[NSAttributedString alloc] initWithString:text];
    
        if(_isSpeek)
            sentenceID = [[BDSSpeechSynthesizer sharedInstance] speakSentence:[string string] withError:&err];
        else
            sentenceID = [[BDSSpeechSynthesizer sharedInstance] synthesizeSentence:[string string] withError:&err];
        if(err == nil){
            NSMutableDictionary *addedString = [[NSMutableDictionary alloc] initWithObjects:@[string, [NSNumber numberWithInteger:sentenceID], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0]] forKeys:@[@"TEXT", @"ID", @"SPEAK_LEN", @"SYNTH_LEN"]];
            [self.synthesisTexts addObject:addedString];
           // [self updateSynthProgress];
        }
        else{
            NSLog(@"TTS add sentence error:%@",err);
        }
    }

- (NSInteger)SynthesizeTTsText:(nonnull NSString *)text withError:(NSError**)err{
    NSInteger sentenceID;
   // NSError* err = nil;
    
    NSAttributedString* string = [[NSAttributedString alloc] initWithString:text];
    
    if(_isSpeek)
        sentenceID = [[BDSSpeechSynthesizer sharedInstance] speakSentence:[string string] withError:err];
    else
        sentenceID = [[BDSSpeechSynthesizer sharedInstance] synthesizeSentence:[string string] withError:err];
    if(err == nil){
        NSMutableDictionary *addedString = [[NSMutableDictionary alloc] initWithObjects:@[string, [NSNumber numberWithInteger:sentenceID], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0]] forKeys:@[@"TEXT", @"ID", @"SPEAK_LEN", @"SYNTH_LEN"]];
        [self.synthesisTexts addObject:addedString];
        // [self updateSynthProgress];
    }
    else{
        NSLog(@"TTS add sentence error:%@",*err);
    }
    
    return sentenceID;
}

// 取消TTS任务
- (void)cancel{
    if(self.synthesisTexts.count > 0)
    {
        [[BDSSpeechSynthesizer sharedInstance] cancel];
        [self.synthesisTexts removeAllObjects];
    }
}

#pragma mark - implement BDSSpeechSynthesizerDelegate
- (void)synthesizerStartWorkingSentence:(NSInteger)SynthesizeSentence{
    NSLog(@"TTS Did start synth %ld", SynthesizeSentence);
}

- (void)synthesizerFinishWorkingSentence:(NSInteger)SynthesizeSentence{
    NSLog(@"TTS Did finish synth, %ld", SynthesizeSentence);
    if(!_isSpeek){
        if(self.synthesisTexts.count > 0 &&
           SynthesizeSentence == [[[self.synthesisTexts objectAtIndex:0] objectForKey:@"ID"] integerValue]){
            [self.synthesisTexts removeObjectAtIndex:0];
        }
        else{
            NSLog(@"TTS Sentence ID mismatch??? received ID: %ld\nKnown sentences:", (long)SynthesizeSentence);
            /*
            for(NSDictionary* dict in self.synthesisTexts){
                NSLog(@"ID: %ld Text:\"%@\"", [[dict objectForKey:@"ID"] integerValue], [((NSAttributedString*)[dict objectForKey:@"TEXT"]) string]);
            }
             */
        }
    }
}

- (void)synthesizerSpeechStartSentence:(NSInteger)SpeakSentence{
    NSLog(@"TTS Did start speak %ld", SpeakSentence);
}

- (void)synthesizerSpeechEndSentence:(NSInteger)SpeakSentence{
    NSLog(@"TTS Did end speak %ld", SpeakSentence);
    if(self.synthesisTexts.count > 0 &&
       SpeakSentence == [[[self.synthesisTexts objectAtIndex:0] objectForKey:@"ID"] integerValue]){
        [self.synthesisTexts removeObjectAtIndex:0];
    }
    else{
        NSLog(@"TTS Sentence ID mismatch??? received ID: %ld\nKnown sentences:", (long)SpeakSentence);
    }
}

- (void)synthesizerNewDataArrived:(NSData *)newData
                       DataFormat:(BDSAudioFormat)fmt
                   characterCount:(int)newLength
                   sentenceNumber:(NSInteger)SynthesizeSentence{
    NSLog(@"TTS NewData arrive fmt: %d", fmt);
    NSMutableDictionary* sentenceDict = nil;
    for(NSMutableDictionary *dict in self.synthesisTexts){
        if([[dict objectForKey:@"ID"] integerValue] == SynthesizeSentence){
            sentenceDict = dict;
            break;
        }
    }
    if(sentenceDict == nil){
        NSLog(@"TTS data arrived Sentence ID mismatch??? received ID: %ld\nKnown sentences:", (long)SynthesizeSentence);
        
        return;
    }
    [self saveData:newData];
    [sentenceDict setObject:[NSNumber numberWithInteger:newLength] forKey:@"SYNTH_LEN"];
    //[self refreshAfterProgressUpdate:sentenceDict];
}

- (void)saveData: (NSData *)newData{
    
    // 获取路径.
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"tts.mp3"];
    NSError *error = nil;
    
    BOOL written = [newData writeToFile:filePath options:NSDataWritingAtomic error:&error];

    
    if (!written) {
        NSLog(@"write failed: %@", [error localizedDescription]);
    }
}

- (void)synthesizerTextSpeakLengthChanged:(int)newLength
                           sentenceNumber:(NSInteger)SpeakSentence{
    NSLog(@"TTS SpeakLen %ld, %d", SpeakSentence, newLength);
    NSMutableDictionary* sentenceDict = nil;
    for(NSMutableDictionary *dict in self.synthesisTexts){
        if([[dict objectForKey:@"ID"] integerValue] == SpeakSentence){
            sentenceDict = dict;
            break;
        }
    }
    if(sentenceDict == nil){
        NSLog(@"TTS speeak length changed Sentence ID mismatch??? received ID: %ld\nKnown sentences:", (long)SpeakSentence);
        
        return;
    }
    [sentenceDict setObject:[NSNumber numberWithInteger:newLength] forKey:@"SPEAK_LEN"];
    //[self refreshAfterProgressUpdate:sentenceDict];
}

- (void)synthesizerdidPause{
    NSLog(@"TTS Did pause");
}

- (void)synthesizerResumed{
    NSLog(@"TTS Did resume");
  
}

- (void)synthesizerCanceled{
    NSLog(@"TTS Did cancel");
}

- (void)synthesizerErrorOccurred:(NSError *)error
                        speaking:(NSInteger)SpeakSentence
                    synthesizing:(NSInteger)SynthesizeSentence{
    NSLog(@"TTS Did error %@ %ld, %ld", error, SpeakSentence, SynthesizeSentence);


    [self.synthesisTexts removeAllObjects];

    [[BDSSpeechSynthesizer sharedInstance] cancel];
    

}


@end
