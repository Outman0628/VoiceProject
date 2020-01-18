//
//  AssistantItem.m
//  ACM
//
//  Created by David on 2020/1/18.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AssistantItem.h"

@interface AssistanItem()

@end

@implementation AssistanItem

-(AssistanItem *) clone{
    AssistanItem *item = [[AssistanItem alloc] init];
    item.interval = _interval;
    if(_content != nil)
    {
        item.content = [NSString stringWithFormat:@"%@", _content];
    }
    
    return item;
}

@end
