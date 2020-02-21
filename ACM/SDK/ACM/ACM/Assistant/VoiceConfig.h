//
//  VoiceConfig.h
//  ACM
//
//  Created by David on 2020/2/19.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef VoiceConfig_h
#define VoiceConfig_h

@interface VoiceConfig : NSObject

@property NSInteger speechVolume;           // 音量  (0-15)
@property NSInteger speechSpeed;            // 语速  (0-9)
@property NSInteger speechPich;             // 音调  (0-9)
@property NSInteger curSpeakerIndex;        // 当前播报人员(speakerCadidates 中的index)

@end

#endif /* VoiceConfig_h */
