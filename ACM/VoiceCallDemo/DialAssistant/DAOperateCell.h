//
//  DAOperateCell.h
//  VoiceCallDemo
//
//  Created by David on 2020/2/5.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef DAOperateCell_h
#define DAOperateCell_h

#import <UIKit/UIKit.h>

@protocol DAOperateCellDelegate <NSObject>

-(void) addNewDialTask;

@end

@interface DAOperateCell : UITableViewCell
@property (nonatomic,weak) id<DAOperateCellDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIButton *addDABtn;
@end

#endif /* DAOperateCell_h */
