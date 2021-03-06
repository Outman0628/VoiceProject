//
//  DAItemOperationCell.m
//  VoiceCallDemo
//
//  Created by David on 2020/2/5.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAItemOperationCell.h"


@interface DAItemOperationCell()

@end

@implementation DAItemOperationCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (IBAction)auditAss:(id)sender {
    if(_delegate != nil)
    {
        [_delegate auditAss];
    }
}


- (IBAction)updateAss:(id)sender {
    if(_delegate != nil)
    {
        [_delegate updateAss];
    }
}

- (IBAction)voiceSetting:(id)sender {
    if(_delegate != nil)
    {
        [_delegate assVoiceSeting];
    }
}

- (IBAction)newContent:(id)sender {
    if(_delegate != nil)
    {
        [_delegate addContent];
    }
}

@end
