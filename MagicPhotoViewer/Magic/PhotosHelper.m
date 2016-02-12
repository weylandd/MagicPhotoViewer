//
//  PhotosHelper.m
//

#import "PhotosHelper.h"
#import "PhotoController.h"

#define RootViewController [[UIApplication sharedApplication] keyWindow].rootViewController

@interface PhotosHelper () <PhotoControllerDelegate>

@property (nonatomic, strong) PhotoController *photoController;

@end

@implementation PhotosHelper

+ (id)sharedInstance
{
    static PhotosHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (void)openPhotos:(NSArray<UIImageView *> *)photos currentIndex:(NSInteger)index close:(CodeBlock)close
{
    self.photoController = [PhotoController new];
    self.photoController.delegate = self;
    [self.photoController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [RootViewController presentViewController:self.photoController animated:NO completion:^{
        [self.photoController setupInitialState];
        [self.photoController openPhotos:photos currentIndex:index close:close];
    }];
}

#pragma mark - <PhotoControllerDelegate>

- (void)closeController
{
    [self.photoController dismissViewControllerAnimated:NO completion:nil];
}

@end
