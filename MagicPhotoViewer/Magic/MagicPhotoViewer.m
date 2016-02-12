//
//  PhotosHelper.m
//

#import "MagicPhotoViewer.h"
#import "ImageViewer.h"

#define RootViewController [[UIApplication sharedApplication] keyWindow].rootViewController

@interface MagicPhotoViewer () <ImageViewerDelegate, ImageViewerDataSource>

@property (nonatomic, strong) ImageViewer *photoController;
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
    self.photoController = [ImageViewer new];
    self.photoController.delegate = self;
    [self.photoController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self.photoController setupInitialState];
    [RootViewController presentViewController:self.photoController animated:NO completion:^{
        [self.photoController openPhotos:photos currentIndex:index close:close];
    }];
}

#pragma mark - <PhotoControllerDataSource>

//- (UIImage *)imageForIndex:(NSInteger)index
//{
//    
//}

@end
