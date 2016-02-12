//
//  PhotoContentView.m
//

#import "ImageViewer.h"
#import "ImagePage.h"

#define RootView [[UIApplication sharedApplication] keyWindow].rootViewController.view

static const NSInteger MGCPhotosOffset = 5;

@interface ImageViewer () <UIScrollViewDelegate, ImagePageDelegate>

@property (nonatomic, strong) NSArray<UIImageView *> *photos;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) CodeBlock closeBlock;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray<ImagePage *> *pages;
@property (nonatomic, assign) BOOL isRotation;

@end

@implementation ImageViewer

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setupInitialState
{
    self.view.alpha = 0;
    self.view.backgroundColor = [UIColor blackColor];
    self.view.userInteractionEnabled = NO;
}

- (void)openPhotos:(NSArray<UIImageView *> *)photos currentIndex:(NSInteger)index close:(CodeBlock)close
{
    self.photos = photos;
    self.currentPage = index;
    self.closeBlock = close;
    [self _layoutScrollView];
    [self _layoutPages];
    [self _openAnimation];
    [self _preparePage:index];
}

#pragma mark - Setters

- (void)setPhotos:(NSArray<UIImageView *> *)photos
{
    _photos = photos;
    [self _createPages];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    for (UIImageView *imageView in self.photos)
    {
        imageView.hidden = NO;
    }
    UIImageView *imageView = self.photos[currentPage];
    imageView.hidden = YES;
}

#pragma mark - > Layout <

- (void)viewWillLayoutSubviews
{
    [self _layoutScrollView];
    [self _layoutPages];
}

- (void)_layoutScrollView
{
    CGRect rect = self.view.bounds;
    rect.origin.x -= MGCPhotosOffset;
    rect.size.width += MGCPhotosOffset * 2;
    self.scrollView.frame = rect;
}

- (void)_layoutPages
{
    __block CGRect rect = self.scrollView.bounds;
    NSInteger width = CGRectGetWidth(rect);
    rect.size.width -= MGCPhotosOffset * 2;
    [self.pages enumerateObjectsUsingBlock:^(ImagePage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        rect.origin.x = width * idx + MGCPhotosOffset;
        obj.frame = rect;
    }];
    
    CGSize size = self.scrollView.bounds.size;
    size.width = self.pages.count * width;
    self.scrollView.contentSize = size;
    [self _scrollToIndex:self.currentPage animated:NO];
    self.isRotation = NO;
}

#pragma mark - Actions

//- (void)leftButtonDidPressed
//{
//    [self _closeAnimationCompleted:^{
//        [self.delegate closeController];
//        if (self.closeBlock)
//        {
//            self.closeBlock();
//        }
//    }];
//}

//- (void)actionButtonTapped
//{
//    UIImageView *image = self.photos[self.currentPage];
//    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[image.image] applicationActivities:nil];
//    [self presentViewController:activityController animated:YES completion:nil];
//}

#pragma mark - Scroll

- (void)_scrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    CGRect rect = self.scrollView.bounds;
    rect.origin.x = index * CGRectGetWidth(rect) + MGCPhotosOffset;
    rect.size.width -= MGCPhotosOffset * 2;
    [self.scrollView scrollRectToVisible:rect animated:animated];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self _calculateNextPage:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isRotation)
    {
        return;
    }
    CGRect rect = self.scrollView.bounds;
    CGFloat originX = scrollView.contentOffset.x;
    NSInteger page = roundf(originX / CGRectGetWidth(rect));
    
    if (page != self.currentPage)
    {
        self.currentPage = page;
        [self _calculateNextPage:scrollView];
    }
}

#pragma mark - Orientation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    self.isRotation = YES;
}

#pragma mark - <ImagePageDelegate>

- (void)closePhoto:(UIImageView *)photo;
{
    [self _closeAnimationWith:photo completed:^{
        [self dismissViewControllerAnimated:NO completion:^{
            if (self.closeBlock)
            {
                self.closeBlock();
            }
        }];
    }];
}

- (void)changeBackgroundAlpha:(CGFloat)alpha
{
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
}

#pragma mark - Animations

- (void)_openAnimation
{
    UIImageView *image = self.photos[self.currentPage];
    CGRect rect = [image convertRect:image.frame toView:nil];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    imageView.image = image.image;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [RootView addSubview:imageView];
    
    CGRect newRect;
    newRect.size = [self _sizeForImage:imageView.image];
    newRect.origin = [self _originForSize:newRect.size];
    
    [UIView animateWithDuration:0.2 animations:^{
        imageView.frame = newRect;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.alpha = 1;
        } completion:^(BOOL finished) {
            [imageView removeFromSuperview];
            self.view.userInteractionEnabled = YES;
        }];
    }];
}

- (void)_closeAnimationWith:(UIImageView *)photo completed:(void(^)())completed
{
    UIImageView *image = self.photos[self.currentPage];
    CGRect rect = [image convertRect:image.frame toView:nil];
    [UIView animateWithDuration:0.2 animations:^{
        photo.frame = rect;
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [photo removeFromSuperview];
        image.hidden = NO;
        if (completed)
        {
            completed();
        }
    }];
}

//- (void)_closeAnimationCompleted:(void(^)())completed
//{
//    UIImageView *image = self.photos[self.currentPage];
//    image.hidden = NO;
//    [UIView animateWithDuration:0.2 animations:^{
//        self.view.alpha = 0;
//    } completion:^(BOOL finished) {
//        if (completed)
//        {
//            completed();
//        }
//    }];
//}

#pragma mark - Status bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Private methods

- (void)_calculateNextPage:(UIScrollView *)scrollView
{
    UIPanGestureRecognizer *pan = [scrollView panGestureRecognizer];
    CGFloat velocity = [pan velocityInView:pan.view].x;
    if (velocity < 0)
    {
        [self _preparePage:self.currentPage + 1];
    }
    else if (velocity > 0)
    {
        [self _preparePage:self.currentPage -1];
    }
}

- (void)_preparePage:(NSInteger)index
{
    if (index < 0 || index >= self.photos.count)
    {
        return;
    }
    ImagePage *page = self.pages[index];
    if (!page.image)
    {
        UIImageView *imageView = self.photos[index];
        page.image = imageView.image;
    }
    [page prepareForShow];
}

- (void)_createPages
{
    if (!self.photos)
    {
        return;
    }
    NSMutableArray *pages = [NSMutableArray new];
    for (NSInteger index = 0; index < self.photos.count; index++)
    {
        ImagePage *page = [ImagePage new];
        page.delegate = self;
        page.index = index;
        [self.scrollView addSubview:page];
        [pages addObject:page];
    }
    self.pages = pages;
}

- (CGSize)_sizeForImage:(UIImage *)image
{
    CGSize size = self.view.bounds.size;
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
    CGRect rect = self.view.bounds;
    CGPoint origin;
    origin.x = CGRectGetMidX(rect) - size.width / 2;
    origin.y = CGRectGetMidY(rect) - size.height / 2;
    return origin;
}

#pragma mark - Lazy initialization

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [UIScrollView new];
        _scrollView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

@end
