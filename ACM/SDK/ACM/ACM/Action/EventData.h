//
//  EventData.h
//  ACM
//
//  Created by David on 2020/1/7.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef EventData_h
#define EventData_h

#import "../ACMCommon.h"

typedef struct _EventData {
    
    ACMEventType type;
    int param1;
    int param2;
    double param3;
    id  param4;
    id  param5;
    id  param6;
    id  param7;
    id  param8;
} EventData;

#endif /* EventData_h */
