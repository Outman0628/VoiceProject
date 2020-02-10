//
//  VideoChatViewController.h
//  Agora iOS Tutorial Objective-C
//
//  Created by James Fang on 7/15/16.
//  Copyright © 2016 Agora.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoChatViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *localVideo;
@property (weak, nonatomic) IBOutlet UIView *remoteVideo;

@end

