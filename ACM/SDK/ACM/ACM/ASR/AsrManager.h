//
//  AsrManager.h
//  ACM
//
//  Created by David on 2020/1/14.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef AsrManager_h
#define AsrManager_h

@interface AsrManager : NSObject
// 初始化Asr 对象

- (BOOL)startAsr;

- (void)stopAsr;

-(void)repeatAsr;

@end

#endif /* AsrManager_h */
