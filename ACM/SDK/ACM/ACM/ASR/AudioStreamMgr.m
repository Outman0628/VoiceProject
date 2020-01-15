//
//  AudioStreamMgr.m
//  ACM
//
//  Created by David on 2020/1/14.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioStreamMgr.h"
#import "ExternalAudio.h"

@interface AudioStreamMgr ()

    @property NSMutableArray * _Nullable subScriberList;
    @property ExternalAudio *extAudio;
@end

@implementation AudioStreamMgr

static AudioStreamMgr* instace = nil;

+ (void)initMgr{
    if(instace == nil)
    {
        instace = [[AudioStreamMgr alloc] init];
        [instace initExtraAudio];
    }
}

+ (void)startWork{
    [instace.extAudio startWork];
}

+ (void)stopWork{
    if(instace != nil)
    {
        [instace.extAudio stopWork];
    }
    
}

+ (BOOL)subscribeAudioStream: (nonnull NSObject* ) delegate{
    BOOL ret = false;
    if(instace != nil)
    {
        [instace.subScriberList addObject:delegate];
    }
    return ret;
}

+ (void)unsubscribeAudioStream: (nonnull NSObject* ) delegate
{
    if(instace != nil)
    {
@synchronized(self) {
        for (int i=0; i<[instace.subScriberList count]; i++) {
            if(instace.subScriberList[i] == delegate)
            {
                [instace.subScriberList removeObject:delegate];
            }
        }
        }
    }
}

+ (void)didCaptureData:(unsigned char *_Nullable)data bytesLength:(int)bytesLength
{
    if(instace != nil)
    {
        @synchronized(self) {
            for (int i=0; i<[instace.subScriberList count]; i++) {
                id <AudioStreamPushDelegate> delegate =instace.subScriberList[i];
                [delegate didCaptureData:data bytesLength:bytesLength];
            }
        }
    }
    
}

-(id _Nullable )init{
    if (self = [super init]) {
        self.subScriberList = [NSMutableArray array];
    }
    return self;
}

- (void) initExtraAudio{
    self.extAudio = [ExternalAudio sharedExternalAudio];
    [self.extAudio setupExternalAudioWithAgoraKit:nil sampleRate:16000 channels:1 audioCRMode:AudioCRModeExterCaptureSDKRender IOType:IOUnitTypeVPIO];
}

@end
