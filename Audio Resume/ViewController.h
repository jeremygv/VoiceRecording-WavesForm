//
//  ViewController.h
//  Audio Resume
//
//  Created by Jeremiah on 28/06/16.
//  Copyright © 2016 Jeremiah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SCSiriWaveformView.h"
#import "BJRangeSliderWithProgress.h"
#import "RETrimControl.h"
#import "TTRangeSlider.h"
@interface ViewController : UIViewController<RETrimControlDelegate,TTRangeSliderDelegate>
{
    BJRangeSliderWithProgress *slide;
}
- (IBAction)btnActionRecord:(id)sender;
- (IBAction)btnActionStop:(id)sender;

- (IBAction)btnActionPlay:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *recordpausebutton;

@property (strong, nonatomic) IBOutlet SCSiriWaveformView *waveformView;



@property (strong, nonatomic) IBOutlet TTRangeSlider *rangeSliderCustom;


- (IBAction)btnActionEdit:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *edit;

@property (strong, nonatomic) IBOutlet BJRangeSliderWithProgress *slider;

@end

