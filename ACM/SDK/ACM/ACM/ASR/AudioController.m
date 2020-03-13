//
//  AcmAudioController.m
//  ACM
//
//  Created by David on 2020/1/13.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AudioController.h"

#define InputBus 1
#define OutputBus 0

#import "../Log/AcmLog.h"
#define AudioCtrlTag  @"AudioCtrl"

@interface AudioController ()
@property (nonatomic, assign) OSStatus error;
@property (nonatomic, assign) AudioUnit remoteIOUnit;
@property (nonatomic, assign) int sampleRate;
@property (nonatomic, assign) int channelCount;
@end

@implementation AudioController

static double preferredIOBufferDuration = 0.02;

+ (instancetype)audioController {
    AudioController *audioController = [[self alloc] init];
    return audioController;
}

#pragma mark - <Capture Call Back>
static OSStatus captureCallBack(void *inRefCon,
                                AudioUnitRenderActionFlags *ioActionFlags,
                                const AudioTimeStamp *inTimeStamp,
                                UInt32 inBusNumber, // inputBus = 1
                                UInt32 inNumberFrames,
                                AudioBufferList *ioData)
{
    AudioController *audioController = (__bridge AudioController *)inRefCon;
    
    AudioUnit captureUnit = [audioController remoteIOUnit];
    
    if (!inRefCon) return 0;
    
    AudioBuffer buffer;
    buffer.mData = NULL;
    buffer.mDataByteSize = 0;
    buffer.mNumberChannels = audioController.channelCount;
    
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0] = buffer;
    
    OSStatus status = AudioUnitRender(captureUnit,
                                      ioActionFlags,
                                      inTimeStamp,
                                      inBusNumber,
                                      inNumberFrames,
                                      &bufferList);
    
    if (!status) {
        if ([audioController.delegate respondsToSelector:@selector(audioController:didCaptureData:bytesLength:)]) {
            [audioController.delegate audioController:audioController didCaptureData:(unsigned char *)bufferList.mBuffers[0].mData bytesLength:bufferList.mBuffers[0].mDataByteSize];
        }
    }
    else {
        [audioController error:status position:@"captureCallBack"];
    }
    
    return 0;
}

#pragma mark - <Render Call Back>
static OSStatus renderCallBack(void *inRefCon,
                               AudioUnitRenderActionFlags *ioActionFlags,
                               const AudioTimeStamp *inTimeStamp,
                               UInt32 inBusNumber,
                               UInt32 inNumberFrames,
                               AudioBufferList *ioData)
{
    AudioController *audioController = (__bridge AudioController *)(inRefCon);
    
    if (*ioActionFlags == kAudioUnitRenderAction_OutputIsSilence) {
        return noErr;
    }
    
    int result = 0;
    
    if ([audioController.delegate respondsToSelector:@selector(audioController:didRenderData:bytesLength:)]) {
        result = [audioController.delegate audioController:audioController didRenderData:(uint8_t*)ioData->mBuffers[0].mData bytesLength:ioData->mBuffers[0].mDataByteSize];
    }
    
    if (result == 0) {
        *ioActionFlags = kAudioUnitRenderAction_OutputIsSilence;
        ioData->mBuffers[0].mDataByteSize = 0;
    }
    
    return noErr;
}

- (void)audioController:(AudioController *)controller
         didCaptureData:(unsigned char *)data
            bytesLength:(int)bytesLength{
    
}

#pragma mark - <Step 1, Set Up Audio Session>
- (void)setUpAudioSessionWithSampleRate:(int)sampleRate channelCount:(int)channelCount audioCRMode:(AudioCRMode)audioCRMode IOType:(IOUnitType)ioType{

    

    self.sampleRate = sampleRate;
    self.channelCount = channelCount;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSUInteger sessionOption = AVAudioSessionCategoryOptionMixWithOthers;
    sessionOption |= AVAudioSessionCategoryOptionAllowBluetooth;
    
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:sessionOption error:nil];
    [audioSession setMode:AVAudioSessionModeDefault error:nil];
    [audioSession setPreferredIOBufferDuration:preferredIOBufferDuration error:nil];
    NSError *error;
    BOOL success = [audioSession setActive:YES error:&error];
    if (!success) {
        ErrLog(AudioCtrlTag,@"<Error> audioSession setActive:YES error:nil");
    }
    if (error) {
        ErrLog(AudioCtrlTag,@"<Error> setUpAudioSessionWithSampleRate : %@", error.localizedDescription);
    }

    
    [self setupRemoteIOWithIOType:ioType];
}

#pragma mark - <Step 2, Set Up Audio Unit>
- (void)setupRemoteIOWithIOType:(IOUnitType)ioType {
#if TARGET_OS_IPHONE
    // AudioComponentDescription
    AudioComponentDescription remoteIODesc;
    remoteIODesc.componentType = kAudioUnitType_Output;
    remoteIODesc.componentSubType = ioType == IOUnitTypeVPIO ? kAudioUnitSubType_VoiceProcessingIO : kAudioUnitSubType_RemoteIO;
    remoteIODesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    remoteIODesc.componentFlags = 0;
    remoteIODesc.componentFlagsMask = 0;
    AudioComponent remoteIOComponent = AudioComponentFindNext(NULL, &remoteIODesc);
    _error = AudioComponentInstanceNew(remoteIOComponent, &_remoteIOUnit);
    [self error:_error position:@"AudioComponentInstanceNew"];
#endif
    
  //  if (_audioCRMode == AudioCRModeExterCaptureSDKRender || _audioCRMode == AudioCRModeExterCaptureExterRender) {
        
#if !TARGET_OS_IPHONE
        AudioComponentDescription remoteIODesc;
        remoteIODesc.componentType = kAudioUnitType_Output;
        remoteIODesc.componentSubType = kAudioUnitSubType_HALOutput;
        remoteIODesc.componentManufacturer = kAudioUnitManufacturer_Apple;
        remoteIODesc.componentFlags = 0;
        remoteIODesc.componentFlagsMask = 0;
        AudioComponent remoteIOComponent = AudioComponentFindNext(NULL, &remoteIODesc);
        _error = AudioComponentInstanceNew(remoteIOComponent, &_remoteIOUnit);
        [self error:_error position:@"AudioComponentInstanceNew"];
        _error = AudioUnitInitialize(_remoteIOUnit);
        [self error:_error position:@"AudioUnitInitialize"];
#endif
        [self setupCapture];
  //  }
    
   // if (_audioCRMode == AudioCRModeSDKCaptureExterRender || _audioCRMode == AudioCRModeExterCaptureExterRender) {
        
#if !TARGET_OS_IPHONE
        AudioComponentDescription macPlayDesc;
        macPlayDesc.componentType = kAudioUnitType_Output;
        macPlayDesc.componentSubType = kAudioUnitSubType_DefaultOutput;
        macPlayDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
        macPlayDesc.componentFlags = 0;
        macPlayDesc.componentFlagsMask = 0;
        AudioComponent macPlayComponent = AudioComponentFindNext(NULL, &macPlayDesc);
        _error = AudioComponentInstanceNew(macPlayComponent, &_macPlayUnit);
        [self error:_error position:@"AudioComponentInstanceNew"];
        _error = AudioUnitInitialize(_macPlayUnit);
        [self error:_error position:@"AudioUnitInitialize"];
#endif
        [self setupRender];
   // }

    
}

- (void)setupCapture {
    // EnableIO
    UInt32 one = 1;
    _error = AudioUnitSetProperty(_remoteIOUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  InputBus,
                                  &one,
                                  sizeof(one));
    [self error:_error position:@"kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input"];
    
    
    // AudioStreamBasicDescription
    AudioStreamBasicDescription streamFormatDesc = [self signedIntegerStreamFormatDesc];
    _error = AudioUnitSetProperty(_remoteIOUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  InputBus,
                                  &streamFormatDesc,
                                  sizeof(streamFormatDesc));
    [self error:_error position:@"kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output"];
    
    // CallBack
    AURenderCallbackStruct captureCallBackStruck;
    captureCallBackStruck.inputProcRefCon = (__bridge void * _Nullable)(self);
    captureCallBackStruck.inputProc = captureCallBack;
    
    _error = AudioUnitSetProperty(_remoteIOUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  InputBus,
                                  &captureCallBackStruck,
                                  sizeof(captureCallBackStruck));
    [self error:_error position:@"kAudioOutputUnitProperty_SetInputCallback"];
}

- (AudioStreamBasicDescription)signedIntegerStreamFormatDesc {
    AudioStreamBasicDescription streamFormatDesc;
    streamFormatDesc.mSampleRate = _sampleRate;
    streamFormatDesc.mFormatID = kAudioFormatLinearPCM;
    streamFormatDesc.mFormatFlags = (kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked);
    streamFormatDesc.mChannelsPerFrame = _channelCount;
    streamFormatDesc.mFramesPerPacket = 1;
    streamFormatDesc.mBitsPerChannel = 16;
    streamFormatDesc.mBytesPerFrame = streamFormatDesc.mBitsPerChannel / 8 * streamFormatDesc.mChannelsPerFrame;
    streamFormatDesc.mBytesPerPacket = streamFormatDesc.mBytesPerFrame * streamFormatDesc.mFramesPerPacket;
    
    return streamFormatDesc;
}

- (void)setupRender {

    // EnableIO
    UInt32 one = 1;
    _error = AudioUnitSetProperty(_remoteIOUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  OutputBus,
                                  &one,
                                  sizeof(one));
    [self error:_error position:@"kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output"];
    
    // AudioStreamBasicDescription
    AudioStreamBasicDescription streamFormatDesc = [self signedIntegerStreamFormatDesc];
    _error = AudioUnitSetProperty(_remoteIOUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  OutputBus,
                                  &streamFormatDesc,
                                  sizeof(streamFormatDesc));
    [self error:_error position:@"kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input"];
    
    // CallBack
    AURenderCallbackStruct renderCallback;
    renderCallback.inputProcRefCon = (__bridge void * _Nullable)(self);
    renderCallback.inputProc = renderCallBack;
    AudioUnitSetProperty(_remoteIOUnit,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Input,
                         OutputBus,
                         &renderCallback,
                         sizeof(renderCallback));
    [self error:_error position:@"kAudioUnitProperty_SetRenderCallback"];
    
    
}

- (void)startWork {

        _error = AudioOutputUnitStart(_remoteIOUnit);
        [self error:_error position:@"AudioOutputUnitStart"];

}

- (void)error:(OSStatus)error position:(NSString *)position {
    if (error != noErr) {
        NSString *errorInfo = [NSString stringWithFormat:@"<ACLog> Error: %d, Position: %@", (int)error, position];
        if ([self.delegate respondsToSelector:@selector(audioController:error:info:)]) {
            [self.delegate audioController:self error:error info:position];
        }
        InfoLog(AudioCtrlTag,@"<OSStatus> :%@", errorInfo);
    }
}

- (void)stopWork {
    _error = AudioOutputUnitStop(_remoteIOUnit);
    [self error:_error position:@"AudioOutputUnitStop"];
}

@end
