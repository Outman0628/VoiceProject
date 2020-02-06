//
//  UpDateConfigTask.h
//  ACM
//
//  Created by David on 2020/1/20.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef UpDateConfigTask_h
#define UpDateConfigTask_h

#import "Assistant.h"

@interface UpDateConfigTask : NSObject


//-(BOOL )updateConfig: (NSMutableArray *_Nonnull) contents  Config:(VoiceConfig *)config completionBlock: (AssistantBlock _Nullable )completionHandler;


-(BOOL )updateAnswerAssistantConfig: (AnswerAssistant *_Nonnull) AAss  completionBlock: (AssistantBlock _Nullable )completionHandler;

-(BOOL )updateDialAssistantConfig: (DialAssistant *_Nonnull) DAss  completionBlock: (AssistantBlock _Nullable )completionHandler;

@end

#endif /* UpDateConfigTask_h */
