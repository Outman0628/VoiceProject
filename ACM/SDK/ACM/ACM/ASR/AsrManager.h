//
//  AsrManager.h
//  ACM
//
//  Created by David on 2020/1/14.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef AsrManager_h
#define AsrManager_h
#include "AssistantEnum.h"

typedef void (^AudioFileToTextBlock)(AudioToFileCode code,  NSString * _Nullable text);

@interface AsrManager : NSObject
// 初始化Asr 对象

- (BOOL)startAsr;

- (void)stopAsr;

-(void)repeatAsr;

-(void)audioFileToText:(nonnull NSString*) filePath  CallBack:(AudioFileToTextBlock _Nonnull ) block;

-(void)stopAudioFileToTextTask;

@end

#endif /* AsrManager_h */
