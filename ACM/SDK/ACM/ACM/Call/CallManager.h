//
//  CallManager.h
//  ACM
//
//  Created by David on 2020/1/9.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef CallManager_h
#define CallManager_h
#import "Call.h"

@interface CallManager : NSObject

// 正在进行中的电话，注意刚结束不久的电话也在这个队列
// 防止频繁的拨号，挂断使得状态不通不及时，造成拨打方和接听方进入已结束的通话
@property NSMutableArray * _Nullable activeCallList;


/*
 初始化
 */
-(id _Nullable )init;

/*
 检测通话是否已经存在
 
 @param channelId 通话 channel
 @return YES 通话已经存在，No 通话不存在
 */
-(BOOL )IsActiveCall: (nonnull NSString *)channelId;

/*
生成新的通话记录
 @param channelId 通话 channel
 @return YES 通话已经存在，No 通话不存在
 */
-( nonnull Call * )createReceveCall: (nonnull NSDictionary *)callReq;

@end

#endif /* CallManager_h */
