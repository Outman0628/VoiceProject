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
#import "DASubscribersCell.h"
#import <ACM/DialAssistant.h>
#import <ACM/AssistantItem.h>
#import <ACM/Assistant.h>
#import "TTSConfigViewController.h"


enum DialItemDetailCount{
    ItemSettingOperation = 0,
    ItemDatetime,
    ItemSubscribers,
    ItemContent,
    ItemSettingSectionCount,
};

@interface DAItemDetailViewController() <DAItemOperationDelegate, AssistantCallBack, DAItemConentOperate>


@property DASubscribersCell *subscriberCell;
@property DAItemDatetimeCell *dateCell;
@property DAItemOperationCell *operateCell;


@property (weak, nonatomic) IBOutlet UIView *rootView;
@property (strong, nonatomic) IBOutletCollection(UITapGestureRecognizer) NSArray *testRootView;
@end

@implementation DAItemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
   
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)DismissKeboard:(id)sender {
    
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
            return self.dialAss.contents.count;
        case ItemSubscribers:
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
        case ItemSubscribers:
            [l setText:[[NSBundle mainBundle] localizedStringForKey:@"拨打人员列表" value:@"" table:@"Localizable"]];
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
    if(indexPath.section == ItemSubscribers){
        return 80;
    }
    return 40;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section){
        case ItemSettingOperation:
            //return [tableView dequeueReusableCellWithIdentifier:@"DA_Detail_OPERATE_CELL" forIndexPath:indexPath];
            return [self cellForSetting:tableView IndexPath:indexPath];
        case ItemDatetime:
            //return [tableView dequeueReusableCellWithIdentifier:@"DA_DETAIL_DATE_CELL" forIndexPath:indexPath];
            return [self cellForDate:tableView IndexPath:indexPath];
        case ItemContent:
            //return [tableView dequeueReusableCellWithIdentifier:@"DA_VOICE_CONTENT_CELL" forIndexPath:indexPath];
            return [self cellForContent:tableView IndexPath:indexPath];
        case ItemSubscribers:
            return [self cellForSubscribers:tableView IndexPath:indexPath];
        default:
            break;
    }
    return [tableView dequeueReusableCellWithIdentifier:@"NAVIGATE_CELL" forIndexPath:indexPath];
}

- (UITableViewCell*)cellForSubscribers:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath{
    
    if(_subscriberCell == nil){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DA_SUBSCRIBERS_CELL" forIndexPath:indexPath];
        _subscriberCell = (DASubscribersCell *)cell;
        _subscriberCell.subscribersTextView.text = @"";
        for(int i = 0; i < self.dialAss.subscribers.count; i++){
            if( i == 0 ){
                _subscriberCell.subscribersTextView.text = [_subscriberCell.subscribersTextView.text stringByAppendingString:[NSString stringWithFormat:@"%@", self.dialAss.subscribers[i]]];
            }
            else{
            _subscriberCell.subscribersTextView.text = [_subscriberCell.subscribersTextView.text stringByAppendingString:[NSString stringWithFormat:@";%@", self.dialAss.subscribers[i]]];
            }
        }
    }
    return _subscriberCell;
}

//
- (UITableViewCell*)cellForDate:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath{
    
    if(_dateCell == nil){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DA_DETAIL_DATE_CELL" forIndexPath:indexPath];
        _dateCell = (DAItemDatetimeCell *)cell;
        _dateCell.datePicker.date = self.dialAss.dialDateTime;
    }
    return _dateCell;
}

- (UITableViewCell*)cellForSetting:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath{
    
    
    
    if(_operateCell == nil){
        DAItemOperationCell *cell = (DAItemOperationCell *) [tableView dequeueReusableCellWithIdentifier:@"DA_Detail_OPERATE_CELL" forIndexPath:indexPath];
        cell.delegate = self;
        _operateCell = cell;
    }
    return _operateCell;
}

- (UITableViewCell*)cellForContent:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath{
    /*
    if(indexPath.row >= _contentViewList.count){
        DAItemContentCell *cell = (DAItemContentCell *) [tableView dequeueReusableCellWithIdentifier:@"DA_VOICE_CONTENT_CELL" forIndexPath:indexPath];
        [_contentViewList addObject:cell];
        if(indexPath.row < self.dialAss.contents.count){
            AssistanItem *item = self.dialAss.contents[indexPath.row];
            cell.contentTextView.text = item.content;
            cell.intervalTextField.text = [NSString stringWithFormat:@"%ld",(long)item.interval ];
        }
    }
    return _contentViewList[indexPath.row];
     */
    
   
    DAItemContentCell *cell = (DAItemContentCell *) [tableView dequeueReusableCellWithIdentifier:@"DA_VOICE_CONTENT_CELL" forIndexPath:indexPath];

    if(indexPath.row < self.dialAss.contents.count){
        AssistanItem *item = self.dialAss.contents[indexPath.row];
        cell.assItem = item;
        cell.contentTextView.text = item.content;
        cell.intervalTextField.text = [NSString stringWithFormat:@"%ld",(long)item.interval ];
        cell.delegate = self;
    }
    
    return cell;
}



/*
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
    
    _dialAss.dialDateTime = _dateCell.datePicker.date;
    
    return YES;
}
 */
- (BOOL) checkAssItemsValue{
    for(int i = 0; i < _dialAss.contents.count; i++){
        AssistanItem *item = _dialAss.contents[i];
        
        if(item.interval < 0 || item.content == nil || item.content.length == 0)
        {
            return NO;
        }
    }
    
    return YES;
}

-(BOOL) generateSubscribers{
    BOOL ret = YES;
    
    if([self.subscriberCell.subscribersTextView.text containsString:@"用户"])
        return NO;
    
    NSArray *peerList = [self.subscriberCell.subscribersTextView.text componentsSeparatedByString:@";"];
    if(peerList == nil || peerList.count == 0){
        ret = NO;
    }
    
    [_dialAss.subscribers removeAllObjects];
    
    for(int i = 0; i < peerList.count; i++)
    {
        [_dialAss.subscribers addObject:peerList[i]];
    }
    return ret;
}

-(BOOL) generateDate{
     NSDate *date = _dateCell.datePicker.date;
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger interval = [zone secondsFromGMTForDate: date];
    //返回以当前NSDate对象为基准，偏移多少秒后得到的新NSDate对象
    _dialAss.dialDateTime = [date dateByAddingTimeInterval: interval];
    
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
   
    if([self checkAssItemsValue])
    {
        
        [Assistant auditionDialAssistant:_dialAss  CallBack:self ];
        
    }else
    {
        [self showAlert:@"参数错误请检查"];
    }
    
}

-(void) updateAss{
    
   
    if([self checkAssItemsValue] && [self generateSubscribers] && [self generateDate])
    {
        
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

-(void) addContent{
    //[self.tableView reloadData];
   
    AssistanItem *item = [[AssistanItem alloc] init];
    [self.dialAss.contents addObject:item];
   
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dialAss.contents.count -1 inSection:ItemContent];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone]; // 插入方法
    [self.tableView endUpdates];
    
}

////////////////////// from DAItemConentOperate
-(void) delContent: (NSObject *) assItem{
    if(assItem != nil){
        AssistanItem *item = (AssistanItem *)assItem;
        NSInteger index = [self.dialAss.contents indexOfObject:item];
        [self.dialAss.contents removeObject:item];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:ItemContent];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone]; // 插入方法
        [self.tableView endUpdates];
    }
}

////////////////////// from AssistantCallback
- (void)auditResult:(AssistantCode) code Error:(NSError * _Nullable) subCode{
    [self showAlert:[NSString stringWithFormat:@"callback 试听结果 %ld", (long)code]];
}

- (void)updateDialAssistantResult:(AssistantCode) code Error:(NSError * _Nullable) subCode{
    [self showAlert:[NSString stringWithFormat:@"callback 更新结果 %ld", (long)code]];
}

///////////////////////////////// for ShowAlertProtocol
- (void)showAlert:(NSString * _Nonnull)message handle:(void (^_Nullable)(UIAlertAction * _Nullable))handle {
    [self.view endEditing:true];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:handle];
    [alert addAction:action];
    
    [self presentViewController:alert animated:true completion:nil];
}

- (void)showAlertWidthCancel:(NSString * _Nonnull)message handle:(void (^_Nullable)(UIAlertAction * _Nullable))handle {
    [self.view endEditing:true];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:handle];
    [alert addAction:action];
    
    action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:handle];
    [alert addAction:action];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)showAlert:(NSString * _Nonnull)message; {
    [self showAlert:message handle:nil];
}


- (void)showAlertWidthCancel:(NSString * _Nonnull)message Callback:(OKCallback _Nullable)completionBlock {
    [self showAlertWidthCancel:message handle:^(UIAlertAction * _Nullable action) {
        if([action.title isEqualToString:@"OK"])
        {
            completionBlock(true);
        }
    }];
}

@end
