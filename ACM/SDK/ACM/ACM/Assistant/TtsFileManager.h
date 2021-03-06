//
//  TtsFileManager.h
//  ACM
//
//  Created by David on 2020/1/17.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef TtsFileManager_h
#define TtsFileManager_h
#import "AssistantEnum.h"
#import "Assistant.h"

@class TtsManager;

@interface TtsFileManager : NSObject

+(nullable NSString *)generateFileName:(nonnull NSString*) content  fullName:(NSString**)filePath Config:(VoiceConfig *_Nullable)config;

-(void)prepareVoiceFiles:(nonnull NSArray *) contents ttsManager:(nonnull TtsManager *)ttsMgr Config:(VoiceConfig *_Nullable)config completionBlock: (AssistantBlock _Nullable )completionHandler;


@end

#endif /* TtsFileManager_h */
