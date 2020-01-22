//
//  EttsModelViewController.m
//  TTSDemo
//
//  Created by lappi on 7/28/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#import "EttsModelViewController.h"
#import "EttsModelTableViewCell.h"
#import "TTSConfigViewController.h"
#import "BDSSpeechSynthesizer.h"

@interface EttsModelViewController ()
@property (nonatomic,strong)NSMutableArray* bundleModels;
@property (nonatomic,strong)NSMutableDictionary* managerModels;
@end

@implementation EttsModelViewController

-(void)displayError:(NSError*)error withTitle:(NSString*)title{
    NSString* errMessage = error.localizedDescription;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:errMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* dismiss = [UIAlertAction actionWithTitle:[[NSBundle mainBundle] localizedStringForKey:@"OK" value:@"" table:@"Localizable"] style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {}];
    [alert addAction:dismiss];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)loadAudioModelWithName:(NSString*)modelName
                modelLanguage:(NSString*)language
                modelTextData:(NSString*)textDataFile
              modelSpeechData:(NSString*)speechDataFile{
    
    NSError *err = [[BDSSpeechSynthesizer sharedInstance] reinitOfflineEngineData:textDataFile];
    if(err){
        [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed load text data" value:@"" table:@"Localizable"]];
        return; // old value not changed
    }
    err = [[BDSSpeechSynthesizer sharedInstance] reinitOfflineEngineData:speechDataFile];
    if(err){
        [self displayError:err withTitle:[[NSBundle mainBundle] localizedStringForKey:@"Failed load speech data" value:@"" table:@"Localizable"]];
        return;
    }
    [TTSConfigViewController loadedAudioModelWithName:modelName forLanguage:language];
}

-(void)modelDownloadSucceeded{
    [self fetchManagerLocalModels]; // refresh locals
}

- (void)viewDidLoad {
    [super viewDidLoad];
        // Do any additional setup after loading the view.
    [self setBundleModels:[[NSMutableArray alloc] init]];
    
    AudioModel* model = [[AudioModel alloc] init];
    self.viewIsValid = YES;
    [model setModelID:@"bundle_english_female"];
    [model setModelTextDataPath:[[NSBundle mainBundle] pathForResource:@"English_Text" ofType:@"dat"]];
    [model setModelSpeechDataPath:[[NSBundle mainBundle] pathForResource:@"English_Speech_Female" ofType:@"dat"]];
    [model setStatus:AudioModelStatus_usable];
    [model setModelLanguage:@"eng"];
    [model setModelSpeaker:@"f7"];
    [model setModelID:@"--"];
    [model setModelName:@"English female"];
    [model setDelegate:self];
    [self.bundleModels addObject:model];
    
    model = [[AudioModel alloc] init];
    [model setModelID:@"bundle_english_male"];
    [model setModelTextDataPath:[[NSBundle mainBundle] pathForResource:@"English_Text" ofType:@"dat"]];
    [model setModelSpeechDataPath:[[NSBundle mainBundle] pathForResource:@"English_Speech_Male" ofType:@"dat"]];
    [model setStatus:AudioModelStatus_usable];
    [model setModelLanguage:@"eng"];
    [model setModelSpeaker:@"macs"];
    [model setModelID:@"--"];
    [model setModelName:@"English male"];
    [model setDelegate:self];
    [self.bundleModels addObject:model];
    
    model = [[AudioModel alloc] init];
    [model setModelID:@"bundle_chinese_female"];
    [model setModelTextDataPath:[[NSBundle mainBundle] pathForResource:@"Chinese_Text" ofType:@"dat"]];
    [model setModelSpeechDataPath:[[NSBundle mainBundle] pathForResource:@"Chinese_Speech_Female" ofType:@"dat"]];
    [model setStatus:AudioModelStatus_usable];
    [model setModelLanguage:@"chn"];
    [model setModelSpeaker:@"f7"];
    [model setModelID:@"--"];
    [model setModelName:@"Chinese female"];
    [model setDelegate:self];
    [self.bundleModels addObject:model];
    
    model = [[AudioModel alloc] init];
    [model setModelID:@"bundle_chinese_male"];
    [model setModelTextDataPath:[[NSBundle mainBundle] pathForResource:@"Chinese_Text" ofType:@"dat"]];
    [model setModelSpeechDataPath:[[NSBundle mainBundle] pathForResource:@"Chinese_Speech_Male" ofType:@"dat"]];
    [model setStatus:AudioModelStatus_usable];
    [model setModelLanguage:@"chn"];
    [model setModelSpeaker:@"yyjw"];
    [model setModelID:@"--"];
    [model setModelName:@"Chinese male"];
    [model setDelegate:self];
    [self.bundleModels addObject:model];
    
    [self setManagerModels:[[NSMutableDictionary alloc] init]];

    [self.tableView reloadData];
    
    [self fetchManagerLocalModels];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
}
-(void)viewWillDisappear:(BOOL)animated{
    self.viewIsValid = NO;
}

-(void)fetchManagerLocalModels{
    // get model infos from local database
    if(!self.viewIsValid)return;
    if(!self.modelManager){
        self.modelManager = [BDSTTSEventManager createEventManagerWithName:(NSString*)BDS_ETTS_MODEL_MANAGER_NAME];
    }
    NSMutableDictionary* commandParams = [[NSMutableDictionary alloc] init];
    [commandParams setObject:self forKey:BDS_ETTS_MODEL_MANAGER_CALLBACK_DELEGATE];
    [self.modelManager sendCommand:(NSString*)BDS_ETTS_MODEL_MANAGER_COMMAND_GET_LOCAL withParameters:commandParams];
    
}

- (void)checkUpdate:(NSArray *)arr{
    if(!self.modelManager){
        self.modelManager = [BDSTTSEventManager createEventManagerWithName:(NSString*)BDS_ETTS_MODEL_MANAGER_NAME];
    }
    NSMutableDictionary* commandParams = [[NSMutableDictionary alloc] init];
    [commandParams setObject:self forKey:BDS_ETTS_MODEL_MANAGER_CALLBACK_DELEGATE];
    [commandParams setObject:arr forKey:BDS_ETTS_MODEL_MANAGER_MODEL_INFO];
    [self.modelManager sendCommand:(NSString*)BDS_ETTS_MODEL_MANAGER_COMMAND_CHECK_UPDATE withParameters:commandParams];
    
}
-(void)fetchManagerRemoteModels{
    // get list of all models available from server
    if(!self.viewIsValid)return;
    if(!self.modelManager){
        self.modelManager = [BDSTTSEventManager createEventManagerWithName:(NSString*)BDS_ETTS_MODEL_MANAGER_NAME];
    }
    NSMutableDictionary* commandParams = [[NSMutableDictionary alloc] init];
    [commandParams setObject:self forKey:BDS_ETTS_MODEL_MANAGER_CALLBACK_DELEGATE];
    [self.modelManager sendCommand:(NSString*)BDS_ETTS_MODEL_MANAGER_COMMAND_GET_AVAILABLE withParameters:commandParams];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35)];
    [l setBackgroundColor:[UIColor grayColor]];
    switch (section) {
        case 0:
            [l setText:[[NSBundle mainBundle] localizedStringForKey:@"App bundled audio models" value:@"" table:@"Localizable"]];
            break;
        case 1:
            [l setText:[[NSBundle mainBundle] localizedStringForKey:@"Audio models from manager" value:@"" table:@"Localizable"]];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return self.bundleModels.count;
    }else if(section == 1){
        return self.managerModels.count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EttsModelTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ETTS_AUDIO_MODEL_CELL" forIndexPath:indexPath];
    if(indexPath.section == 0){
        [cell setModelBackend:[self.bundleModels objectAtIndex:indexPath.row]];
    }else{
        NSArray* models = [self.managerModels allValues];
        if(indexPath.row < models.count){
            [cell setModelBackend:[models objectAtIndex:indexPath.row]];
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - EttsModelDownloaderDelegate
-(void)modelDownloadQueuedForHandle:(NSString*)downloadHandle
                         forModelID:(NSString*)modelID
                         userParams:(NSDictionary*)params
                              error:(NSError*)err{

}

-(void)modelDownloadStartedForHandle:(NSString*)downloadHandle{

}

-(void)modelDownloadProgressForHandle:(NSString*)downloadHandle
                           totalBytes:(NSInteger)total
                      downloadedBytes:(NSInteger)downloaded{

}

-(void)modelFinishedForHandle:(NSString*)downloadHandle
                    withError:(NSError*)err{

}

-(void)gotRemoteModels:(NSArray*)models error:(NSError*)err{
    if(!self.viewIsValid)return;
    if(err){
        [self displayError:err withTitle:@"Failed get model info from server"];
        return;
    }
    for(NSMutableDictionary *modelInfo in models){
        AudioModel* model = [[AudioModel alloc] init];
        // remote data doesn't have any info about datafile paths etc.
        // This info is generated when model download is requested and can be queried
        // using BDS_ETTS_MODEL_MANAGER_COMMAND_GET_LOCAL.
        // This sample uses BDS_ETTS_MODEL_MANAGER_COMMAND_GET_LOCAL command to
        // refresh models in self.managerModels after succesfull model download
        [model setModelID:[modelInfo objectForKey:BDS_ETTS_MODEL_MANAGER_MODEL_ID]];
        if([self.managerModels objectForKey:model.modelID] != nil){
            continue;   // this model was locally available, don't add.
        }
        [model setStatus:AudioModelStatus_notReady];
        [model setModelLanguage:[modelInfo objectForKey:BDS_ETTS_MODEL_MANAGER_MODEL_LANGUAGE]];
        [model setModelName:[modelInfo objectForKey:BDS_ETTS_MODEL_MANAGER_MODEL_NAME]];
        [model setDelegate:self];
        [self.managerModels setObject:model forKey:model.modelID];
    }
    [self.tableView reloadData];
}
- (void)gotUpdateInfo:(NSArray *)models error:(NSError *)err{
    
    NSLog(@"UpdateInfo:%@", models.description);
    for (NSDictionary *dic in models) {
        
        if ([[dic objectForKey:@"needUpdate"] intValue]) {
            
            
            NSString *modeIdStr = [[NSString alloc] initWithFormat:@"%@", [dic objectForKey:@"id"]];
            if(!self.modelManager){
                self.modelManager = [BDSTTSEventManager createEventManagerWithName:(NSString*)BDS_ETTS_MODEL_MANAGER_NAME];
            }
            NSMutableDictionary* commandParams = [[NSMutableDictionary alloc] init];
            [commandParams setObject:self forKey:BDS_ETTS_MODEL_MANAGER_CALLBACK_DELEGATE];
            [commandParams setObject:modeIdStr forKey:BDS_ETTS_MODEL_MANAGER_MODEL_ID];
            [self.modelManager sendCommand:(NSString*)BDS_ETTS_MODEL_MANAGER_COMMAND_UPDATE withParameters:commandParams];
        }
        
    }
   

}

-(void)gotDefaultModels:(NSArray*)models error:(NSError*)err{

}

-(void)gotLocalModels:(NSArray*)models error:(NSError*)err{
    BOOL fetchRemote = YES;
    if(!self.viewIsValid)return;
    if(err){
        [self displayError:err withTitle:@"Failed get local model info"];
    }else{
        for(NSMutableDictionary *modelInfo in models){
            AudioModel* model = [[AudioModel alloc] init];
            [model setModelID:[modelInfo objectForKey:BDS_ETTS_MODEL_MANAGER_MODEL_ID]];
            
            // Updating an existing
            AudioModel* tmp = [self.managerModels objectForKey:model.modelID];
            if(tmp){
                fetchRemote = NO;   // we are updating existing models, no need to fetch again
                model = tmp;
            }
            [model setModelSpeaker:[modelInfo objectForKey:BDS_ETTS_MODEL_MANAGER_MODEL_SPEAKER]];
            [model setModelTextDataPath:[modelInfo objectForKey:BDS_ETTS_MODEL_MANAGER_MODEL_TEXT_DATA]];
            [model setModelSpeechDataPath:[modelInfo objectForKey:BDS_ETTS_MODEL_MANAGER_MODEL_SPEECH_DATA]];
            BOOL usable = [[modelInfo objectForKey:BDS_ETTS_MODEL_MANAGER_MODEL_USABLE] boolValue];
            [model setStatus:usable?AudioModelStatus_usable:AudioModelStatus_notReady];
            [model setModelLanguage:[modelInfo objectForKey:BDS_ETTS_MODEL_MANAGER_MODEL_LANGUAGE]];
            [model setModelName:[modelInfo objectForKey:BDS_ETTS_MODEL_MANAGER_MODEL_NAME]];
            
            [model setModelSize:[[modelInfo objectForKey:BDS_ETTS_MODEL_MANAGER_MODEL_SIZE] integerValue]];
            [model setModelDownloaded:[[modelInfo objectForKey:BDS_ETTS_MODEL_MANAGER_MODEL_DOWNLOADED] integerValue]];
            [model setDelegate:self];
            if(tmp == nil){
                // added new one
                [self.managerModels setObject:model forKey:model.modelID];
            }
            else{
                // updated existing
                if(model.modelUI){
                    [model.modelUI backendUpdated];
                }
            }
        }
    }
    if(fetchRemote){
        [self.tableView reloadData];
        [self fetchManagerRemoteModels];
    }
}
@end
