//
//  DAItemContentCell.m
//  VoiceCallDemo
//
//  Created by David on 2020/2/5.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAItemContentCell.h"
#ifdef AssistantDef
#import <ACM/AssistantItem.h>
#endif

@interface DAItemContentCell() <UITextViewDelegate>

@end

@implementation DAItemContentCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    self.contentTextView.returnKeyType =UIReturnKeyDone;
    self.intervalTextField.returnKeyType =UIReturnKeyDone;
    self.contentTextView.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    
    [_contentTextView resignFirstResponder];
    [_intervalTextField resignFirstResponder];
}

#ifdef AssistantDef
- (IBAction)intervalChanged:(id)sender {
    @try{
    AssistanItem *retItem = (AssistanItem *)_assItem;
    retItem.interval = [_intervalTextField.text integerValue];
    }
    @catch (NSException *e){
        
    }
}

///////////////// from UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView{
    AssistanItem *retItem = (AssistanItem *)_assItem;
    retItem.content = _contentTextView.text;
}

- (IBAction)delBtnClicked:(id)sender {
    if(_delegate != nil){
        [_delegate delContent:_assItem];
    }
}
#endif

@end
