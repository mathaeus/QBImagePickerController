//
//  QBImagePickerAssetView.m
//  QBImagePickerController
//
//  Created by Katsuma Tanaka on 2013/01/21.
//  Copyright (c) 2013年 Katsuma Tanaka. All rights reserved.
//

#import "QBImagePickerAssetView.h"

// Views
#import "QBImagePickerVideoInfoView.h"

@interface QBImagePickerAssetView ()

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) QBImagePickerVideoInfoView *videoInfoView;
@property (nonatomic, retain) UIImageView *overlayImageView;

@end

@implementation QBImagePickerAssetView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self) {
        /* Initialization */
        // Image View
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:imageView];
        self.imageView = imageView;
        [imageView release];
        
        // Video Info View
        QBImagePickerVideoInfoView *videoInfoView = [[QBImagePickerVideoInfoView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 17, self.bounds.size.width, 17)];
        videoInfoView.hidden = YES;
        videoInfoView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:videoInfoView];
        self.videoInfoView = videoInfoView;
        [videoInfoView release];
        
        // Overlay Image View
        UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        overlayImageView.contentMode = UIViewContentModeScaleAspectFill;
        overlayImageView.clipsToBounds = YES;
        overlayImageView.image = [UIImage imageNamed:@"QBImagePickerController.bundle/overlay.png"];
        overlayImageView.hidden = YES;
        overlayImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:overlayImageView];
        self.overlayImageView = overlayImageView;
        [overlayImageView release];
    }
    
    return self;
}

- (void)setAsset:(ALAsset *)asset
{
    [_asset release];
    _asset = [asset retain];
    
    // Set thumbnail image
    self.imageView.image = [self thumbnail];
    
    if([self.asset valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo) {
        double duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        
        self.videoInfoView.hidden = NO;
        self.videoInfoView.duration = round(duration);
    } else {
        self.videoInfoView.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected
{
    if(self.allowsMultipleSelection) {
        self.overlayImageView.hidden = !selected;
    }
}

- (BOOL)selected
{
    return !self.overlayImageView.hidden;
}

- (void)dealloc
{
    [_asset release];
    
    [_imageView release];
    [_videoInfoView release];
    [_overlayImageView release];
    
    [super dealloc];
}


#pragma mark - Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([self.delegate assetViewCanBeSelected:self] && !self.allowsMultipleSelection) {
        self.imageView.image = [self tintedThumbnail];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([self.delegate assetViewCanBeSelected:self]) {
        self.selected = !self.selected;
        
        if(self.allowsMultipleSelection) {
            self.imageView.image = [self thumbnail];
        } else {
            self.imageView.image = [self tintedThumbnail];
        }
    } else {
        self.selected = !self.selected;
        
        self.imageView.image = [self thumbnail];
    }
    
    [self.delegate assetView:self didChangeSelectionState:self.selected];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.imageView.image = [self thumbnail];
}


#pragma mark - Instance Methods

- (UIImage *)thumbnail
{
    return [UIImage imageWithCGImage:[self.asset thumbnail]];
}

- (UIImage *)tintedThumbnail
{
    UIImage *thumbnail = [self thumbnail];
    
    UIGraphicsBeginImageContext(thumbnail.size);
    
    CGRect rect = CGRectMake(0, 0, thumbnail.size.width, thumbnail.size.height);
    [thumbnail drawInRect:rect];
    
    [[UIColor colorWithWhite:0 alpha:0.5] set];
    UIRectFillUsingBlendMode(rect, kCGBlendModeSourceAtop);
    
    UIImage *tintedThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tintedThumbnail;
}

@end