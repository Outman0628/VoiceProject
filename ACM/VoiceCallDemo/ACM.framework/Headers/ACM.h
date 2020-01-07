//
//  ACM.h
//  ACM
//
//  Created by David on 2020/1/2.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for ACM.
FOUNDATION_EXPORT double ACMVersionNumber;

//! Project version string for ACM.
FOUNDATION_EXPORT const unsigned char ACMVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <ACM/PublicHeader.h>
#import "IACMCallBack.h"

@interface ACM : NSObject
+ (void) initManager: ( nullable NSString *) appId  acmCallback:(id <IACMCallBack> _Nullable)delegate;
@end
