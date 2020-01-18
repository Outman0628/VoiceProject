//
//  AnswerAsistant.m
//  ACM
//
//  Created by David on 2020/1/12.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnswerAssistant.h"
#import "AssistantItem.h"

@interface AnswerAssistant()
@end

@implementation AnswerAssistant

-(id _Nullable )init
{
    if (self = [super init]) {
        
        self.contents = [NSMutableArray array];
        self.enable = false;
    }
    return self;
}

/*
 * 克隆
 */
-(AnswerAssistant *) clone{
    AnswerAssistant *clone = [[AnswerAssistant alloc]init];
    clone.speechVolume = _speechVolume;
    clone.speechSpeed = _speechSpeed;
    clone.speechPich = _speechPich;
    clone.curSpeakerIndex = _curSpeakerIndex;
    if(_contents != nil && _contents.count > 0)
    {
        for (int i=0; i<[_contents count]; i++) {
            NSObject *item = _contents[i];
            
            if([item isMemberOfClass:[AssistanItem class]])
            {
                AssistanItem *cloneItem = [(AssistanItem *)_contents[i] clone];
                [clone.contents addObject:cloneItem];
            }
            
        }
    }
    return clone;
}


@end
