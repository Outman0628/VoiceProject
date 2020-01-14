//
//  AcmAudioController.h
//  ACM
//
//  Created by David on 2020/1/13.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef AcmAudioController_h
#define AcmAudioController_h

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(int, AudioCRMode) {
    AudioCRModeExterCaptureSDKRender = 1,
    AudioCRModeSDKCaptureExterRender = 2,
    AudioCRModeSDKCaptureSDKRender = 3,
    AudioCRModeExterCaptureExterRender = 4
};

typedef NS_ENUM(int, IOUnitType) {
    IOUnitTypeVPIO,
    IOUnitTypeRemoteIO
};

@class AudioController;
@protocol AudioControllerDelegate <NSObject>
@optional
- (void)audioController:(AudioController *)controller
         didCaptureData:(unsigned char *)data
            bytesLength:(int)bytesLength;
- (int)audioController:(AudioController *)controller
         didRenderData:(unsigned char *)data
           bytesLength:(int)bytesLength;
- (void)audioController:(AudioController *)controller
                  error:(OSStatus)error
                   info:(NSString *)info;
@end

@interface AudioController : NSObject
@property (nonatomic, weak) id<AudioControllerDelegate> delegate;

+ (instancetype)audioController;
- (void)setUpAudioSessionWithSampleRate:(int)sampleRate channelCount:(int)channelCount audioCRMode:(AudioCRMode)audioCRMode IOType:(IOUnitType)ioType;
- (void)startWork;
- (void)stopWork;
@end

#endif /* AcmAudioController_h */
