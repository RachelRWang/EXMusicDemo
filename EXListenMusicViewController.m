//
//  EXListenMusicViewController.m
//
//  Created by Rachel Ruiheng Wang on 8/29/22.
//

#import "EXListenMusicViewController.h"
#import "AVKit/AVKit.h"
#import "ShazamKit/ShazamKit.h"
#import "EXMusicResources.h"
#import "EXAnimatedViewController.h"
#import "EXShazamMediaItem.h"

API_AVAILABLE(ios(15.0))
@interface EXListenMusicViewController ()<SHSessionDelegate>

@property (nonatomic, strong) SHSession *session;
@property (nonatomic, strong) SHSignatureGenerator *signatureGenerator;
@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, strong) EXShazamMediaItem *curMediaItem;
@property (nonatomic, strong) NSURL *appleMusicURL;
@property (nonatomic, strong) EXAnimatedViewController *animationViewController;

@property (weak, nonatomic) IBOutlet UIImageView *musicImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *listenMusicButton;

@end

@implementation EXListenMusicViewController

IMPL_STRING_CONST(listenMusicLabelTitle, @"Listening to music...")
IMPL_STRING_CONST(listenMusicLabelSubtitle, @"Make sure your device can hear the song clearly.")
IMPL_STRING_CONST(backgroundImageViewDefaultImageName, @"music_background")
IMPL_STRING_CONST(backgroundVideoName, @"wave1")
IMPL_CGFLOAT_CONST(listenMusicButtonCornerRadius, 18.0)

+ (instancetype)initWithBundle:(NSBundle *)bundle
{
    UIStoryboard *musicStoryBoard = [UIStoryboard storyboardWithName:NSStringFromClass(self.class) bundle:bundle];
    EXListenMusicViewController *musicViewController = [musicStoryBoard instantiateInitialViewController];
    
    assert([musicViewController isKindOfClass:EXListenMusicViewController.class]);
    
    if (@available(iOS 15.0, *))
    {
        musicViewController.session = [[SHSession alloc]init];
        musicViewController.session.delegate = musicViewController;
        musicViewController.signatureGenerator = [[SHSignatureGenerator alloc] init];
    }
    
    musicViewController.audioEngine = [[AVAudioEngine alloc]init];

    return musicViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.listenMusicButton.backgroundColor = [UIColor grayColor];
    [self.listenMusicButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.listenMusicButton.layer.cornerRadius = self.class.listenMusicButtonCornerRadius;
    
    self.backgroundImageView.image = [UIImage imageNamed:self.class.backgroundImageViewDefaultImageName inBundle:EXMusicResources.bundle compatibleWithTraitCollection:nil];
    self.animationViewController.view.hidden = NO;
    self.titleLabel.hidden = YES;
    self.artistLabel.hidden = YES;
    self.listenMusicButton.hidden = NO;
    self.musicImageView.hidden = YES;

    // add blur effect on background image
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.view.backgroundColor = [UIColor clearColor];

        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:blurEffectView aboveSubview:self.backgroundImageView];
    }
    
    // set up animation view controller
    self.animationViewController = [[EXAnimatedViewController alloc] initWithVideoName:self.class.backgroundVideoName];
    self.animationViewController.view.frame = CGRectMake(0, 0, self.containerView.bounds.size.width, self.containerView.bounds.size.height);
    [self addChildViewController:self.animationViewController];
    [self.containerView addSubview:self.animationViewController.view];
}

- (IBAction)doScanMusic:(UIButton *)sender
{
    [self.animationViewController playVideo];
    [self startListening];
}

- (IBAction)doCancel:(UIButton *)sender
{
    [self resetUIForPrepareToListen];
}

- (IBAction)doDone:(UIButton *)sender
{
    [self resetUIForPrepareToListen];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)startListening
{
    if (self.audioEngine.isRunning)
    {
        [self.audioEngine stop];
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    @try{
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if(granted)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateUIForListeningMusic];
                });
            
                [audioSession setActive:true withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
                AVAudioInputNode *input = self.audioEngine.inputNode;
                AVAudioFormat *format = [input outputFormatForBus:0];
                [input installTapOnBus:0 bufferSize:1024 format:format block: ^(AVAudioPCMBuffer *buf, AVAudioTime *when) {
                // __'__buf' contains captured audio from the node at time 'when'
                    [self.session matchStreamingBuffer:buf atTime:nil];
                }];
                
                [self.audioEngine prepare];
                @try {
                    [self.audioEngine startAndReturnError:nil];
                } @catch (NSException *exception) {
                    NSLog(@"Audio startException: %@", exception);
                }
            }
            else
            {
                // did not get the permission
            }
        }];
    }
    @catch (NSException * error) {
        NSLog(@"Record Permission Exception: %@", error);
    }
}

- (void)updateForNewMediaItem:(EXShazamMediaItem *)mediaItem
{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED,0), ^{
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:mediaItem.itemArtworkURL];
        if (imageData == nil)
        {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.animationViewController.view.hidden = YES;
            self.musicImageView.hidden = NO;
            self.titleLabel.text = mediaItem.itemTitle;
            self.artistLabel.text = mediaItem.itemArtistName;
            self.musicImageView.image = [UIImage imageWithData:imageData];
            self.backgroundImageView.image = [UIImage imageWithData: imageData];
            self.appleMusicURL = mediaItem.itemAppleMusicURL;
            self.curMediaItem = nil;
        });
    });
}

- (IBAction)doListenOnAppleMusic:(id)sender
{
    [[UIApplication sharedApplication] openURL:self.appleMusicURL options:@{} completionHandler:^(BOOL success){
        if(!success)
        {
            NSLog(@"Fail to open apple music URL");
        }
    }];
}

- (void)updateUIForListeningMusic
{
    self.listenMusicButton.hidden = YES;
    self.titleLabel.hidden = NO;
    self.artistLabel.hidden = NO;
    self.titleLabel.text = self.class.listenMusicLabelTitle;
    self.artistLabel.text = self.class.listenMusicLabelSubtitle;
}

- (void)resetUIForPrepareToListen
{
    if (self.audioEngine.isRunning)
    {
        [self.audioEngine stop];
        [self.audioEngine.inputNode removeTapOnBus:0];
        
        // update UI to default: waiting for detecting music
        self.titleLabel.hidden = YES;
        self.artistLabel.hidden = YES;
        self.listenMusicButton.hidden = NO;
        self.musicImageView.hidden = YES;
        self.animationViewController.view.hidden = NO;
        self.backgroundImageView.image = [UIImage imageNamed:self.class.backgroundImageViewDefaultImageName inBundle:EXMusicResources.bundle compatibleWithTraitCollection:nil];
        [self.animationViewController pauseVideo];
    }
}

#pragma mark -
#pragma mark - SHSessionDelegate
#pragma mark -

- (void)session:(SHSession *)session didFindMatch:(SHMatch *)match
API_AVAILABLE(ios(15.0)) API_AVAILABLE(ios(15.0)){
    EXShazamMediaItem *mediaItem = [[EXShazamMediaItem alloc]init];
    SHMatchedMediaItem *newMatchedMediaItem = match.mediaItems.firstObject;
    mediaItem.itemTitle = newMatchedMediaItem.title;
    mediaItem.itemArtistName = newMatchedMediaItem.artist;
    mediaItem.itemArtworkURL = newMatchedMediaItem.artworkURL;
    mediaItem.itemAppleMusicURL = newMatchedMediaItem.appleMusicURL;

    //update the UI when detecting the new music item
    if (![mediaItem isEqualToShazamMediaItem:self.curMediaItem])
    {
        [self updateForNewMediaItem:mediaItem];
        self.curMediaItem = mediaItem;
    }
}
@end
