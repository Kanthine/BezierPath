//
//  AudioViewController.m
//  BezierPath
//
//  Created by 苏沫离 on 2020/9/21.
//

#import "AudioViewController.h"
#import "AudioSpectrumView.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioViewController ()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) AudioSpectrumStripView *spectrumStripView;
@property (strong, nonatomic) AudioSpectrumWaveView *spectrumWaveView;
@end

@implementation AudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.opacity = 0.5;
    gl.frame = self.view.bounds;
    gl.startPoint = CGPointMake(0, 0);
    gl.endPoint = CGPointMake(1, 1);
    gl.colors = @[(__bridge id)[UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.39].CGColor,(__bridge id)[UIColor colorWithRed:53/255.0 green:54/255.0 blue:54/255.0 alpha:1.0].CGColor];
    gl.locations = @[@(0.0),@(0.5f),@(1.0f)];
    
    CAGradientLayer *gl_2 = [CAGradientLayer layer];
    gl_2.frame = self.view.bounds;
    gl_2.startPoint = CGPointMake(0, 0);
    gl_2.endPoint = CGPointMake(1, 1);
    gl_2.colors = @[(__bridge id)[UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:0.0].CGColor,(__bridge id)[UIColor colorWithRed:31/255.0 green:30/255.0 blue:34/255.0 alpha:1.0].CGColor];
    gl_2.locations = @[@(0.0),@(1.0f)];
    [self.view.layer addSublayer:gl];
    [self.view.layer addSublayer:gl_2];
    
    [self.view addSubview:self.spectrumStripView];
    [self.view addSubview:self.spectrumWaveView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.audioPlayer play];
    [self.spectrumStripView resertSpectrumWithDuration:self.audioPlayer.duration];
    [self.spectrumStripView startSpectrum];
    [self.spectrumWaveView startSpectrum];

}

#pragma mark - setter and getters

- (AVAudioPlayer *)audioPlayer{
    if (_audioPlayer == nil) {
        NSString *path = [NSBundle.mainBundle pathForResource:@"卡路里" ofType:@"mp3"];
        NSError *error;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
        _audioPlayer.meteringEnabled = YES;
        NSLog(@"error ==== %@",error);
    }
    return _audioPlayer;
}


- (AudioSpectrumStripView *)spectrumStripView{
    if (_spectrumStripView == nil) {
        _spectrumStripView = [[AudioSpectrumStripView alloc] initWithFrame:CGRectMake(0, 100,CGRectGetWidth(UIScreen.mainScreen.bounds), 50 * 2.0)];
        
        __weak typeof (self) weakSelf = self;
        _spectrumStripView.itemLevelBlock = ^CGFloat{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.audioPlayer updateMeters];
            return [strongSelf.audioPlayer averagePowerForChannel:1];
        };
    }
    return _spectrumStripView;
}

- (AudioSpectrumWaveView *)spectrumWaveView{
    if (_spectrumWaveView == nil) {
        AudioSpectrumWaveView *spectrumView = [[AudioSpectrumWaveView alloc] initWithFrame:CGRectMake(12,250,300, 60)];
        __weak typeof (self) weakSelf = self;
        spectrumView.itemLevelBlock = ^CGFloat{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf.audioPlayer updateMeters];
            return [strongSelf.audioPlayer averagePowerForChannel:1];
        };
        _spectrumWaveView = spectrumView;
        
    }
    return _spectrumWaveView;
}

@end
