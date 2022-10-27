//
//  EXShazamMedediaItem.m
//
//  Created by Rachel Ruiheng Wang on 10/26/22.
//

#import "EXShazamMediaItem.h"

@implementation EXShazamMediaItem

- (instancetype)initWithItemTitle:(NSMutableString *)title andArtistName:(NSMutableString *)artistName andArtworjURL:(NSURL *)artWorkURL andAppleMusicURL:(NSURL *)appleMusicURL
{
    self = [super init];
    
    if (self)
    {
        self.itemTitle = title;
        self.itemArtistName = artistName;
        self.itemArtworkURL = artWorkURL;
        self.itemAppleMusicURL = appleMusicURL;
    }
    
    return self;
}

- (BOOL)isEqual:(id)other
{
    if(other == self)
    {
        return YES;
    }
    if(!other || ![other isKindOfClass:[self class]])
    {
        return NO;
    }
    
    return [self isEqualToShazamMediaItem:other];
}

- (BOOL)isEqualToShazamMediaItem:(EXShazamMediaItem *)mediaItem
{
    if (self == mediaItem)
    {
        return YES;
    }
    
    if(![(NSString *)[self itemTitle] isEqual:[mediaItem itemTitle]])
    {
        return NO;
    }

    if(![(NSString *)[self itemArtistName] isEqual:[mediaItem itemArtistName]])
    {
        return NO;
    }
    
    if(![(NSString *)[self itemArtworkURL] isEqual:[mediaItem itemArtworkURL]])
    {
        return NO;
    }
    
    return YES;
}

@end
