//
//  PhotoView.h
//

#import <UIKit/UIKit.h>
@protocol MGCImagePageDelegate;

static const CGFloat MGCCloseAnimationDuration = 0.3;

@interface MGCImagePage : UIView

@property (nonatomic, weak) id<MGCImagePageDelegate> delegate;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) NSInteger index;

- (void)prepareForShow;

@end

@protocol MGCImagePageDelegate

- (void)closeActionWithProgress:(CGFloat)progress;

- (void)closeFailedAction;

- (void)closeWithImage:(UIImageView *)image;

@end
