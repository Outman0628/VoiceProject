//
//  DAViewController.m
//  VoiceCallDemo
//
//  Created by David on 2020/2/5.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAViewController.h"
#import "DialItemCell.h"
#import "DAOperateCell.h"
#import "DAItem/DAItemDetailViewController.h"
#import <ACM/Assistant.h>

enum DialSettingSectionCount{
    SettingOperation = 0,
    SettingItem,
    SettingSectionCount,
};

@interface DAViewController() <DAOperateCellDelegate, DAItemCellDelegate>
@property NSMutableArray *dialAssistantList;
@end

@implementation DAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Assistant getDialAsistant:^(NSArray * _Nullable dialAssistantList, AssistantCode code) {
        if(code != AssistantOK){
            [self showAlert: [NSString stringWithFormat:@"获取拨打任务失败:%ld", (long)code]];
            return;
        }else{
            self.dialAssistantList = [dialAssistantList mutableCopy];
            [self.tableView reloadData];
        }
    }];
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

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return SettingSectionCount;
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SettingOperation:
            if(_dialAssistantList == nil)
            {
                return 0;
            }
            else{
                return 1;
            }
            
        case SettingItem:
            if(_dialAssistantList == nil)
            {
                return 0;
            }
            else{
                return _dialAssistantList.count;
            }
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
        case SettingOperation:
            [l setText:[[NSBundle mainBundle] localizedStringForKey:@"操作" value:@"" table:@"Localizable"]];
            break;
        case SettingItem:
            [l setText:[[NSBundle mainBundle] localizedStringForKey:@"拨打计划" value:@"" table:@"Localizable"]];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section){
        case SettingOperation:
            //return [tableView dequeueReusableCellWithIdentifier:@"Dial_Schedule_Operate_CELL" forIndexPath:indexPath];
            return [self cellForOperateItem:tableView IndexPath:indexPath];
        case SettingItem:
            return [self cellForDialItem:tableView IndexPath:indexPath];
            
        default:
            break;
    }
    return [tableView dequeueReusableCellWithIdentifier:@"NAVIGATE_CELL" forIndexPath:indexPath];
}

- (UITableViewCell*)cellForOperateItem:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath{
    DAOperateCell *cell = (DAOperateCell *)[tableView dequeueReusableCellWithIdentifier:@"Dial_Schedule_Operate_CELL" forIndexPath:indexPath];
    
    cell.delegate = self;
    return cell;
}

- (UITableViewCell*)cellForDialItem:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath{
    if( indexPath.row < _dialAssistantList.count ){
        DialItemCell *cell = (DialItemCell *)[tableView dequeueReusableCellWithIdentifier:@"ASS_DIAL_ITEM" forIndexPath:indexPath];
        cell.datePicker.date = ((DialAssistant *)_dialAssistantList[indexPath.row]).dialDateTime;
        cell.delegate = self;
        cell.dialAss = _dialAssistantList[indexPath.row];
        return cell;
    }else{
        return nil;
    }
}


#pragma mark - DAOperateCellDelegate
-(void) addNewDialTask{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    DAItemDetailViewController * vc = (DAItemDetailViewController*)[storyboard instantiateViewControllerWithIdentifier:@"DA_ITEM_DETAIL_CONFIG"];
    vc.dialAss = [[DialAssistant alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - DAItemCellDelegate
-(void) jumpToDetail: (NSObject *)dialAss{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    DAItemDetailViewController * vc = (DAItemDetailViewController*)[storyboard instantiateViewControllerWithIdentifier:@"DA_ITEM_DETAIL_CONFIG"];
    vc.dialAss = (DialAssistant *)dialAss;
    [self.navigationController pushViewController:vc animated:YES];
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
