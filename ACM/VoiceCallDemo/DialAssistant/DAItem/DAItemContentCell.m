//
//  DAItemContentCell.m
//  VoiceCallDemo
//
//  Created by David on 2020/2/5.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAItemContentCell.h"

@interface DAItemContentCell()

@end

@implementation DAItemContentCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    self.contentTextView.returnKeyType =UIReturnKeyDone;
    self.intervalTextField.returnKeyType =UIReturnKeyDone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    
    [_contentTextView resignFirstResponder];
    [_intervalTextField resignFirstResponder];
}



@end
