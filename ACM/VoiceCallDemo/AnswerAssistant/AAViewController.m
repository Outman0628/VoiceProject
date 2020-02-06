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
#import <ACM/AssistantCallback.h>
#import "TTSConfigViewController.h"

@interface AAViewController () <AssistantCallBack>

@property (weak, nonatomic) IBOutlet UIView *rootView;

@property (weak, nonatomic) IBOutlet UIView *AssistantItemView1;

@property (weak, nonatomic) IBOutlet UIView *AssistantItemView2;

@property (weak, nonatomic) IBOutlet UIView *AssistantItemView3;

@property (weak, nonatomic) IBOutlet UIView *AssistantItemView4;

@property (weak, nonatomic) IBOutlet UIButton *auditButton;

@property (weak, nonatomic) IBOutlet UIButton *updateButton;
\
@property (weak, nonatomic) IBOutlet UIButton *settingButton;

@property (weak, nonatomic) IBOutlet UISwitch *assSwitch;

@property AnswerAssistant *answerAss;

@end

@implementation AAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.auditButton.enabled = false;
    self.updateButton.enabled = false;
    self.assSwitch.enabled = false;
    self.settingButton.enabled = false;
    
    [self clearAssView];
    
    [Assistant getAnswerAsistant:^(AnswerAssistant * _Nullable answerAssistant, AssistantCode code) {
        if(code == AssistantOK && answerAssistant != nil){
            self.answerAss = answerAssistant;
            [self initAssView];
        }else{
            [self showAlert: [NSString stringWithFormat:@"获取当前语音助手参数错误:@%ld", (long)code]];
            self.auditButton.enabled = false;
            self.updateButton.enabled = false;
            self.assSwitch.enabled = false;
            self.settingButton.enabled = false;
        }
        
    }];

}

-(void) clearAssView{
    [self ClearAssistantItem:_AssistantItemView1];
    [self ClearAssistantItem:_AssistantItemView2];
    [self ClearAssistantItem:_AssistantItemView3];
    [self ClearAssistantItem:_AssistantItemView4];
}


-(void) initAssView{
    
    self.auditButton.enabled = true;
    self.updateButton.enabled = true;
    self.assSwitch.enabled = true;
    self.settingButton.enabled = true;
    
    for(int i = 0; i < self.answerAss.contents.count; i++){
        if( i == 0){
            [self SetAssistantItem:_AssistantItemView1 AssItem:self.answerAss.contents[i]];
        }else if( i == 1){
            [self SetAssistantItem:_AssistantItemView2 AssItem:self.answerAss.contents[i]];
        }else if( i == 2){
            [self SetAssistantItem:_AssistantItemView3 AssItem:self.answerAss.contents[i]];
        }else if( i == 3){
            [self SetAssistantItem:_AssistantItemView4 AssItem:self.answerAss.contents[i]];
        }
    }
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

- (IBAction)answerAssSetting:(id)sender {
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    TTSConfigViewController * vc = (TTSConfigViewController*)[storyboard instantiateViewControllerWithIdentifier:@"TTS_CONFIG"];
    vc.config = self.answerAss.config;
    [self.navigationController pushViewController:vc animated:YES];
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
        else if([subView isKindOfClass:[UISwitch class]])
        {
            ((UISwitch *)subView).on = false;
        }
    }
}

-(void) SetAssistantItem:(nonnull UIView *)view AssItem:(AssistanItem *)item{
    for(UIView *subView in view.subviews)
    {
        if([subView isKindOfClass:[UITextView class]])
        {
            ((UITextView *)subView).text = item.content;
        }
        else if([subView isKindOfClass:[UITextField class]])
        {
            ((UITextField *)subView).text = [NSString stringWithFormat:@"%ld",(long)item.interval ];
        }
        else if([subView isKindOfClass:[UISwitch class]])
        {
            ((UISwitch *)subView).on = true;
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

- (void)auditResult:(AssistantCode) code Error:(NSError * _Nullable) subCode{
    [self showAlert:[NSString stringWithFormat:@"callback 试听结果 %ld", (long)code]];
    _auditButton.enabled = true;
    _updateButton.enabled = true;
    _assSwitch.enabled = true;
}

- (void)updateAnswerAssistantResult:(AssistantCode) code Error:(NSError * _Nullable) subCode{
    [self showAlert:[NSString stringWithFormat:@"callback 更新语音助手结果 %ld", (long)code]];
    _auditButton.enabled = true;
    _updateButton.enabled = true;
    _assSwitch.enabled = true;
}

- (IBAction)auditAss:(id)sender {
    NSMutableArray *assItems = nil;
    
    if([self generateAnswerAssItem:&assItems])
    {
        _answerAss.contents = assItems;
        [Assistant auditionAnswerAssistant:_answerAss  CallBack:self ];
        _auditButton.enabled = false;
        _updateButton.enabled = false;
        _assSwitch.enabled = false;
    }else
    {
        [self showAlert:@"参数错误请检查"];
    }
    
}

- (IBAction)updateAss:(id)sender {
    NSMutableArray *assItems = nil;
    if([self generateAnswerAssItem:&assItems])
    {
        _answerAss.contents = assItems;
        [Assistant updateAnswerAssistantParam:_answerAss  CallBack:self ];
        _auditButton.enabled = false;
        _updateButton.enabled = false;
        _assSwitch.enabled = false;
    }else
    {
        [self showAlert:@"参数错误请检查"];
    }
}

-(BOOL) generateAnswerAssItem: (NSMutableArray **)items{
    
    NSMutableArray *contents = [NSMutableArray array];
    
    AssistanItem *item = nil;
    
    if([self getAssItem:_AssistantItemView1 AssRetItem:&item])
    {
        if(item != nil){
            [contents addObject:item];
        }
    }
    else{
        return NO;
    }
    
    item = nil;
    
    if([self getAssItem:_AssistantItemView2 AssRetItem:&item])
    {
        if(item != nil){
            [contents addObject:item];
        }
    }
    else{
        return NO;
    }
    
    item = nil;
    
    if([self getAssItem:_AssistantItemView3 AssRetItem:&item])
    {
        if(item != nil){
            [contents addObject:item];
        }
    }
    else{
        return NO;
    }
    
    item = nil;
    
    if([self getAssItem:_AssistantItemView4 AssRetItem:&item])
    {
        if(item != nil){
            [contents addObject:item];
        }
    }
    else{
        return NO;
    }
    
    *items = contents;
    
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
