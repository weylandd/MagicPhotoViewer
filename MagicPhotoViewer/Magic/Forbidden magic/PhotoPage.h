//
//  PhotoView.h
//

#import <UIKit/UIKit.h>
@protocol PhotoViewDelegate;

@interface PhotoPage : UIView

@property (nonatomic, weak) id<PhotoViewDelegate> delegate;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) NSInteger index;

- (void)prepareForShow;

@end

@protocol PhotoViewDelegate

- (void)changeBackgroundAlpha:(CGFloat)alpha;

- (void)closePhoto:(UIImageView *)photo;

@end
