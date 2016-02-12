//
//  PhotoView.h
//

#import <UIKit/UIKit.h>
@protocol PhotoViewDelegate;

@interface PhotoPage : UIView

@property (nonatomic, weak) id<PhotoViewDelegate> delegate;
@property (nonatomic, strong) UIImage *image;

@end

@protocol PhotoViewDelegate

- (void)changeBackgroundAlpha:(CGFloat)alpha;

- (void)closePhoto:(UIImageView *)photo;

@end
