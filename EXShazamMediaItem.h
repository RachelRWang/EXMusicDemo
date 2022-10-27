//
//  EXShazamMedediaItem.h
//
//  Created by Rachel Ruiheng Wang on 10/26/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EXShazamMediaItem : NSObject

@property(nonatomic, strong) NSString *itemTitle;
@property(nonatomic, strong) NSString *itemArtistName;
@property(nonatomic, strong) NSURL *itemArtworkURL;
@property(nonatomic, strong) NSURL *itemAppleMusicURL;

- (instancetype)initWithItemTitle:(NSMutableString *)title andArtistName:(NSMutableString *)artistName andArtworjURL:(NSURL *)artWorkURL andAppleMusicURL:(NSURL *)appleMusicURL;
- (BOOL)isEqualToShazamMediaItem:(EXShazamMediaItem *)mediaItem;

@end

NS_ASSUME_NONNULL_END
