//
//  EXAnimatedViewController.m
//
//  Created by Rachel Ruiheng Wang on 10/27/22.
//

#import "EXAnimatedViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "EXMusicResources.h"

@interface EXAnimatedViewController ()

@property (strong, nonatomic) NSString *videoName;
@property (weak, nonatomic) IBOutlet UIView *videoContainerView;
@property (strong, nonatomic) AVPlayer *avPlayer;

@end

@implementation EXAnimatedViewController
IMPL_STRING_CONST(mp4FileType, @"mp4")

- (instancetype)initWithVideoName:(NSString *)videoName
{
    self = [super initWithNibName:NSStringFromClass(EXAnimatedViewController.class) bundle:EXMusicResources.bundle];
    if (self)
    {
        self.videoName = videoName;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *filepath = [EXMusicResources.bundle pathForResource:self.videoName ofType:self.class.mp4FileType];

    NSURL *fileURL = [NSURL fileURLWithPath:filepath];
    
    self.avPlayer = [AVPlayer playerWithURL:fileURL];
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;

    AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    videoLayer.frame = CGRectMake(0, 0, self.videoContainerView.frame.size.width, self.videoContainerView.frame.size.height);
    videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.videoContainerView.layer addSublayer:videoLayer];

    // auto replay the video when reaching the end of it
    objc_declare_weakSelf;
    NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
    [noteCenter addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                            object:nil
                             queue:nil
                        usingBlock:^(NSNotification *note) {
                            [weakSelf.avPlayer seekToTime:kCMTimeZero];
                            [weakSelf.avPlayer play];
                        }];
}

- (void)playVideo
{
    [self.avPlayer play];
}

- (void)pauseVideo
{
    [self.avPlayer seekToTime:CMTimeMake(0, 1)];
    [self.avPlayer pause];
}

@end

