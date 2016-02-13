//
//  PhotoView.h
//

#import <UIKit/UIKit.h>
@protocol ImagePageDelegate;

static const CGFloat MGCCloseAnimationDuration = 0.3;

@interface ImagePage : UIView

@property (nonatomic, weak) id<ImagePageDelegate> delegate;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) NSInteger index;

- (void)prepareForShow;

@end

@protocol ImagePageDelegate

- (void)closeActionWithProgress:(CGFloat)progress;

- (void)closeFailedAction;

- (void)closeWithImage:(UIImageView *)image;

@end
