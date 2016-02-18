//
//  PhotoContentView.h
//

#import <UIKit/UIKit.h>
@protocol ImageViewerDelegate;
@protocol ImageViewerDataSource;

@interface ImageViewer : UIViewController

@property (nonatomic, weak) id <ImageViewerDelegate> delegate;
@property (nonatomic, weak) id <ImageViewerDataSource> dataSource;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) NSInteger currentPage;

- (void)openFromViewController:(UIViewController *)viewController withCurrentIndex:(NSInteger)currentIndex;

@end

@protocol ImageViewerDelegate <NSObject>
@optional

- (void)imageViewerWillClose:(ImageViewer *)imageViewer;

- (void)imageViewer:(ImageViewer *)imageViewer prepareImageViewForAnimationWithIndex:(NSInteger)index;

@end

@protocol ImageViewerDataSource <NSObject>

- (UIImageView *)imageViewer:(ImageViewer *)imageViewer imageViewForAnimationWithIndex:(NSInteger)index;

- (UIImage *)imageViewer:(ImageViewer *)imageViewer imageForIndex:(NSInteger)index;

- (NSUInteger)numberOfItemsImageViewer:(ImageViewer *)imageViewer;

@end