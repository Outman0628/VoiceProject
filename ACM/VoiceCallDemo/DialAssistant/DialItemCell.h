//
//  DialItemCell.h
//  VoiceCallDemo
//
//  Created by David on 2020/2/5.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef DialItemCell_h
#define DialItemCell_h

#import <UIKit/UIKit.h>
@interface DialItemCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIButton *delBtn;
@property (nonatomic, strong) IBOutlet UIButton *detailBtn;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@end
#endif /* DialItemCell_h */
