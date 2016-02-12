//
//  PhotoContentView.h
//

#import "MagicPhotoViewer.h"
@protocol ImageViewerDelegate;

@interface ImageViewer : UIViewController

@property (nonatomic, weak) id<ImageViewerDelegate> delegate;

- (void)setupInitialState;

- (void)openPhotos:(NSArray<UIImageView *> *)photos currentIndex:(NSInteger)index close:(CodeBlock)close;

@end

@protocol ImageViewerDelegate <NSObject>

@end

@protocol ImageViewerDataSource <NSObject>

//- (UIImage *)imageViewer:() imageForIndex:(NSInteger)index;

@end