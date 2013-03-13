/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import "objc/runtime.h"
#import <QuartzCore/QuartzCore.h>

static char operationKey;

@implementation UIImageView (WebCache)

- (void)setImageForURL:(NSString *)url
{
    [self setImageForURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)setImageForURL:(NSString *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageForURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)setImageForURL:(NSString *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    [self setImageForURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)setImageForURL:(NSString *)url completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageForURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)setImageForURL:(NSString *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageForURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)setImageForURL:(NSString *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageForURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)setImageForURL:(NSString *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock;
{
    [self cancelCurrentImageLoad];
    NSURL* urlObj;
    if ([url isKindOfClass:[NSString class]]) {
     urlObj = [NSURL URLWithString:url];
    }else{
        urlObj = (NSURL*)url;
    }
    self.image = placeholder;
    
    if (urlObj)
    {
        __weak UIImageView *wself = self;
        id<SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadWithURL:urlObj options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
        {
            __strong UIImageView *sself = wself;
            if (!sself) return;
            if (image)
            {
                
                sself.image = image;
                [sself setNeedsLayout];
                
                CATransition *animation = [CATransition animation];
                [animation setDuration:0.2];
                [animation setType:kCATransitionFade];
                [animation setSubtype:kCATransitionFade];
                
                [[sself layer] addAnimation:animation forKey:@"DisplayView"];
            }
            if (completedBlock && finished)
            {
                completedBlock(image, error, cacheType);
            }
        }];
        objc_setAssociatedObject(self, &operationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)cancelCurrentImageLoad
{
    // Cancel in progress downloader from queue
    id<SDWebImageOperation> operation = objc_getAssociatedObject(self, &operationKey);
    if (operation)
    {
        [operation cancel];
        objc_setAssociatedObject(self, &operationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}


@end
