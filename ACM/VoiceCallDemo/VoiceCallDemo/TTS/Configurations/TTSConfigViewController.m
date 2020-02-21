//
//  TTSConfigViewController.m
//  TTSDemo
//
//  Created by lappi on 3/16/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#include <math.h>
#import "TTSConfigViewController.h"
#import "SelectionTableViewController.h"
#ifdef AssistantDef
#import <ACM/Assistant.h>
#import <ACM/AnswerAssistant.h>
#endif

enum SettingsSections{
    SettingSection_SynthesisGeneral = 0,
    SettingSection_OnlineSynthesis,
    SettingSectionCount,
    
    
    
};

enum SettingRows_AudioPlayer{
    SettingRow_AudioPlayer_AudioVolume = 0,
    SettingRow_AudioPlayer_Enable_AVAudioSessionManagement,
    SettingRow_AudioPlayer_AVAudiosessionCategory,
    SettingRow_AudioPlayer_AVAudioSessionCategoryOptions,
    SettingRow_AudioPlayerCount,
};

enum SettingRows_SynthesisGeneral{
    SettingRow_SynthesisGeneral_SynthVolume = 0,
    SettingRow_SynthesisGeneral_SynthSpeed,
    SettingRow_SynthesisGeneral_SynthPitch,
    SettingRow_SynthesisGeneralCount
};

enum SettingRows_OnlineSynthesis{
    SettingRow_OnlineSynthesis_Speaker = 0,
    SettingRow_OnlineSynthesisCount
};

enum SettingRows_OfflineSynthesis{
    SettingRow_OfflineAudiomodelManager = 0,
    SettingRow_OfflineSynthesis_AudioEncoding,
    SettingRow_OfflineSynthesis_AppID,
    SettingRow_OfflineXml,
    SettingRow_OfflineSynthesisCount
};

NSString* const EDIT_PROPERTY_ID_PLAYER_VOLUME = @"PLAYER_VOLUME";
NSString* const EDIT_PROPERTY_ID_VOLUME = @"VOL";
NSString* const EDIT_PROPERTY_ID_SPEED = @"SPEED";
NSString* const EDIT_PROPERTY_ID_PITCH = @"PITC";
NSString* const EDIT_PROPERTY_ID_ENABLE_SPEAK = @"SPEAK";
NSString* const EDIT_PROPERTY_ID_ENABLE_FILE_SYNTH = @"READ_FROM_FILE";
NSString* const EDIT_PROPERTY_ID_ENABLE_AUDIO_SESSION_MANAGEMENT = @"ENABLE_AV_MANAGEMENT";
NSString* const EDIT_PROPERTY_ID_ONLINE_TTS_XML = @"ONLINE_TTS_XML";
NSString* const EDIT_PROPERTY_ID_OFFLINE_TTS_XML = @"OFFLINE_TTS_XML";
NSString* const EDIT_PROPERTY_ID_TTS_ONLINE_TIMEOUT = @"ONLINE_TTS_TIMEOUT";
NSString* const EDIT_PROPERTY_ID_OFFLINE_TTS_APPID = @"OFFLINE_ENGINE_APP_ID";

static float SDK_PLAYER_VOLUME = 0.5;

static NSString* setOfflineAppID = @"";

#define KNOWN_ONLINE_SPEAKER_COUNT 5
#define AVAILABLE_AV_CATEGORY_OPTION_COUNT 5
const NSString *AUDIO_SESSION_CATEGORY_OPT_NAMES[] = {@"Mix with others",@"Duck others",@"Allow bluetooth",@"Default to speaker",@"Interrupt spoken, mix others"};

typedef enum SelectionControllerSelectProperty{
    
        SelectionControllerSelectProperty_ONLINE_AUE,
    SelectionControllerSelectProperty_AUDIO_SESSION_CATEGORY_OPTIONS,
    SelectionControllerSelectProperty_AUDIO_SESSION_CATEGORY,
    SelectionControllerSelectProperty_ONLINE_SPEAKER,
    SelectionControllerSelectProperty_OFFLINE_AUDIO_ENCODING,
    SelectionControllerSelectProperty_ONLINE_TTS_THRESHOLD
}SelectionControllerSelectProperty;

__strong static NSString* currentOfflineEnglishModelName;
__strong static NSString* currentOfflineChineseModelName;

@interface TTSConfigViewController ()
@property (nonatomic,strong)NSMutableArray* selectionControllerSelectedIndexes;
@property (nonatomic)SelectionControllerSelectProperty ongoing_multiselection;
@end

@implementation TTSConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)ttsEedNotif:(NSNotification *)notif{
    
    NSLog(@"ttsEedNotif object:%@", notif.object);
    
}

- (void)ttsErrorNotif:(NSNotification *)notif{
    
    NSLog(@"ttsErrorNotif object:%@", notif.object);
}


+(void)loadedAudioModelWithName:(NSString*)modelName forLanguage:(NSString*)language{
    if([language isEqualToString:@"eng"]){
        currentOfflineEnglishModelName = modelName;
    }else{
        currentOfflineChineseModelName = modelName;
    }
}

-(void)processMultiselectResult{
    NSMutableArray* selected = self.selectionControllerSelectedIndexes;
    self.selectionControllerSelectedIndexes = nil;
    switch (self.ongoing_multiselection) {


        case SelectionControllerSelectProperty_ONLINE_SPEAKER:
        {
            if(selected.count > 0){
                self.config.curSpeakerIndex = ((NSNumber *)[selected objectAtIndex:0]).integerValue;
            }

            break;
        }
        default:
            break;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.selectionControllerSelectedIndexes != nil){
        [self processMultiselectResult];
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)displayError:(NSError*)error withTitle:(NSString*)title{
    NSString* errMessage = error.localizedDescription;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:errMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* dismiss = [UIAlertAction actionWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"OK" value:@"" table:@"Localizable"] style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {}];
    [alert addAction:dismiss];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source
#ifdef AssistantDef
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
   return SettingSectionCount;
     
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SettingSection_SynthesisGeneral:
            return SettingRow_SynthesisGeneralCount;
        case SettingSection_OnlineSynthesis:
            return SettingRow_OnlineSynthesisCount;
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
        case SettingSection_SynthesisGeneral:
            [l setText:[[NSBundle mainBundle] localizedStringForKey:@"语音设置" value:@"" table:@"Localizable"]];
            break;
        case SettingSection_OnlineSynthesis:
            [l setText:[[NSBundle mainBundle] localizedStringForKey:@"播报员设置" value:@"" table:@"Localizable"]];
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

-(UITableViewCell*)cellForGeneralSettings:(NSIndexPath* )path table:(UITableView*) tableView{
    switch (path.row) {
        case SettingRow_SynthesisGeneral_SynthVolume:
        {
            // Volume
            SliderTableViewCell* cell = (SliderTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"SLIDER_CELL" forIndexPath:path];
            cell.PROPERTY_ID = EDIT_PROPERTY_ID_VOLUME;
            
            NSInteger currentValue = self.config.speechVolume;
            
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

            NSInteger currentValue = self.config.speechSpeed;
            
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
            
            NSInteger currentValue = self.config.speechPich;
            
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


- (UITableViewCell*)cellForOnlineTTSSettings:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case SettingRow_OnlineSynthesis_Speaker:
        {
            // speaker
            NavigationTableViewCell* cell = (NavigationTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"NAVIGATE_CELL" forIndexPath:indexPath];
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"播报员" value:@"" table:@"Localizable"]];
            /**
            [cell.currentValueLabel setText:[self onlineSpeakerDescriptionFromID:[[[BDSSpeechSynthesizer sharedInstance] getSynthParamforKey:BDS_SYNTHESIZER_PARAM_SPEAKER withError:nil] integerValue]]];
             */
            NSString *player = [self onlineSpeakerDescriptionFromID:self.config.curSpeakerIndex];
            [cell.currentValueLabel setText:player];
            return cell;
        }
        default:
            break;
    }
    return nil;
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
            /**
            [cell.stateSwitch setOn:[[[BDSSpeechSynthesizer sharedInstance] getSynthParamforKey:BDS_SYNTHESIZER_PARAM_ENABLE_AVSESSION_MGMT withError:nil] boolValue]];
             */
            cell.delegate = self;
            cell.PROPERTY_ID = EDIT_PROPERTY_ID_ENABLE_AUDIO_SESSION_MANAGEMENT;
            return cell;
        }
        case SettingRow_AudioPlayer_AVAudiosessionCategory:
        {
            // category
            NavigationTableViewCell* cell = (NavigationTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"NAVIGATE_CELL" forIndexPath:indexPath];
            [cell.nameLabel setText:[[NSBundle mainBundle] localizedStringForKey:@"Category" value:@"" table:@"Localizable"]];
            /**
            [cell.currentValueLabel setText:[BDSSpeechSynthesizer sharedInstance].audioSessionCategory];
             */
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch(indexPath.section){
        case SettingSection_SynthesisGeneral:
            return [self cellForGeneralSettings:indexPath table:tableView];
        case SettingSection_OnlineSynthesis:
            return [self cellForOnlineTTSSettings:tableView IndexPath:indexPath];
    }
    return [tableView dequeueReusableCellWithIdentifier:@"NAVIGATE_CELL" forIndexPath:indexPath];
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
                    
                    NSInteger currentSpeaker = self.config.curSpeakerIndex;
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

#pragma mark - SwitchTableViewCellDelegate
-(void)switchStateChanged:(BOOL)newState forPropertyID:(NSString*)propertyID{
    if([EDIT_PROPERTY_ID_ENABLE_AUDIO_SESSION_MANAGEMENT isEqualToString:propertyID]){
        /**
        NSError* err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[NSNumber numberWithBool:newState] forKey:BDS_SYNTHESIZER_PARAM_ENABLE_AVSESSION_MGMT];
         */
        NSError *err = nil;
        
        if(err){
            [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed to change audio session management status" value:@"" table:@"Localizable"]];
            return;
        }
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    else if([EDIT_PROPERTY_ID_ONLINE_TTS_XML isEqualToString:propertyID]){
        /**
        NSError* err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:(newState?[NSNumber numberWithInt:1]:[NSNumber numberWithInt:0]) forKey:BDS_SYNTHESIZER_PARAM_ONLINE_OPEN_XML];
         */
        NSError* err = nil;
        if(err){
            [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set online xml" value:@"" table:@"Localizable"]];
        }
    }
    else if([EDIT_PROPERTY_ID_OFFLINE_TTS_XML isEqualToString:propertyID]){
        /**
        NSError* err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:(newState?[NSNumber numberWithInt:1]:[NSNumber numberWithInt:0]) forKey:BDS_SYNTHESIZER_PARAM_ETTS_OPEN_XML];
         */
        NSError* err = nil;
        if(err){
            [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set online xml" value:@"" table:@"Localizable"]];
        }
    }
}
#pragma mark - SliderTableViewCellDelegate
-(void)sliderValueChanged:(float)newValue forProperty:(NSString*)propertyID fromSlider:(SliderTableViewCell*)src{
    if([EDIT_PROPERTY_ID_VOLUME isEqualToString:propertyID]){
        
        self.config.speechVolume = newValue;
    }
    else if([EDIT_PROPERTY_ID_SPEED isEqualToString:propertyID]){
        self.config.speechSpeed = newValue;
    }
    else if([EDIT_PROPERTY_ID_PITCH isEqualToString:propertyID]){
        self.config.speechPich = newValue;
    }
}
#pragma mark - InputTableViewCellDelegate
-(void)InputCellChangedValue:(NSString*)newValue forProperty:(NSString*)propertyID
{
    if([EDIT_PROPERTY_ID_TTS_ONLINE_TIMEOUT isEqualToString:propertyID]){
        /**
        NSError* err = [[BDSSpeechSynthesizer sharedInstance] setSynthParam:[NSNumber numberWithFloat:[newValue floatValue]] forKey:BDS_SYNTHESIZER_PARAM_ONLINE_REQUEST_TIMEOUT];
        if(err){
            [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed set online tts timeout" value:@"" table:@"Localizable"]];
        }
         */
    }
    else if([EDIT_PROPERTY_ID_OFFLINE_TTS_APPID isEqualToString:propertyID]){
//        // switching app id requires reloading whole engine
//        NSString* offlineEngineSpeechData = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:offlineSpeakerChineseSpeechDats[setOfflineSpeaker]] ofType:@"dat"];
//        NSString* offlineEngineTextData = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:offlineSpeakerChineseTextDats[setOfflineSpeaker]] ofType:@"dat"];
//        NSString* offlineEngineEnglishSpeechData = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:offlineSpeakerEnglishSpeechDats[setOfflineSpeaker]] ofType:@"dat"];
//        NSString* offlineEngineEnglishTextData = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:offlineSpeakerEnglishTextDats[setOfflineSpeaker]] ofType:@"dat"];
//        NSString* offlineEngineLicenseFile = [[NSBundle mainBundle] pathForResource:@"offline_engine_tmp_license" ofType:@"dat"];
//        
//        NSError* err = [[BDSSpeechSynthesizer sharedInstance] loadOfflineEngine:offlineEngineTextData speechDataPath:offlineEngineSpeechData licenseFilePath:offlineEngineLicenseFile withAppCode:newValue];
//        if(err){
//            [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Offline TTS init failed" value:@"" table:@"Localizable"]];
//            setOfflineSpeaker = OfflineSpeaker_None;
//            return;
//        }
//        err = [[BDSSpeechSynthesizer sharedInstance] loadEnglishDataForOfflineEngine:offlineEngineEnglishTextData speechData:offlineEngineEnglishSpeechData];
//        if(err){
//            [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Offline TTS load English support failed" value:@"" table:@"Localizable"]];
//            return;
//        }
//        setOfflineAppID = newValue;
    }
    [self.tableView reloadData];
}
#endif
@end
