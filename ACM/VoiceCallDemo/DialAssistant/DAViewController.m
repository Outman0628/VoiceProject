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

enum DialSettingSectionCount{
    SettingOperation = 0,
    SettingItem,
    SettingSectionCount,
};

@interface DAViewController() <DAOperateCellDelegate, DAItemCellDelegate>

@end

@implementation DAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
            return 1;
        case SettingItem:
            return 2;
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
            return [tableView dequeueReusableCellWithIdentifier:@"Dial_Schedule_Operate_CELL" forIndexPath:indexPath];
        case SettingItem:
            return [self cellForDialItem:tableView IndexPath:indexPath];
            
        default:
            break;
    }
    return [tableView dequeueReusableCellWithIdentifier:@"NAVIGATE_CELL" forIndexPath:indexPath];
}

- (UITableViewCell*)cellForDialItem:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath{

    DialItemCell *cell = (DialItemCell *)[tableView dequeueReusableCellWithIdentifier:@"ASS_DIAL_ITEM" forIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}


#pragma mark - DAOperateCellDelegate
-(void) addNewDialTask{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    DAItemDetailViewController * vc = (DAItemDetailViewController*)[storyboard instantiateViewControllerWithIdentifier:@"DA_ITEM_DETAIL_CONFIG"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - DAItemCellDelegate
-(void)jumpToDetail{
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    DAItemDetailViewController * vc = (DAItemDetailViewController*)[storyboard instantiateViewControllerWithIdentifier:@"DA_ITEM_DETAIL_CONFIG"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
