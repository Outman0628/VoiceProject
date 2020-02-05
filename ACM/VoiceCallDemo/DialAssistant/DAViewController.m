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

enum DialSettingSectionCount{
    SettingOperation = 0,
    SettingItem,
    SettingSectionCount,
};

@interface DAViewController()

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
    
    return cell;
}


/*
 #pragma mark - Table view data source
 

 
 -(UITableViewCell*)cellForGeneralSettings:(NSIndexPath* )path table:(UITableView*) tableView{
 switch (path.row) {
 case SettingRow_SynthesisGeneral_SynthVolume:
 {
 // Volume
 SliderTableViewCell* cell = (SliderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SLIDER_CELL" forIndexPath:path];
 cell.PROPERTY_ID = EDIT_PROPERTY_ID_VOLUME;
 
 NSInteger currentValue = self.answerAss.config.speechVolume;
 
 [cell.valueSlider setMaximumValue:15.0];
 [cell.valueSlider setMinimumValue:0.0];
 [cell.valueSlider setValue:(float)currentValue];
 [cell.currentValueLabel setText:[NSString stringWithFormat:@"%ld", (long)currentValue]];
 cell.isContinuous = NO;
 cell.delegate = self;
 [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"音量" value:@"" table:@"Localizable"]];
 return cell;
 }
 case SettingRow_SynthesisGeneral_SynthSpeed:
 {
 // Speed
 SliderTableViewCell* cell = (SliderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SLIDER_CELL" forIndexPath:path];
 cell.PROPERTY_ID = EDIT_PROPERTY_ID_SPEED;
 
 NSInteger currentValue = self.answerAss.config.speechSpeed;
 
 [cell.valueSlider setMaximumValue:9.0];
 [cell.valueSlider setMinimumValue:0.0];
 [cell.valueSlider setValue:(float)currentValue];
 [cell.currentValueLabel setText:[NSString stringWithFormat:@"%ld", (long)currentValue]];
 cell.isContinuous = NO;
 cell.delegate = self;
 [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"语速" value:@"" table:@"Localizable"]];
 return cell;
 }
 case SettingRow_SynthesisGeneral_SynthPitch:
 {
 // Pitch
 SliderTableViewCell* cell = (SliderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SLIDER_CELL" forIndexPath:path];
 cell.PROPERTY_ID = EDIT_PROPERTY_ID_PITCH;
 
 NSInteger currentValue = self.answerAss.config.speechPich;
 
 [cell.valueSlider setMaximumValue:9.0];
 [cell.valueSlider setMinimumValue:0.0];
 [cell.valueSlider setValue:(float)currentValue];
 [cell.currentValueLabel setText:[NSString stringWithFormat:@"%ld", (long)currentValue]];
 cell.isContinuous = NO;
 cell.delegate = self;
 [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"语调" value:@"" table:@"Localizable"]];
 return cell;
 }
 default:
 break;
 }
 return nil;
 }
 
 -(NSString*)onlineSpeakerDescriptionFromID:(NSInteger)speakerID{
 NSArray *speakers = [Assistant getCandidates];
 
 if(speakerID >= 0 && speakerID < speakers.count)
 {
 return speakers[speakerID];
 }
 
 return @"";
 }
 
 


-(NSString*)offlineSpeakerDescriptionFromID:(NSInteger)speakerID{
    switch (speakerID) {
        case 0: return [[NSBundle mainBundle] localizedStringForKey:@"Female" value:@"" table:@"Localizable"];
        case 1: return [[NSBundle mainBundle] localizedStringForKey:@"Male" value:@"" table:@"Localizable"];
        default:
            return [[NSBundle mainBundle] localizedStringForKey:@"Unknown" value:@"" table:@"Localizable"];
    }
}


- (UITableViewCell*)cellForAudioSettings:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case SettingRow_AudioPlayer_AudioVolume:
        {
            // Volume
            SliderTableViewCell* cell = (SliderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SLIDER_CELL" forIndexPath:indexPath];
            cell.PROPERTY_ID = EDIT_PROPERTY_ID_PLAYER_VOLUME;
            [cell.valueSlider setMaximumValue:1.0];
            [cell.valueSlider setMinimumValue:0.0];
            [cell.valueSlider setValue:SDK_PLAYER_VOLUME];
            [cell.currentValueLabel setText:[NSString stringWithFormat:@"%.2f", SDK_PLAYER_VOLUME]];
            cell.isContinuous = YES;
            cell.delegate = self;
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"Volume" value:@"" table:@"Localizable"]];
            return cell;
        }
        case SettingRow_AudioPlayer_Enable_AVAudioSessionManagement:{
            // Enable management
            SwitchTableViewCell* cell = (SwitchTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SWITCH_CELL" forIndexPath:indexPath];
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"Audio session management" value:@"" table:@"Localizable"]];

            cell.delegate = self;
            cell.PROPERTY_ID = EDIT_PROPERTY_ID_ENABLE_AUDIO_SESSION_MANAGEMENT;
            return cell;
        }
        case SettingRow_AudioPlayer_AVAudiosessionCategory:
        {
            // category
            NavigationTableViewCell* cell = (NavigationTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"NAVIGATE_CELL" forIndexPath:indexPath];
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"Category" value:@"" table:@"Localizable"]];
            return cell;
        }
        case SettingRow_AudioPlayer_AVAudioSessionCategoryOptions:
        {
            // category options
            NavigationTableViewCell* cell = (NavigationTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"NAVIGATE_CELL" forIndexPath:indexPath];
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"Audio session category opts" value:@"" table:@"Localizable"]];
            [cell.currentValueLabel setText:@""];
            return cell;
        }
        default:
            break;
    }
    return nil;
}



- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SettingSection_SynthesisGeneral:
        {
            switch (indexPath.row) {
                case SettingRow_SynthesisGeneral_SynthVolume:
                case SettingRow_SynthesisGeneral_SynthSpeed:
                case SettingRow_SynthesisGeneral_SynthPitch:
                    
                    return NO;
                    
                default:
                    return NO;
            }
        }
        case SettingSection_OnlineSynthesis:
            switch (indexPath.row) {
                case SettingRow_OnlineSynthesis_Speaker:
                    return YES;
                default:
                    return NO;
            }
        default:
            return NO;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case SettingSection_SynthesisGeneral:
        {
            switch (indexPath.row) {
                    
                default:
                    break;
            }
            break;
        }
        case SettingSection_OnlineSynthesis:
            switch (indexPath.row) {
                case SettingRow_OnlineSynthesis_Speaker:{
                    // online speaker
                    NSString * storyboardName = @"Main";
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                    SelectionTableViewController * vc = (SelectionTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"SINGLE_OR_MULTISELECT_VIEW"];
                    vc.isMultiSelect = NO;
                    vc.allowNoneSelected = NO;
                    
                    NSInteger currentSpeaker = self.answerAss.config.curSpeakerIndex;
                    NSMutableArray* availableItems = [[NSMutableArray alloc] init];
                    for (NSInteger i = 0; i < [Assistant getCandidates].count; i++) {
                        [availableItems addObject:[self onlineSpeakerDescriptionFromID:i]];
                    }
                    NSMutableArray* selectedItems = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInteger:currentSpeaker], nil];
                    vc.title = [[NSBundle mainBundle] localizedStringForKey:@"播报人员" value:@"" table:@"Localizable"];
                    vc.selectableItemNames = availableItems;
                    vc.selectedItems = selectedItems;
                    self.ongoing_multiselection = SelectionControllerSelectProperty_ONLINE_SPEAKER;
                    self.selectionControllerSelectedIndexes = selectedItems;
                    [self.navigationController pushViewController:vc animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        default:
            break;
    }
}
 
 */


@end
