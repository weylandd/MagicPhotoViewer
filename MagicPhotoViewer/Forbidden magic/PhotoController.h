//
//  PhotoContentView.h
//

#import "PhotosHelper.h"
@protocol PhotoControllerDelegate;

@interface PhotoController : UIViewController

@property (nonatomic, weak) id<PhotoControllerDelegate> delegate;

- (void)openPhotos:(NSArray<UIImageView *> *)photos currentIndex:(NSInteger)index close:(CodeBlock)close;

@end

@protocol PhotoControllerDelegate <NSObject>

- (void)closeController;

@end