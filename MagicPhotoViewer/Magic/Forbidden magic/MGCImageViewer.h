//
//  PhotoContentView.h
//

#import <UIKit/UIKit.h>
@protocol MGCImageViewerDelegate;
@protocol MGCImageViewerDataSource;

@interface MGCImageViewer : UIViewController

@property (nonatomic, weak) id <MGCImageViewerDelegate> delegate;
@property (nonatomic, weak) id <MGCImageViewerDataSource> dataSource;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) NSInteger currentPage;

- (void)openFromViewController:(UIViewController *)viewController withCurrentIndex:(NSInteger)currentIndex;

@end

@protocol MGCImageViewerDelegate <NSObject>
@optional

- (void)imageViewerWillClose:(MGCImageViewer *)imageViewer;

- (void)imageViewer:(MGCImageViewer *)imageViewer prepareImageViewForAnimationWithIndex:(NSInteger)index;

@end

@protocol MGCImageViewerDataSource <NSObject>

- (UIImageView *)imageViewer:(MGCImageViewer *)imageViewer imageViewForAnimationWithIndex:(NSInteger)index;

- (UIImage *)imageViewer:(MGCImageViewer *)imageViewer imageForIndex:(NSInteger)index;

- (NSUInteger)numberOfItemsImageViewer:(MGCImageViewer *)imageViewer;

@end