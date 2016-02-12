//
//  PhotoView.h
//

#import <UIKit/UIKit.h>
@protocol ImagePageDelegate;

@interface ImagePage : UIView

@property (nonatomic, weak) id<ImagePageDelegate> delegate;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) NSInteger index;

- (void)prepareForShow;

@end

@protocol ImagePageDelegate

- (void)changeBackgroundAlpha:(CGFloat)alpha;

- (void)closePhoto:(UIImageView *)photo;

@end
