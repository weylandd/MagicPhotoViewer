//
//  PhotoView.h
//

#import <UIKit/UIKit.h>

@protocol PhotoViewDelegate

- (void)photoWillDragging;

- (void)closePhoto:(UIImageView *)photo;

@end

@interface PhotoPage : UIView

@property (nonatomic, weak) id<PhotoViewDelegate> delegate;

@property (nonatomic, strong) UIImage *image;

@end
