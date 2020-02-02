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
#import "Assistant.h"

@interface AnswerAssistant()
@end

@implementation AnswerAssistant

-(id _Nullable )init
{
    if (self = [super init]) {
        
        self.contents = [NSMutableArray array];
        self.config = [[VoiceConfig alloc]init];
        self.enable = true;
    }
    return self;
}

/*
 * 克隆
 */
-(AnswerAssistant *) clone{
    AnswerAssistant *clone = [[AnswerAssistant alloc]init];
    clone.config.speechVolume = _config.speechVolume;
    clone.config.speechSpeed = _config.speechSpeed;
    clone.config.speechPich = _config.speechPich;
    clone.config.curSpeakerIndex = _config.curSpeakerIndex;
    clone.enable = _enable;
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
