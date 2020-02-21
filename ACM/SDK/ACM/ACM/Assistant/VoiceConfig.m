//
//  VoiceConfig.m
//  ACM
//
//  Created by David on 2020/2/19.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoiceConfig.h"

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
