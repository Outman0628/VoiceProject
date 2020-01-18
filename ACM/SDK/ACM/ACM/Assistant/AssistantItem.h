//
//  AssistantItem.h
//  ACM
//
//  Created by David on 2020/1/17.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef AssistantItem_h
#define AssistantItem_h

@interface AssistanItem : NSObject
@property  NSInteger interval;     // 与前面一句话的间隔时间 s
@property  NSString *content;      // 文本内容

/*
 * 克隆
 */
-(AssistanItem *) clone;

@end


#endif /* AssistantItem_h */
