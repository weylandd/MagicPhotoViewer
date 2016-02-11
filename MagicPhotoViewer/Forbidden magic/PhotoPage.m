//
//  PhotoView.m
//

#import "PhotoPage.h"

#define RootView [[UIApplication sharedApplication] keyWindow].rootViewController.view

@interface PhotoPage () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) CGFloat previousScale;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) CGFloat currentScale;

@end

@implementation PhotoPage

#pragma mark - > layout <

- (void)layoutSubviews
{
    [self _layoutScrollView];
    [self _layoutImageView];
}

- (void)_layoutScrollView
{
    CGRect rect = self.bounds;
    self.scrollView.frame = rect;
}

- (void)_layoutImageView
{
    CGRect rect;
    rect.size = [self _sizeForImage:self.imageView.image];
    rect.origin = [self _originForSize:rect.size];
    self.imageView.frame = rect;
}

#pragma mark - setters

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
    CGRect rect = self.bounds;
    rect.size = [self _sizeForImage:self.imageView.image];
    rect.origin = [self _originForSize:rect.size];
    self.imageView.frame = rect;
    self.scrollView.contentSize = rect.size;
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.delegate photoWillDragging];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat offset = ABS(scrollView.contentOffset.y);
    if (offset > 50)
    {
        CGRect rect = self.imageView.frame;
        rect.origin.y -= self.scrollView.contentOffset.y;
        [self.imageView removeFromSuperview];
        [RootView addSubview:self.imageView];
        [RootView bringSubviewToFront:self.imageView];
        self.imageView.frame = rect;
        self.hidden = YES;
        [self.delegate closePhoto:self.imageView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = ABS(scrollView.contentOffset.y);
    if (offset > 140)
    {
        return;
    }
    self.scrollView.backgroundColor = [UIColor colorWithWhite:0 alpha:1 - offset/200];
}

#pragma mark - private

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
    origin.x = CGRectGetMidX(rect) - size.width / 2;
    origin.y = CGRectGetMidY(rect) - size.height / 2;
    return origin;
}

#pragma mark - lazy initialization

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [UIScrollView new];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor blackColor];
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
        [self.scrollView addSubview:_imageView];
    }
    return _imageView;
}

@end
