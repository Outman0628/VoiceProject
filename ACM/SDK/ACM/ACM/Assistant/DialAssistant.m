//
//  DialAssistant.m
//  ACM
//
//  Created by David on 2020/2/6.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DialAssistant.h"
#import "AssistantItem.h"
#import "Assistant.h"

@interface DialAssistant()

@end

@implementation DialAssistant

-(id _Nullable )init
{
    if (self = [super init]) {
        self->_assId = [NSString stringWithFormat:@""];
        self.contents = [NSMutableArray array];
        self.config = [[VoiceConfig alloc]init];
        self.dialDateTime = [[NSDate alloc ] init];
        self.subscribers = [NSMutableArray array];
        [self.subscribers addObject:@"515"];
        [self.subscribers addObject:@"501"];
    }
    return self;
}

/*
 * 克隆
 */
- (id)copy{
    DialAssistant *clone = [[DialAssistant alloc]init];
    clone->_assId = _assId;
    clone.config.speechVolume = _config.speechVolume;
    clone.config.speechSpeed = _config.speechSpeed;
    clone.config.speechPich = _config.speechPich;
    clone.config.curSpeakerIndex = _config.curSpeakerIndex;
    clone.dialDateTime = [[NSDate alloc] initWithTimeIntervalSinceNow: _dialDateTime.timeIntervalSinceNow];
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
    if(_subscribers != nil && _subscribers.count > 0){
        for(int i = 0; i < _subscribers.count; i++){
            NSObject *item = _subscribers[i];
            if([item isMemberOfClass:[NSString class]]){
                NSString *cloneSubscriber = [NSString stringWithFormat:@"%@", _subscribers[i]];
                [clone.subscribers addObject:cloneSubscriber];
            }
        }
    }
    return clone;
}


@end
