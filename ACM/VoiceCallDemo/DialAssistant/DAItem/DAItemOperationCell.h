//
//  DAItemOperationCell.h
//  VoiceCallDemo
//
//  Created by David on 2020/2/5.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef DAItemOperationCell_h
#define DAItemOperationCell_h

@protocol DAItemOperationDelegate <NSObject>

-(void) auditAss;

-(void) updateAss;

-(void) assVoiceSeting;

-(void) addContent;

@end

#import <UIKit/UIKit.h>
@interface DAItemOperationCell : UITableViewCell
@property (nonatomic,weak) id<DAItemOperationDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIButton *auditBtn;
@property (nonatomic, strong) IBOutlet UIButton *updateBtn;
@property (nonatomic, strong) IBOutlet UIButton *settingBtn;
@property (nonatomic, strong) IBOutlet UIButton *addContentBtn;
@end

#endif /* DAItemOperationCell_h */
