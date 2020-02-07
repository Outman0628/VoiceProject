//
//  DASubscribersCell.m
//  VoiceCallDemo
//
//  Created by David on 2020/2/7.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DASubscribersCell.h"

@interface DASubscribersCell()

@end

@implementation DASubscribersCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    [_subscribersTextView resignFirstResponder];
}



@end
