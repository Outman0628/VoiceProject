//
//  EttsModelTableViewCell.m
//  TTSDemo
//
//  Created by lappi on 7/28/16.
//  Copyright © 2016 baidu. All rights reserved.
//

#import "EttsModelTableViewCell.h"
#import "EttsModelViewController.h"
@implementation AudioModel

-(instancetype)init{
    self = [super init];
    [self setModelSize:-1];
    [self setModelDownloaded:0];
    return self;
}

-(void)actionButtonTapped{
    switch (self.status) {
        case AudioModelStatus_notReady:
        case AudioModelStatus_downloadError:
        {
            // start download
            if(!self.modelManager){
                self.modelManager = [BDSTTSEventManager createEventManagerWithName:(NSString*)BDS_ETTS_MODEL_MANAGER_NAME];
            }
            NSMutableDictionary* commandParams = [[NSMutableDictionary alloc] init];
            [commandParams setObject:self forKey:BDS_ETTS_MODEL_MANAGER_CALLBACK_DELEGATE];
            [commandParams setObject:self.modelID forKey:BDS_ETTS_MODEL_MANAGER_MODEL_ID];
            [self.modelManager sendCommand:(NSString*)BDS_ETTS_MODEL_MANAGER_COMMAND_DOWNLOAD withParameters:commandParams];
            self.status = AudioModelStatus_queing;
            [self.modelUI backendUpdated];
            break;
        }
        case AudioModelStatus_queing:
            // do nothing, obscure status between sending download request and getting callback
            break;
        case AudioModelStatus_queued:
        case AudioModelStatus_downloading:
        {
            // stop download
            if(!self.modelManager){
                self.modelManager = [BDSTTSEventManager createEventManagerWithName:(NSString*)BDS_ETTS_MODEL_MANAGER_NAME];
            }
            NSMutableDictionary* commandParams = [[NSMutableDictionary alloc] init];
            [commandParams setObject:self.modelDownloadHandle forKey:BDS_ETTS_MODEL_MANAGER_MODEL_DOWNLOAD_HANDLE];
            [self.modelManager sendCommand:(NSString*)BDS_ETTS_MODEL_MANAGER_COMMAND_DOWNLOAD_STOP withParameters:commandParams];
            self.status = AudioModelStatus_notReady;
            [self.modelUI backendUpdated];
            break;
        }
        case AudioModelStatus_usable:
            // load to offline engine
            [self.delegate loadAudioModelWithName:self.modelName modelLanguage:self.modelLanguage modelTextData:self.modelTextDataPath modelSpeechData:self.modelSpeechDataPath];
            break;
        default:
            break;
    }
}

-(void)stopDownload{
    if(self.status == AudioModelStatus_queing){
        self.status = AudioModelStatus_notReady;    // should stop
    }
    if(!self.modelManager){
        self.modelManager = [BDSTTSEventManager createEventManagerWithName:(NSString*)BDS_ETTS_MODEL_MANAGER_NAME];
    }
    NSMutableDictionary* commandParams = [[NSMutableDictionary alloc] init];
    [commandParams setObject:self.modelDownloadHandle forKey:BDS_ETTS_MODEL_MANAGER_MODEL_DOWNLOAD_HANDLE];
    [self.modelManager sendCommand:(NSString*)BDS_ETTS_MODEL_MANAGER_COMMAND_DOWNLOAD_STOP withParameters:commandParams];
    self.status = AudioModelStatus_notReady;
}

#pragma mark - EttsModelDownloaderDelegate
-(void)modelDownloadQueuedForHandle:(NSString*)downloadHandle
                         forModelID:(NSString*)modelID
                         userParams:(NSDictionary*)params
                              error:(NSError*)err{
    if(self.status == AudioModelStatus_notReady){
        self.status = AudioModelStatus_downloading;
        [self stopDownload];
        return;
    }
    if(err){
        self.status = AudioModelStatus_downloadError;
    }else{
        self.modelDownloadHandle = downloadHandle;
        self.status = AudioModelStatus_queued;
    }
    if(self.modelUI){
        [self.modelUI backendUpdated];
    }
}

-(void)modelDownloadStartedForHandle:(NSString*)downloadHandle{
    if(self.status == AudioModelStatus_notReady){
        self.status = AudioModelStatus_downloading;
        [self stopDownload];
        return;
    }
    self.status = AudioModelStatus_downloading;
    if(self.modelUI){
        [self.modelUI backendUpdated];
    }
}

-(void)modelDownloadProgressForHandle:(NSString*)downloadHandle
                           totalBytes:(NSInteger)total
                      downloadedBytes:(NSInteger)downloaded{
    self.modelSize = total;
    self.modelDownloaded = downloaded;
    if(self.modelUI){
        [self.modelUI backendUpdated];
    }
}

-(void)modelFinishedForHandle:(NSString*)downloadHandle
                    withError:(NSError*)err{
    if(err){
        self.status = AudioModelStatus_downloadError;
    }else{
        self.status = AudioModelStatus_usable;
        [self.delegate modelDownloadSucceeded];
    }
    if(self.modelUI){
        [self.modelUI backendUpdated];
    }
}

-(void)gotRemoteModels:(NSArray*)models error:(NSError*)err{
    
}

-(void)gotDefaultModels:(NSArray*)models error:(NSError*)err{
    
}

-(void)gotLocalModels:(NSArray*)models error:(NSError*)err{
    
}

@end

@implementation EttsModelTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)ActionButtonTap:(id)sender {
    [self.backend actionButtonTapped];
}

-(void)setModelBackend:(AudioModel *)backend{
    if(self.backend && self.backend.modelUI == self){
        [self.backend setModelUI:nil];
    }
    self.backend = backend;
    if(backend){
        [backend setModelUI:self];
    }
    [self backendUpdated];
}

-(void)backendUpdated{
    if(self.backend){
        [self.ModelNameLabel setText:[NSString stringWithFormat:@"%@ - %@ (id:%@)", self.backend.modelName, self.backend.modelSpeaker, self.backend.modelID]];
        if(self.backend.status == AudioModelStatus_usable){
            [self.DownloadProgress setHidden:YES];
            [self.DownloadWait setHidden:YES];
            [self.DownloadWait stopAnimating];
            [self.ActionButton setTitle:@"Load" forState:UIControlStateNormal];
        }else if(self.backend.status == AudioModelStatus_downloadError){
            [self.DownloadProgress setHidden:YES];
            [self.DownloadWait setHidden:YES];
            [self.DownloadWait stopAnimating];
            [self.ActionButton setTitle:@"Try again" forState:UIControlStateNormal];
            [self.ModelNameLabel setText:[NSString stringWithFormat:@"%@ (download error)", self.backend.modelName]];
        }
        else if(self.backend.status == AudioModelStatus_downloading){
            [self.DownloadProgress setHidden:NO];
            [self.DownloadWait setHidden:YES];
            [self.DownloadWait stopAnimating];
            [self.ActionButton setTitle:@"Stop" forState:UIControlStateNormal];
            if(self.backend.modelSize > 0)
                [self.DownloadProgress setProgress:(((float)self.backend.modelDownloaded)/((float)self.backend.modelSize)) animated:YES];
            else{
                [self.DownloadProgress setProgress:0 animated:NO];
            }
        }
        else if(self.backend.status == AudioModelStatus_queued ||
                self.backend.status == AudioModelStatus_queing){
            [self.DownloadProgress setHidden:YES];
            [self.DownloadWait setHidden:NO];
            [self.DownloadWait startAnimating];
            [self.ActionButton setTitle:@"Stop" forState:UIControlStateNormal];
            if(self.backend.modelSize > 0)
                [self.DownloadProgress setProgress:(((float)self.backend.modelDownloaded)/((float)self.backend.modelSize)) animated:YES];
            else{
                [self.DownloadProgress setProgress:0 animated:NO];
            }
        }else{
            // not ready (AudioModelStatus_notReady)
            [self.DownloadProgress setHidden:YES];
            [self.DownloadWait setHidden:YES];
            [self.DownloadWait stopAnimating];
            [self.ActionButton setTitle:@"Download" forState:UIControlStateNormal];
        }
    }
}
@end
