//
//  DAItemDetailViewController.m
//  VoiceCallDemo
//
//  Created by David on 2020/2/5.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAItemDetailViewController.h"


enum DialItemDetailCount{
    ItemSettingOperation = 0,
    ItemDatetime,
    ItemContent,
    ItemSettingSectionCount,
};

@interface DAItemDetailViewController()

@end

@implementation DAItemDetailViewController

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
    
    return ItemSettingSectionCount;
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case ItemSettingOperation:
            return 1;
        case ItemDatetime:
            return 1;
        case ItemContent:
            return 3;
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
            return [tableView dequeueReusableCellWithIdentifier:@"DA_Detail_OPERATE_CELL" forIndexPath:indexPath];
        case ItemDatetime:
            return [tableView dequeueReusableCellWithIdentifier:@"DA_DETAIL_DATE_CELL" forIndexPath:indexPath];
        case ItemContent:
            return [tableView dequeueReusableCellWithIdentifier:@"DA_VOICE_CONTENT_CELL" forIndexPath:indexPath];
        default:
            break;
    }
    return [tableView dequeueReusableCellWithIdentifier:@"NAVIGATE_CELL" forIndexPath:indexPath];
}

- (UITableViewCell*)cellForDialItem:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath{
    
    /*
    DialItemCell *cell = (DialItemCell *)[tableView dequeueReusableCellWithIdentifier:@"ASS_DIAL_ITEM" forIndexPath:indexPath];
    
    return cell;
     */
    return nil;
}

@end
