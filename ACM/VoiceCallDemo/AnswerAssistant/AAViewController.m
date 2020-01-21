//
//  AAViewController.m
//  VoiceCallDemo
//
//  Created by David on 2020/1/20.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAViewController.h"
#import <ACM/Assistant.h>
#import <ACM/AnswerAssistant.h>
#import <ACM/AssistantItem.h>

@interface AAViewController ()

@property (weak, nonatomic) IBOutlet UIView *AssistantItemView1;

@property (weak, nonatomic) IBOutlet UIView *AssistantItemView2;

@property (weak, nonatomic) IBOutlet UIView *AssistantItemView3;

@property (weak, nonatomic) IBOutlet UIView *AssistantItemView4;

@property (weak, nonatomic) IBOutlet UIButton *auditButton;

@property (weak, nonatomic) IBOutlet UIButton *updateButton;

@property (weak, nonatomic) IBOutlet UISwitch *assSwitch;

@end

@implementation AAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAssView];
    

}



-(void) initAssView{
    [self ClearAssistantItem:_AssistantItemView1];
    [self ClearAssistantItem:_AssistantItemView2];
    [self ClearAssistantItem:_AssistantItemView3];
    [self ClearAssistantItem:_AssistantItemView4];
}

- (IBAction)itemSwitch:(id)sender {
   // UISwitch *switcher = (UISwitch *)sender;
    /*
    for(UIView *subView in _AssistantItemView1.subviews)
    {
        if([subView isKindOfClass:[UITextView class]])
        {
            ((UITextView *)subView).text = @"";
        }
    }
     */
}

- (IBAction)DismissKeyboard:(id)sender {
    //[self.view resignFirstResponder];
    
    [self DismissItemKeyboard:_AssistantItemView1];
    [self DismissItemKeyboard:_AssistantItemView2];
    [self DismissItemKeyboard:_AssistantItemView3];
    [self DismissItemKeyboard:_AssistantItemView4];
}

- (void)DismissItemKeyboard:(nonnull UIView *)view{
    for(UIView *subView in view.subviews)
    {
        [subView resignFirstResponder];
    }
}



-(void) ClearAssistantItem:(nonnull UIView *)view{
    for(UIView *subView in view.subviews)
    {
        if([subView isKindOfClass:[UITextView class]])
        {
            ((UITextView *)subView).text = @"";
        }
    }
}

- (IBAction)answerAssistantSwitch:(id)sender {
    
}

/*
 - (void)auditAssistant{
 
 AnswerAssistant *ass = [[AnswerAssistant alloc]init];
 ass.enable = YES;
 // ass.content = @"你好中国";
 
 AssistanItem *item1 = [[AssistanItem alloc]init];
 item1.interval = 5;
 item1.content = [NSString stringWithFormat:@"你好中国"];
 
 AssistanItem *item2 = [[AssistanItem alloc]init];
 item2.interval = 3;
 item2.content = [NSString stringWithFormat:@"天气晴朗"];
 
 [ass.contents addObject:item1];
 [ass.contents addObject:item2];
 
 // [Assistant auditionAnswerAssistant:ass];
 
 /*
 [Assistant auditionAnswerAssistant:ass completionBlock:^(AssistantCode code, NSError * _Nullable subCode) {
 [self showAlert:[NSString stringWithFormat:@"试听结果 %ld",(long)code]];
 }];
 */
/*
[Assistant updateAnswerAssistantParam:ass completionBlock:^(AssistantCode code, NSError * _Nullable subCode) {
    [self showAlert:[NSString stringWithFormat:@"语音助手配置完成 %ld",(long)code]];
}];
}

 
 */


- (IBAction)auditAss:(id)sender {
    AnswerAssistant *ass = nil;
    
    if([self generateAnswerAssit:&ass])
    {
        [Assistant auditionAnswerAssistant:ass completionBlock:^(AssistantCode code, NSError * _Nullable subCode) {
            [self showAlert:[NSString stringWithFormat:@"试听结果 %d", code]];
        }];
    }else
    {
        [self showAlert:@"参数错误请检查"];
    }
    
}

- (IBAction)updateAss:(id)sender {
}

-(BOOL) generateAnswerAssit: (AnswerAssistant **)retItem{
    
    AnswerAssistant *assItem = [[AnswerAssistant alloc]init];
    
    AssistanItem *item = nil;
    
    if([self getAssItem:_AssistantItemView1 AssRetItem:&item])
    {
        if(item != nil){
            [assItem.contents addObject:item];
        }
    }
    else{
        return NO;
    }
    
    item = nil;
    
    if([self getAssItem:_AssistantItemView2 AssRetItem:&item])
    {
        if(item != nil){
            [assItem.contents addObject:item];
        }
    }
    else{
        return NO;
    }
    
    item = nil;
    
    if([self getAssItem:_AssistantItemView3 AssRetItem:&item])
    {
        if(item != nil){
            [assItem.contents addObject:item];
        }
    }
    else{
        return NO;
    }
    
    item = nil;
    
    if([self getAssItem:_AssistantItemView4 AssRetItem:&item])
    {
        if(item != nil){
            [assItem.contents addObject:item];
        }
    }
    else{
        return NO;
    }
    
    *retItem = assItem;
    
    return YES;
}

-(BOOL) getAssItem: (nonnull UIView *)view AssRetItem:(AssistanItem **)item{
    
    AssistanItem *retItem = [[AssistanItem alloc]init];
    
    for(UIView *subView in view.subviews)
    {
        if([subView isKindOfClass:[UITextView class]])
        {
            retItem.content = ((UITextView *)subView).text;
        }
        
        if([subView isKindOfClass:[UITextField class]])
        {
            retItem.interval = [((UITextField *)subView).text integerValue];
        }
        
        if([subView isKindOfClass:[UISwitch class]])
        {
            if( !((UISwitch *) subView).isOn )
            {
                return YES;
            }
        }
    }
    
    if(retItem.interval < 0 || retItem.content == nil || retItem.content.length == 0)
    {
        return NO;
    }
    *item = retItem;
    
    return TRUE;
}

@end
