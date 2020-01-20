//
//  TtsManager.h
//  ACM
//
//  Created by David on 2020/1/17.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef TtsManager_h
#define TtsManager_h


@class TtsFileTasks;

@interface TtsManager : NSObject

- (void)SynthesizeText:(nonnull NSString *)text;

// 文转音，并返回转换句柄
- (NSInteger)SynthesizeTTsText:(nonnull NSString *)text fileName:(nonnull NSString*)fName ttsTask:(nonnull TtsFileTasks*)task withError:(NSError**)err;

@end


#endif /* TtsManager_h */
