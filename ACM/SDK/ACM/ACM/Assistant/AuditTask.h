//
//  AuditTask.h
//  ACM
//
//  Created by David on 2020/1/20.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef AuditTask_h
#define AuditTask_h

#import "Assistant.h"

@interface AuditTask : NSObject


-(BOOL )audit: (NSMutableArray *_Nonnull) contents completionBlock: (AssistantBlock _Nullable )completionHandler;

@end

#endif /* AuditTask_h */
