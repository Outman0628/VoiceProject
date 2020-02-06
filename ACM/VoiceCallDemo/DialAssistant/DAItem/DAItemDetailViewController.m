//
//  DAItemDetailViewController.m
//  VoiceCallDemo
//
//  Created by David on 2020/2/5.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAItemDetailViewController.h"
#import "DAItemOperationCell.h"
#import "DAItemDatetimeCell.h"
#import "DAItemContentCell.h"
#import <ACM/DialAssistant.h>
#import <ACM/AssistantItem.h>
#import <ACM/Assistant.h>
#import "TTSConfigViewController.h"


enum DialItemDetailCount{
    ItemSettingOperation = 0,
    ItemDatetime,
    ItemContent,
    ItemSettingSectionCount,
};

@interface DAItemDetailViewController() <DAItemOperationDelegate, AssistantCallBack>

@property NSMutableArray *contentViewList;
@property (weak, nonatomic) IBOutlet UIView *rootView;
@property (strong, nonatomic) IBOutletCollection(UITapGestureRecognizer) NSArray *testRootView;
@end

@implementation DAItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dialAss = [[DialAssistant alloc] init];
    _contentViewList = [NSMutableArray array];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    /*
     if(self.selectionControllerSelectedIndexes != nil){
     [self processMultiselectResult];
     }
     [self.tableView reloadData];
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)DismissKeboard:(id)sender {
    for(int i = 0; i < _contentViewList.count; i++){
        [self DismissKeboard:_contentViewList[i]];
    }
}



- (void)DismissItemKeyboard:(nonnull UIView *)view{
    for(UIView *subView in view.subviews)
    {
        [subView resignFirstResponder];
    }
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return ItemSettingSectionCount;
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case ItemSettingOperation:
            return 1;
        case ItemDatetime:
            return 1;
        case ItemContent:
            return 1;
        default:
            break;
    }
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35)];
    [l setBackgroundColor:[UIColor grayColor]];
    switch (section) {
        case ItemSettingOperation:
            [l setText:[[NSBundle mainBundle] localizedStringForKey:@"操作" value:@"" table:@"Localizable"]];
            break;
        case ItemDatetime:
            [l setText:[[NSBundle mainBundle] localizedStringForKey:@"时间" value:@"" table:@"Localizable"]];
            break;
        case ItemContent:
            [l setText:[[NSBundle mainBundle] localizedStringForKey:@"机器人语音列表" value:@"" table:@"Localizable"]];
            break;
        default:
            break;
    }
    return l;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == ItemContent){
        return 180;
    }
    return 40;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section){
        case ItemSettingOperation:
            //return [tableView dequeueReusableCellWithIdentifier:@"DA_Detail_OPERATE_CELL" forIndexPath:indexPath];
            return [self cellForSetting:tableView IndexPath:indexPath];
        case ItemDatetime:
            return [tableView dequeueReusableCellWithIdentifier:@"DA_DETAIL_DATE_CELL" forIndexPath:indexPath];
            
        case ItemContent:
            //return [tableView dequeueReusableCellWithIdentifier:@"DA_VOICE_CONTENT_CELL" forIndexPath:indexPath];
            return [self cellForContent:tableView IndexPath:indexPath];
        default:
            break;
    }
    return [tableView dequeueReusableCellWithIdentifier:@"NAVIGATE_CELL" forIndexPath:indexPath];
}

- (UITableViewCell*)cellForSetting:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath{
    
    DAItemOperationCell *cell = (DAItemOperationCell *) [tableView dequeueReusableCellWithIdentifier:@"DA_Detail_OPERATE_CELL" forIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

- (UITableViewCell*)cellForContent:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath{
    
    DAItemContentCell *cell = (DAItemContentCell *) [tableView dequeueReusableCellWithIdentifier:@"DA_VOICE_CONTENT_CELL" forIndexPath:indexPath];
    [_contentViewList addObject:cell];
    return cell;
}


-(BOOL) generateAssItem: (NSMutableArray **)items{
    
    NSMutableArray *contents = [NSMutableArray array];
    
    AssistanItem *item = nil;
    
    for(int i = 0; i < _contentViewList.count; i++){
        if([self getAssItem:_contentViewList[i] AssRetItem:&item])
        {
            if(item != nil){
                [contents addObject:item];
            }
        }
        else{
            return NO;
        }
    }
    
    
    *items = contents;
    
    return YES;
}

-(BOOL) getAssItem: (nonnull DAItemContentCell *)contentCell AssRetItem:(AssistanItem **)item{
    
    AssistanItem *retItem = [[AssistanItem alloc]init];
    
    retItem.content = contentCell.contentTextView.text;
    retItem.interval = [contentCell.intervalTextField.text integerValue];
    
    if(retItem.interval < 0 || retItem.content == nil || retItem.content.length == 0)
    {
        return NO;
    }
    *item = retItem;
    
    return TRUE;
}


///////////////////////// from DAItemOperationDelegate

-(void) auditAss{
    NSMutableArray *assItems = nil;
    if([self generateAssItem:&assItems])
    {
        _dialAss.contents = assItems;
        [Assistant auditionDialAssistant:_dialAss  CallBack:self ];
        
    }else
    {
        [self showAlert:@"参数错误请检查"];
    }
    
}

-(void) updateAss{
    //
    
    NSMutableArray *assItems = nil;
    if([self generateAssItem:&assItems])
    {
        _dialAss.contents = assItems;
        [Assistant updateDialAssistantParam:_dialAss  CallBack:self ];
        
    }else
    {
        [self showAlert:@"参数错误请检查"];
    }
}

-(void) assVoiceSeting{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    TTSConfigViewController * vc = (TTSConfigViewController*)[storyboard instantiateViewControllerWithIdentifier:@"TTS_CONFIG"];
    vc.config = self.dialAss.config;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) addContent{}

////////////////////// from AssistantCallback
- (void)auditResult:(AssistantCode) code Error:(NSError * _Nullable) subCode{
    [self showAlert:[NSString stringWithFormat:@"callback 试听结果 %ld", (long)code]];
}

- (void)updateDialAssistantResult:(AssistantCode) code Error:(NSError * _Nullable) subCode{
    [self showAlert:[NSString stringWithFormat:@"callback 更新结果 %ld", (long)code]];
}

@end
