//
//  PhotoView.m
//

#import "ImagePage.h"
#import <AVFoundation/AVFoundation.h>
#define RootView [[UIApplication sharedApplication] keyWindow].rootViewController.view

static const NSInteger MGCOffsetForClose = 50;
static const NSInteger MGCOffsetForProgress = 140;
static const CGFloat MGCMinBacgroundOpacity = 0.3;

@interface ImagePage () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) CGFloat previousScale;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) CGFloat currentScale;
@property (nonatomic, assign) BOOL isZooming;
@property (nonatomic, assign) BOOL isAnimated;

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
}

#pragma mark - Actions

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (!self.image || self.isZooming || self.isAnimated)
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isAnimated = YES;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([self _isScrollScale])
    {
        return;
    }
    CGFloat offset = ABS(scrollView.contentOffset.y);
    if (offset > MGCOffsetForClose)
    {
        [self _closeAnimation];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.isAnimated = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self _isScrollScale])
    {
        return;
    }
    CGFloat offset = ABS(scrollView.contentOffset.y);
    CGFloat progress = offset / MGCOffsetForProgress;
    progress = MIN(progress, 1);
    
    CGFloat alpha = 1 - progress;
    alpha += progress * MGCMinBacgroundOpacity;
    [self.delegate changeBackgroundAlpha:alpha];
}

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

- (void)_closeAnimation
{
    CGRect rect = self.imageView.frame;
    rect.origin.y -= self.scrollView.contentOffset.y;
    [self.imageView removeFromSuperview];
    [RootView addSubview:self.imageView];
    [RootView bringSubviewToFront:self.imageView];
    self.imageView.frame = rect;
    self.hidden = YES;
    [self.delegate closePhoto:self.imageView];
    self.delegate = nil;
}

- (BOOL)_isScrollScale
{
    return self.scrollView.zoomScale != self.scrollView.minimumZoomScale;
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
