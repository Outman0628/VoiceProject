//
//  HttpUtil.h
//  ACM
//
//  Created by David on 2020/1/29.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef HttpUtil_h
#define HttpUtil_h

typedef void (^HttpResponseCallback)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

#define EndCallApi  @"/dapi/call/end"
#define AnswerAssistantSettingApi @"/dapi/account/get-reject-tone"
#define ActiveCallApi @"/dapi/call/msg"

@interface HttpUtil : NSObject

+(void) HttpPost: (nonnull NSString*) stringUrl Param:(nonnull NSString *)param Callback:(HttpResponseCallback _Nullable  )completionHandler;

@end

#endif /* HttpUtil_h */
