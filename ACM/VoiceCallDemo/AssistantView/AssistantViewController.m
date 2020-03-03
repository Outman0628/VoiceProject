//
//  AssistantViewController.m
//  VoiceCallDemo
//
//  Created by David on 2020/2/20.
//  Copyright © 2020 genetek. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AssistantViewController.h"
#import <ACM/AcmAssistant.h>
#import <AVKit/AVKit.h>"

@interface AssistantViewController()
@property (nonatomic, strong) IBOutlet UIButton *textToAudioBtn;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UIButton *addDialPlan;
@property (nonatomic, strong) IBOutlet UIButton *cancelDialPlan;
@property (nonatomic, strong) IBOutlet UIButton *startAudioToTextBtn;
@property (nonatomic, strong) IBOutlet UIButton *cancelAudioToTextBtn;
@property (nonatomic, strong) IBOutlet UITextView *audioToTextResultView;
@property (nonatomic, strong) IBOutlet UIView *rootView;

@property AVAudioPlayer* player;

@end

@implementation AssistantViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initControls];
}

- (void) initControls{
    
    //self.textView.returnKeyType =UIReturnKeyDone;
    //self.audioToTextResultView.returnKeyType =UIReturnKeyDone;
    
    UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    
    [_rootView addGestureRecognizer:tapGesturRecognizer];
    
   
}

-(void)tapAction:(id)tap
{
    for(UIView *subView in _rootView.subviews)
    {
        [subView resignFirstResponder];
    }
}

- (IBAction)textConvertToAudio:(id)sender {
    VoiceConfig *config = [[VoiceConfig alloc] init];
    if(self.textView.text.length != 0){
        self.textToAudioBtn.enabled = NO;
        
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        NSString *outputFilePath = [documentPath stringByAppendingPathComponent:@"apptest.wav"];
        [AcmAssistant textToAudioFile:self.textView.text FilePath:outputFilePath VoiceConfig:config CallBack:^(AssistantCode code, NSString * _Nullable filePath) {
            if(code == AssistantOK){
                [self showAlert: [NSString stringWithFormat:@"转换成功：文件名字:%@", filePath] ];
                //NSString *wavFile = [self getAndCreatePlayableFileFromPcmData:filePath];
                
                //[self openDocumentIn:wavFile];
                //[self shareLog:[NSURL URLWithString:wavFile]];
                /*
                NSURL *urlFile = [NSURL fileURLWithPath:wavFile];
                NSError *error = nil;
                self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:urlFile error:&error];
                if (error == nil) {
                    [self.player prepareToPlay];
                    [self.player play];
                }
                */
                
                
                [AcmAssistant audioFileToText:filePath CallBack:^(AudioToFileCode code, NSString * _Nullable text) {
                    if(code == AudioToFileCodeOK){
                        self.audioToTextResultView.text = text;
                        [self showAlert:@"转换成功"];
                    }else{
                        self.audioToTextResultView.text = @"转换失败";
                        [self showAlert:[NSString stringWithFormat:@"转换失败:%ld", (long)code]];
                    }
                    
                    self.startAudioToTextBtn.enabled = YES;
                }];
                
                
            }else{
                [self showAlert:[NSString stringWithFormat:@"转换失败:%ld",(long)code]];
            }
             self.textToAudioBtn.enabled = YES;
        }];
        
    }else{
        [self showAlert:@"文本内容不能为空"];
    }
}

- (IBAction)createDialPlan:(id)sender {
    NSDate *planDate = [[NSDate alloc] init];
    [AcmAssistant addRobotDialPlan:planDate PlanId:@"test id" CallBack:^(AssistantCode code) {
        if(code == AssistantOK){
             [self showAlert:@"添加拨打计划成功"];
        }else{
             [self showAlert:[NSString stringWithFormat:@"添加拨打计划失败:%ld",(long)code]];
        }
    }];
}

- (IBAction)cancelDialPlan:(id)sender {
    NSDate *planDate = [[NSDate alloc] init];
    [AcmAssistant addRobotDialPlan:planDate PlanId:@"test id" CallBack:^(AssistantCode code) {
        if(code == AssistantOK){
            [self showAlert:@"取消拨打计划成功"];
        }else{
            [self showAlert:[NSString stringWithFormat:@"添加拨打计划失败:%ld",(long)code]];
        }
    }];
    
    [AcmAssistant cancelRobotDialPlan:@"test id" CallBack:^(AssistantCode code) {
        if(code == AssistantOK){
            [self showAlert:@"取消拨打计划成功"];
        }else{
            [self showAlert:[NSString stringWithFormat:@"取消拨打计划失败:%ld",(long)code]];
        }
    }];
}


- (IBAction)audioFileToText:(id)sender {
    //16k_test.pcm
    self.startAudioToTextBtn.enabled = NO;
    self.audioToTextResultView.text = @"转换中";
    
    //NSString* testFile = [[NSBundle mainBundle] pathForResource:@"16k_test" ofType:@"pcm"];
    NSString* testFile = [[NSBundle mainBundle] pathForResource:@"10s" ofType:@"mp3"];
    
    [AcmAssistant audioFileToText:testFile CallBack:^(AudioToFileCode code, NSString * _Nullable text) {
        if(code == AudioToFileCodeOK){
            self.audioToTextResultView.text = text;
            [self showAlert:@"转换成功"];
        }else{
            self.audioToTextResultView.text = @"转换失败";
            [self showAlert:[NSString stringWithFormat:@"转换失败:%ld", (long)code]];
        }
        
        self.startAudioToTextBtn.enabled = YES;
    }];
    
}

- (IBAction)cancelAudioFileToText:(id)sender {
    [AcmAssistant cancelAudioFileToText];
}

-(void)openDocumentIn:(NSString *)filePath {
    
    UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
    
   // documentController.delegate = self;
    
    //[documentController retain];
    
    documentController.UTI = @"public.wav";//You need to set the UTI (Uniform Type Identifiers) for the documentController object so that it can help the system find the appropriate application to open your document. In this case, it is set to “com.adobe.pdf”, which represents a PDF document. Other common UTIs are "com.apple.quicktime-movie" (QuickTime movies), "public.html" (HTML documents), and "public.jpeg" (JPEG files)
    
    [documentController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    
}

-(void)shareLog:(NSURL *)fileURL{
    
    //在iOS 11不显示分享选项了
    //定义URL数组
    NSArray *urls=@[fileURL];
    //创建分享的类型,注意这里没有常见的微信,朋友圈以QQ等,但是罗列完后,实际运行是相应按钮的,所以可以运行.
    
    UIActivityViewController *activituVC=[[UIActivityViewController alloc]initWithActivityItems:urls applicationActivities:nil];
    NSArray *cludeActivitys=@[UIActivityTypePostToFacebook,
                              UIActivityTypePostToTwitter,
                              UIActivityTypePostToWeibo,
                              UIActivityTypePostToVimeo,
                              UIActivityTypeMessage,
                              UIActivityTypeMail,
                              UIActivityTypeCopyToPasteboard,
                              UIActivityTypePrint,
                              UIActivityTypeAssignToContact,
                              UIActivityTypeSaveToCameraRoll,
                              UIActivityTypeAddToReadingList,
                              UIActivityTypePostToFlickr,
                              UIActivityTypePostToTencentWeibo];
    activituVC.excludedActivityTypes=cludeActivitys;
    
    //显示分享窗口
    [self presentViewController:activituVC animated:YES completion:nil];
    
}

- (NSString *) getAndCreatePlayableFileFromPcmData:(NSString *)filePath
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *wavFilePath = [documentPath stringByAppendingPathComponent:@"test.wav"];
    
   
    
    NSLog(@"PCM file path : %@",filePath); //pcm文件的路径
    
    FILE *fout;
    
    short NumChannels = 1;       //录音通道数
    short BitsPerSample = 16;    //线性采样位数
    int SamplingRate = 16000;     //录音采样率(Hz)
    int numOfSamples = (int)[[NSData dataWithContentsOfFile:filePath] length];
    
    int ByteRate = NumChannels*BitsPerSample*SamplingRate/8;
    short BlockAlign = NumChannels*BitsPerSample/8;
    int DataSize = NumChannels*numOfSamples*BitsPerSample/8;
    int chunkSize = 16;
    int totalSize = 46 + DataSize;
    short audioFormat = 1;
    
    if((fout = fopen([wavFilePath cStringUsingEncoding:1], "w")) == NULL)
    {
        printf("Error opening out file ");
    }
    
    fwrite("RIFF", sizeof(char), 4,fout);
    fwrite(&totalSize, sizeof(int), 1, fout);
    fwrite("WAVE", sizeof(char), 4, fout);
    fwrite("fmt ", sizeof(char), 4, fout);
    fwrite(&chunkSize, sizeof(int),1,fout);
    fwrite(&audioFormat, sizeof(short), 1, fout);
    fwrite(&NumChannels, sizeof(short),1,fout);
    fwrite(&SamplingRate, sizeof(int), 1, fout);
    fwrite(&ByteRate, sizeof(int), 1, fout);
    fwrite(&BlockAlign, sizeof(short), 1, fout);
    fwrite(&BitsPerSample, sizeof(short), 1, fout);
    fwrite("data", sizeof(char), 4, fout);
    fwrite(&DataSize, sizeof(int), 1, fout);
    
    fclose(fout);
    
    NSMutableData *pamdata = [NSMutableData dataWithContentsOfFile:filePath];
    NSFileHandle *handle;
    handle = [NSFileHandle fileHandleForUpdatingAtPath:wavFilePath];
    [handle seekToEndOfFile];
    [handle writeData:pamdata];
    [handle closeFile];
    
    return wavFilePath;
}

NSData* WriteWavFileHeader(long totalAudioLen, long totalDataLen, long longSampleRate,int channels, long byteRate) {
    
    Byte  header[44];
    
    header[0] = 'R';  // RIFF/WAVE header
    header[1] = 'I';
    header[2] = 'F';
    header[3] = 'F';
    
    header[4] = (Byte) (totalDataLen & 0xff);  //file-size (equals file-size - 8)
    header[5] = (Byte) ((totalDataLen >> 8) & 0xff);
    header[6] = (Byte) ((totalDataLen >> 16) & 0xff);
    header[7] = (Byte) ((totalDataLen >> 24) & 0xff);
    
    header[8] = 'W';  // Mark it as type "WAVE"
    header[9] = 'A';
    header[10] = 'V';
    header[11] = 'E';
    header[12] = 'f';  // Mark the format section 'fmt ' chunk
    header[13] = 'm';
    header[14] = 't';
    header[15] = ' ';
    
    header[16] = 16;  // 4 bytes: size of 'fmt ' chunk, Length of format data.  Always 16
    
    header[17] = 0;
    
    header[18] = 0;
    
    header[19] = 0;
    
    header[20] = 1;  // format = 1 ,Wave type PCM
    
    header[21] = 0;
    
    header[22] = (Byte) channels;  // channels
    
    header[23] = 0;
    
    header[24] = (Byte) (longSampleRate & 0xff);
    
    header[25] = (Byte) ((longSampleRate >> 8) & 0xff);
    
    header[26] = (Byte) ((longSampleRate >> 16) & 0xff);
    
    header[27] = (Byte) ((longSampleRate >> 24) & 0xff);
    
    header[28] = (Byte) (byteRate & 0xff);
    
    header[29] = (Byte) ((byteRate >> 8) & 0xff);
    
    header[30] = (Byte) ((byteRate >> 16) & 0xff);
    
    header[31] = (Byte) ((byteRate >> 24) & 0xff);
    
    header[32] = (Byte) (channels * 16 / 8); // block align
    
    header[33] = 0;
    
    header[34] = 16; // bits per sample
    
    header[35] = 0;
    
    header[36] = 'd'; //"data" marker
    
    header[37] = 'a';
    
    header[38] = 't';
    
    header[39] = 'a';
    
    header[40] = (Byte) (totalAudioLen & 0xff);  //data-size (equals file-size - 44).
    
    header[41] = (Byte) ((totalAudioLen >> 8) & 0xff);
    
    header[42] = (Byte) ((totalAudioLen >> 16) & 0xff);
    
    header[43] = (Byte) ((totalAudioLen >> 24) & 0xff);
    
    return [[NSData alloc] initWithBytes:header length:44];;
    
}
@end
