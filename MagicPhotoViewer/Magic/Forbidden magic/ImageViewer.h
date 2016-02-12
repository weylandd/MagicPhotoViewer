//
//  PhotoContentView.h
//

#import "MagicPhotoViewer.h"
@protocol ImageViewerDelegate;
@protocol ImageViewerDataSource;

@interface ImageViewer : UIViewController

@property (nonatomic, weak) id <ImageViewerDelegate> delegate;
@property (nonatomic, weak) id <ImageViewerDataSource> dataSource;

- (void)setupInitialState;

- (void)openPhotos:(NSArray<UIImageView *> *)photos currentIndex:(NSInteger)index close:(CodeBlock)close;

@end

@protocol ImageViewerDelegate <NSObject>

@end

@protocol ImageViewerDataSource <NSObject>

- (UIImage *)imageViewer:(ImageViewer *)imageViewer imageForIndex:(NSInteger)index;

- (UIImageView *)imageViewer:(ImageViewer *)imageViewer imageViewForIndex:(NSInteger)index;

- (NSUInteger)numberOfItemsImageViewer:(ImageViewer *)imageViewer;

@end