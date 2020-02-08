//
//  DAItemContentCell.h
//  VoiceCallDemo
//
//  Created by David on 2020/2/5.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef DAItemContentCell_h
#define DAItemContentCell_h

#import <UIKit/UIKit.h>

@protocol DAItemConentOperate <NSObject>

-(void) delContent: (NSObject *) assItem;

@end

@interface DAItemContentCell : UITableViewCell
@property (nonatomic,weak) id<DAItemConentOperate> delegate;
@property NSObject *assItem;
@property (nonatomic, strong) IBOutlet UIButton *delBtn;
@property (nonatomic, strong) IBOutlet UITextView *contentTextView;
@property (nonatomic, strong) IBOutlet UITextField *intervalTextField;
@end

#endif /* DAItemContentCell_h */
