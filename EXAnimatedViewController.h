//
//  EXAnimatedViewController.h
//
//  Created by Rachel Ruiheng Wang on 10/27/22.
//

#import <UIKit/UIKit.h>
#import "BBConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface EXAnimatedViewController : UIViewController

- (instancetype)initWithVideoName:(NSString *)videoName;
- (void)playVideo;
- (void)pauseVideo;
@end

NS_ASSUME_NONNULL_END
