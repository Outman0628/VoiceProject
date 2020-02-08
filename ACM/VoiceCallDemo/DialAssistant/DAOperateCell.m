//
//  DAOperateCell.m
//  VoiceCallDemo
//
//  Created by David on 2020/2/5.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAOperateCell.h"


@interface DAOperateCell()

@end

@implementation DAOperateCell
- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    
}

- (IBAction)newDialPlan:(id)sender {
    if(_delegate != nil){
        [_delegate addNewDialTask];
    }
}

@end
