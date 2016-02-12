//
//  PhotosHelper.m
//

#import "MagicPhotoViewer.h"
#import "ImageViewer.h"
#import "CustomImageViewer.h"

#define RootViewController [[UIApplication sharedApplication] keyWindow].rootViewController

@interface MagicPhotoViewer () <CustomImageViewerDelegate, CustomImageViewerDataSource>

@property (nonatomic, strong) NSArray *photos;

@end

@implementation MagicPhotoViewer

+ (id)sharedInstance
{
    static MagicPhotoViewer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (void)openPhotos:(NSArray<UIImageView *> *)photos currentIndex:(NSInteger)index close:(CodeBlock)close
{
    self.photos = photos;
    CustomImageViewer *imageViewer = [self _imageViewer];
    [imageViewer setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [imageViewer setupInitialState];
    [RootViewController presentViewController:imageViewer animated:NO completion:^{
        [imageViewer openPhotos:photos currentIndex:index close:close];
    }];
}

#pragma mark - <PhotoControllerDataSource>

- (UIImage *)imageViewer:(ImageViewer *)imageViewer imageForIndex:(NSInteger)index
{
    UIImageView *imageView = self.photos[index];
    return imageView.image;
}

- (UIImageView *)imageViewer:(ImageViewer *)imageViewer imageViewForIndex:(NSInteger)index
{
    UIImageView *imageView = self.photos[index];
    return imageView;
}

- (NSUInteger)numberOfItemsImageViewer:(ImageViewer *)imageViewer
{
    return self.photos.count;
}

#pragma mark - Lazy initialization

- (CustomImageViewer *)_imageViewer
{
    CustomImageViewer *imageViewer = [CustomImageViewer new];
    imageViewer.customDelegate = self;
    imageViewer.customDataSource = self;
    return imageViewer;
}

@end
