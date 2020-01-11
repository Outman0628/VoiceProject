//
//  ViewController.h
//  VoiceCallDemo/works/outsources/liuzheng/voiceprjs/iOSDemo/ACM/VoiceCallDemo/VoiceCallDemo/ViewController.m
//
//  Created by David on 2020/1/3.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicViewController.h"

@interface ViewController : BasicViewController
- (void) handleApnsToken: (nullable NSString *)token;
- (BOOL) handleApnsMessage:(nonnull NSDictionary *)message;
@end

