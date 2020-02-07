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
#import <ACM/DialAssistant.h>
#import "BasicViewController.h"

@interface DAItemDetailViewController : UITableViewController  <ShowAlertProtocol>
//@interface DAItemDetailViewController : BasicViewController
@property  DialAssistant* dialAss;
@end

#endif /* DAItemDetailViewController_h */
