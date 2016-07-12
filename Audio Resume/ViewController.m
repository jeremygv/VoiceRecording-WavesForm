//
//  ViewController.m
//  Audio Resume
//
//  Created by Jeremiah on 28/06/16.
//  Copyright © 2016 Jeremiah. All rights reserved.
//

#import "ViewController.h"
typedef NS_ENUM(NSUInteger, SCSiriWaveformViewInputType) {
    SCSiriWaveformViewInputTypeRecorder,
    SCSiriWaveformViewInputTypePlayer
};
@interface ViewController ()<AVAudioPlayerDelegate,AVAudioRecorderDelegate>
{
    AVAudioRecorder *recorder;
    
    NSURL *trimAudioUrl;
    RETrimControl *trimControl;
    
   AVAudioPlayer *player;
    float seconds;
}
@property (nonatomic, assign) SCSiriWaveformViewInputType selectedInputType;

@end

CGFloat _durationVal;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Set the audio file
  
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    

    NSDictionary *settings = @{AVSampleRateKey:          [NSNumber numberWithFloat: 44100.0],
                               AVFormatIDKey:            [NSNumber numberWithInt: kAudioFormatAppleLossless],
                               AVNumberOfChannelsKey:    [NSNumber numberWithInt: 2],
                               AVEncoderAudioQualityKey: [NSNumber numberWithInt: AVAudioQualityMin]};
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:settings error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
       [self.slider setDisplayMode:BJRSWPAudioRecordMode];
//    trimControl = [[RETrimControl alloc] initWithFrame:CGRectMake(10, (self.view.frame.size.height +100) / 2.0f, 300, 28)];
//    trimControl.length = 200; // 200 seconds
//    trimControl.delegate = self;
//    [self.view addSubview:trimControl];
//    [_slider addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    
    [self.rangeSliderCustom setHidden:YES];
    self.rangeSliderCustom.delegate = self;
    self.rangeSliderCustom.minValue = 0;
    self.rangeSliderCustom.maxValue = 100;
    self.rangeSliderCustom.selectedMinimum =0;
   self.rangeSliderCustom.selectedMaximum = 60;
    self.rangeSliderCustom.minDistance=1;
   
    self.rangeSliderCustom.handleImage = [UIImage imageNamed:@"custom-handle"];
    self.rangeSliderCustom.selectedHandleDiameterMultiplier = 1;
    self.rangeSliderCustom.tintColorBetweenHandles = [UIColor redColor];
    self.rangeSliderCustom.lineHeight = 10;
    NSNumberFormatter *customFormatter = [[NSNumberFormatter alloc] init];
    customFormatter.positiveSuffix = @"S";
    self.rangeSliderCustom.numberFormatterOverride = customFormatter;
    
    
}


-(void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum{
    NSLog(@"min==%f,max ==%f",selectedMinimum,selectedMaximum);

}
#pragma mark-Audio Triming
//- (void)recordDemoFire:(NSTimer*)timer {
//    self.slider.currentProgressValue += 0.6;
//    
//    if (self.slider.currentProgressValue >= self.slider.maxValue) {
//        
//        [self.slider setDisplayMode:BJRSWPAudioSetTrimMode];
//        
//        [timer invalidate];
//    }
//}
//- (void)playDemoFire:(NSTimer*)timer {
//    self.slider.currentProgressValue += 0.2;
//    
//    if (self.slider.currentProgressValue >= self.slider.rightValue) {
//        [self.slider setDisplayMode:BJRSWPAudioSetTrimMode];
//        
//        [timer invalidate];
//    }
//}
//
//-(void)valueChanged
//{
//    NSLog(@"beginvalue==%f",_slider.leftValue);
//      NSLog(@"beginvalue==%f",_slider.rightValue);
//   }

#pragma mark- Siri Wave Methods
- (void)setSelectedInputType:(SCSiriWaveformViewInputType)selectedInputType
{
   _selectedInputType = selectedInputType;
    
    switch (selectedInputType) {
        case SCSiriWaveformViewInputTypeRecorder: {
            [player stop];
            
            [recorder prepareToRecord];
            [recorder setMeteringEnabled:YES];
            [recorder record];
            break;
        }
        case SCSiriWaveformViewInputTypePlayer: {
            [recorder stop];
            
            [player prepareToPlay];
            [player setMeteringEnabled:YES];
            [player play];
            break;
        }
    }
}
- (void)updateMeters
{
    CGFloat normalizedValue;
    switch (_selectedInputType) {
        case SCSiriWaveformViewInputTypeRecorder: {
            [recorder updateMeters];
            normalizedValue = [self _normalizedPowerLevelFromDecibels:[recorder averagePowerForChannel:0]];
          
            break;
        }
        case SCSiriWaveformViewInputTypePlayer: {
            [player updateMeters];
            normalizedValue = [self _normalizedPowerLevelFromDecibels:[player averagePowerForChannel:0]];
            break;
        }
    }
    
    [self.waveformView updateWithLevel:normalizedValue];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnActionRecord:(id)sender {
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
       
        
        CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
        [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        [self.waveformView setWaveColor:[UIColor whiteColor]];
        [self.waveformView setPrimaryWaveLineWidth:3.0f];
        [self.waveformView setSecondaryWaveLineWidth:1.0];
        
        [self setSelectedInputType:SCSiriWaveformViewInputTypeRecorder];

        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        [_recordpausebutton setTitle:@"Pause" forState:UIControlStateNormal];
        
//        [self.slider setDisplayMode:BJRSWPAudioRecordMode];
//        
//        self.slider.currentProgressValue = 0;
//        self.slider.leftValue = 0;
//        self.slider.rightValue = self.slider.maxValue;
//        
//        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(recordDemoFire:) userInfo:nil repeats:YES];
        
    } else {
        
        // Pause recording
        [recorder pause];
        [_recordpausebutton setTitle:@"Record" forState:UIControlStateNormal];
    }
    
    
}

- (IBAction)btnActionStop:(id)sender {
    
    
//    float minutes = floor(recorder.currentTime/60);
//     seconds = recorder.currentTime - (minutes * 60);
    _rangeSliderCustom.maxValue=recorder.currentTime;
//    NSString *time = [[NSString alloc]
//                      initWithFormat:@"%0.0f.%0.0f",
//                      minutes, seconds];
      NSLog(@"Record Time ==%f",recorder.currentTime);
    [recorder stop];
    
  
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (IBAction)btnActionPlay:(id)sender {
    if (!recorder.recording){
        
        
//        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
//        [player setDelegate:self];
//        [player play];
     
       //        _rangeSliderCustom.selectedMaximum = _rangeSliderCustom.maxValue;
        //        trimControl.minValue=0;
//       trimControl.maxValue=player.duration;
        AVAsset *asset = [AVAsset assetWithURL:recorder.url];
        
        AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset
                                                                                presetName:AVAssetExportPresetAppleM4A];
        
        
        CMTime startTime = CMTimeMake((int)(floor(self.rangeSliderCustom.selectedMinimum * 100)), 100);
        CMTime stopTime = CMTimeMake((int)(ceil(self.rangeSliderCustom.selectedMaximum * 100)), 100);
        CGFloat sliderDuration=CMTimeGetSeconds(stopTime)-CMTimeGetSeconds(startTime);
//        _slider.maxValue=sliderDuration;

        CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
        
        exportSession.outputURL = [self uniqueURL];
        trimAudioUrl=exportSession.outputURL;
        exportSession.outputFileType = AVFileTypeAppleM4A;
        exportSession.timeRange = exportTimeRange;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^
         {
             if (AVAssetExportSessionStatusCompleted == exportSession.status)
             {
                 // It worked!
                 player = [[AVAudioPlayer alloc] initWithContentsOfURL:trimAudioUrl error:nil];
                 [player setDelegate:self];
                 [player play];
                 
                 CADisplayLink *displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMetersPlay)];
                 [displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
                   [self setSelectedInputType:SCSiriWaveformViewInputTypePlayer];
                 [self.waveformView setWaveColor:[UIColor whiteColor]];
                 [self.waveformView setPrimaryWaveLineWidth:3.0f];
                 [self.waveformView setSecondaryWaveLineWidth:1.0];
                 

                
                

             }
             else if (AVAssetExportSessionStatusFailed == exportSession.status)
             {
                 // It failed...
             }
         }];

//        [self.slider setDisplayMode:BJRSWPAudioPlayMode];
//        self.slider.currentProgressValue = self.slider.leftValue;
//        
//        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(playDemoFire:) userInfo:nil repeats:YES];
        
    }
}
+(CGFloat *)endValue
{
    CGFloat *maxValues=&_durationVal;
    return maxValues;
}
- (NSURL *)uniqueURL
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"FinalAudio-%d.m4a",arc4random() % 1000]];
    NSURL *fileURL = [NSURL fileURLWithPath:myPathDocs];
    return fileURL;
}


- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [_recordpausebutton setTitle:@"Record" forState:UIControlStateNormal];
    
   
}
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
//                                                    message: @"Finish playing the recording!"
//                                                   delegate: nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];
}
- (void)trimControl:(RETrimControl *)trimControl didChangeLeftValue:(CGFloat)leftValue rightValue:(CGFloat)rightValue
{
    NSLog(@"Left = %f, right = %f", leftValue, rightValue);
}

- (CGFloat)_normalizedPowerLevelFromDecibels:(CGFloat)decibels
{
    if (decibels < -60.0f || decibels == 0.0f) {
        return 0.0f;
    }
    
    return powf((powf(10.0f, 0.05f * decibels) - powf(10.0f, 0.05f * -60.0f)) * (1.0f / (1.0f - powf(10.0f, 0.05f * -60.0f))), 1.0f / 2.0f);
}


- (IBAction)btnActionEdit:(id)sender {
    NSLog(@"SENDer==%@",[sender titleLabel].text);
    if ([[_edit titleLabel].text isEqualToString:@"Edit"]) {
        [_edit setTitle:@"Save" forState:UIControlStateNormal];
         [self.rangeSliderCustom setHidden:NO];
    
    }
    else
    {
            [_edit setTitle:@"Edit" forState:UIControlStateNormal];
         [self.rangeSliderCustom setHidden:YES];
    }
//    _edit.titleLabel.text =@"Save";
    
}
@end
