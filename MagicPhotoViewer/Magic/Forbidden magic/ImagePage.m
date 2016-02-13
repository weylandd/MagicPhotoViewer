//
//  PhotoView.m
//

#import "ImagePage.h"

static const NSInteger MGCDistanceForClose = 50;

@interface ImagePage () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *imageViewCopy;

@property (nonatomic, assign) BOOL isZooming;
@property (nonatomic, assign) BOOL isCanClose;
@property (nonatomic, assign) CGPoint touchStartPoint;

@end

@implementation ImagePage

- (void)prepareForShow
{
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:NO];
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.imageView addGestureRecognizer:doubleTap];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    pan.delegate = self;
    [self.imageView addGestureRecognizer:pan];
}

#pragma mark - Actions

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (!self.image || self.isZooming)
    {
        return;
    }
    if ([self _isScrollScale])
    {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
        return;
    }
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    [self _scrollToTouchPoint:touchPoint];
}

- (void)panGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.userInteractionEnabled = NO;
            self.touchStartPoint = [panGestureRecognizer locationInView:self];
            self.imageViewCopy = [self _copyImageView];
        }
        case UIGestureRecognizerStateChanged:
        {
            [self _panGestureProgress:panGestureRecognizer];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            [self _panGestureEnded:panGestureRecognizer];
            break;
        }
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return [self _gestureRecognizerShouldBegin:gestureRecognizer];
}

#pragma mark - Gestures

- (BOOL)_gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer *)gestureRecognizer;
        CGFloat velocityX = [gesture velocityInView:self].x;
        CGFloat velocityY = [gesture velocityInView:self].y;
        if (ABS(velocityX) < ABS(velocityY) * 2 && [self _isCanClose])
        {
            return YES;
        }
    }
    return NO;
}

- (void)_panGestureProgress:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint touch = [panGestureRecognizer locationInView:self];
    CGFloat distance = ABS(touch.y - self.touchStartPoint.y);
    CGFloat progress = MIN(1, distance / MGCDistanceForClose / 4);
    [self.delegate closeActionWithProgress:progress];
    
    CGPoint displacement = [self _displacementPoints:self.touchStartPoint :touch];
    [self _moveImageViewCopyWithDisplacement:displacement progress:progress];
}

- (void)_panGestureEnded:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint touch = [panGestureRecognizer locationInView:self];
    CGFloat distance = ABS(touch.y - self.touchStartPoint.y);
    if (distance > MGCDistanceForClose)
    {
        [self.delegate closeWithImage:self.imageViewCopy];
    }
    else
    {
        [self.delegate closeFailedAction];
        [self _closeFailedAnimation];
    }
}

#pragma mark - > Layout <

- (void)layoutSubviews
{
    [self _layoutScrollView];
    if (self.image)
    {
        [self _layoutImageView];
        [self _setZoomScales];
    }
}

- (void)_layoutScrollView
{
    CGRect rect = self.bounds;
    self.scrollView.frame = rect;
}

- (void)_layoutImageView
{
    CGRect rect = self.bounds;
    rect.size = [self _sizeForImage:self.imageView.image];
    rect.origin = [self _originForSize:rect.size];
    self.imageView.frame = rect;
    self.scrollView.contentSize = rect.size;
}

#pragma mark - Setters

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
    [self setNeedsLayout];
}

#pragma mark - <UIScrollViewDelegate>

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    self.isAnimated = YES;
//    self.isCanClose = ;
//}
//
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
//{
//    if (scrollView.panGestureRecognizer.numberOfTouches > 1 || !self.isCanClose)
//    {
//        return;
//    }
//    CGFloat offset = ABS(scrollView.contentOffset.y);
//    if (offset > MGCOffsetForClose)
//    {
//        [self _closeAnimation];
//    }
//}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    self.isAnimated = NO;
//    [self.delegate changeBackgroundAlpha:1];
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (scrollView.panGestureRecognizer.numberOfTouches > 1 || !self.isCanClose)
//    {
//        return;
//    }
//    CGFloat offset = ABS(scrollView.contentOffset.y);
//    CGFloat progress = offset / MGCOffsetForProgress;
//    progress = MIN(progress, 1);
//    
//    CGFloat alpha = 1 - progress;
//    alpha += progress * MGCMinBacgroundOpacity;
//    [self.delegate changeBackgroundAlpha:alpha];
//}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self _centerImageView];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view
{
    self.isZooming = YES;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
    self.isZooming = NO;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - Private

//- (CGFloat)_distanceBetweenPoints:(CGPoint)point1 :(CGPoint)point2
//{
//    CGFloat deltaX = point1.x - point2.x;
//    CGFloat deltaY = point1.y - point2.y;
//    return sqrtf(pow(deltaX, 2) + pow(deltaY, 2));
//}

- (void)_closeFailedAnimation
{
    [UIView animateWithDuration:MGCCloseAnimationDuration animations:^{
        self.imageViewCopy.frame = self.imageView.frame;
    } completion:^(BOOL finished) {
        self.imageView.hidden = NO;
        [self.imageViewCopy removeFromSuperview];
        self.imageViewCopy = nil;
        self.userInteractionEnabled = YES;
    }];
}

- (void)_moveImageViewCopyWithDisplacement:(CGPoint)displacement progress:(CGFloat)progress
{
    CGFloat scale = 1 - progress / 5;
    CGRect rect = self.imageView.frame;
    CGFloat cropWidth = CGRectGetWidth(rect) * (1 - scale);
    CGFloat cropHeight = CGRectGetHeight(rect) * (1 - scale);
    
    rect.origin.x += cropWidth / 2;
    rect.origin.y += cropHeight / 2;
    rect.size.width -= cropWidth;
    rect.size.height -= cropHeight;
    rect.origin.x -= displacement.x;
    rect.origin.y -= displacement.y;
    self.imageViewCopy.frame = rect;
}

- (CGPoint)_displacementPoints:(CGPoint)point1 :(CGPoint)point2
{
    CGFloat deltaX = point1.x - point2.x;
    CGFloat deltaY = point1.y - point2.y;
    return CGPointMake(deltaX, deltaY);
}

- (void)_scrollToTouchPoint:(CGPoint)touchPoint
{
    CGRect zoomRect;
    CGFloat scale = self.scrollView.minimumZoomScale / self.scrollView.maximumZoomScale;
    
    CGFloat width = CGRectGetWidth(self.imageView.frame) * scale;
    CGFloat height = CGRectGetHeight(self.imageView.frame) * scale;
    
    zoomRect.origin.x = touchPoint.x - width / 2;
    zoomRect.origin.y = touchPoint.y - height / 2;
    zoomRect.size.width = width;
    zoomRect.size.height = height;
    
    [self.scrollView zoomToRect:zoomRect animated:YES];
}

- (UIImageView *)_copyImageView
{
    CGRect rect = self.imageView.frame;
    rect.origin.y -= self.scrollView.contentOffset.y;
    
    UIImageView *imageView = [UIImageView new];
    [self.containerView addSubview:imageView];
    [self.containerView bringSubviewToFront:imageView];
    imageView.frame = rect;
    imageView.image = self.image;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    self.imageView.hidden = YES;
    return imageView;
}

- (BOOL)_isScrollScale
{
    return self.scrollView.zoomScale != self.scrollView.minimumZoomScale;
}

- (BOOL)_isCanClose
{
    return self.scrollView.contentOffset.y == 0;
}

- (CGSize)_sizeForImage:(UIImage *)image
{
    CGSize size = self.bounds.size;
    CGSize imageSize = image.size;
    CGFloat widthScale = imageSize.width / size.width;
    CGFloat heightScale = imageSize.height / size.height;
    
    if (widthScale > heightScale)
    {
        size.height = imageSize.height / widthScale;
    }
    else
    {
        size.width = imageSize.width / heightScale;
    }
    return size;
}

- (CGPoint)_originForSize:(CGSize)size
{
    CGRect rect = self.bounds;
    CGPoint origin;
    origin.x = (CGRectGetWidth(rect) - size.width) / 2;
    origin.y = (CGRectGetHeight(rect) - size.height) / 2;
    return origin;
}

- (CGPoint)_unsignedOriginForSize:(CGSize)size
{
    CGPoint point = [self _originForSize:size];
    CGFloat x = MAX(0, point.x);
    CGFloat y = MAX(0, point.y);
    return CGPointMake(x, y);
}

- (void)_setZoomScales
{
    self.scrollView.maximumZoomScale = 2;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.zoomScale = 1;
    
    if (!self.image)
    {
        return;
    }
    
    CGSize size = self.bounds.size;
    CGSize imageSize = self.image.size;
    
    CGFloat widthScale = size.width / imageSize.width;
    CGFloat heightScale = size.height / imageSize.height;
    CGFloat minScale = MIN(widthScale, heightScale);
    if (widthScale >= 1 && heightScale >= 1)
    {
        minScale = 1;
    }
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.zoomScale = minScale;
}

-(void)_centerImageView
{
    CGRect rect;
    rect.size = self.scrollView.contentSize;
    rect.origin = [self _unsignedOriginForSize:rect.size];
    self.imageView.frame = rect;
}

#pragma mark - Lazy initialization

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [UIScrollView new];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = YES;
        [self.scrollView addSubview:_imageView];
    }
    return _imageView;
}

@end
