//
//  DAItemDetailViewController.h
//  VoiceCallDemo
//
//  Created by David on 2020/2/5.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef DAItemDetailViewController_h
#define DAItemDetailViewController_h

#import <UIKit/UIKit.h>
#ifdef AssistantDef
#import <ACM/DialAssistant.h>
#endif
#import "BasicViewController.h"

@interface DAItemDetailViewController : UITableViewController  <ShowAlertProtocol>
//@interface DAItemDetailViewController : BasicViewController
#ifdef AssistantDef
@property  DialAssistant* dialAss;
#endif
@end

#endif /* DAItemDetailViewController_h */
