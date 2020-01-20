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


-(BOOL )updateConfig: (NSMutableArray *_Nonnull) contents completionBlock: (AssistantBlock _Nullable )completionHandler;

@end

#endif /* UpDateConfigTask_h */
