//
//  PhotoContentView.m
//

#import "ImageViewer.h"
#import "ImagePage.h"

#define RootView [[UIApplication sharedApplication] keyWindow].rootViewController.view

static const NSInteger MGCPhotosOffset = 5;
static const CGFloat MGCAnimationTime = 0.2;

@interface ImageViewer () <UIScrollViewDelegate, ImagePageDelegate>

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger nextPage;
@property (nonatomic, assign) NSInteger lastPage;
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
    self.currentPage = index;
    self.closeBlock = close;
    [self _createPages];
    [self _layoutScrollView];
    [self _layoutPages];
    [self _openAnimation];
    [self _preparePage:index];
}

#pragma mark - Setters

- (void)setCurrentPage:(NSInteger)currentPage
{
    UIImageView *lastImageView = [self.dataSource imageViewer:self imageViewForIndex:_currentPage];
    UIImageView *newImageView = [self.dataSource imageViewer:self imageViewForIndex:currentPage];
    _currentPage = currentPage;
    
    lastImageView.hidden = NO;
    newImageView.hidden = YES;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isRotation)
    {
        return;
    }
    CGRect rect = self.scrollView.bounds;
    CGFloat originX = scrollView.contentOffset.x;
    CGFloat page = originX / CGRectGetWidth(rect);
    [self _calculateCurrentPage:page];
    [self _calculateNextPage:page];
    [self _calculateLastPage:page];
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
        [self _dismiss];
    }];
}

- (void)changeBackgroundAlpha:(CGFloat)alpha
{
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
}

#pragma mark - Animations

- (void)_dismiss
{
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.closeBlock)
        {
            self.closeBlock();
        }
    }];
}

- (void)_openAnimation
{
    UIImageView *image = [self.dataSource imageViewer:self imageViewForIndex:self.currentPage];
    if (!image)
    {
        [self _dismiss];
    }
    UIImageView *imageView = [self _copyImageView:image];
    
    CGRect newRect;
    newRect.size = [self _sizeForImage:imageView.image];
    newRect.origin = [self _originForSize:newRect.size];
    
    [UIView animateWithDuration:MGCAnimationTime animations:^{
        imageView.frame = newRect;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:MGCAnimationTime animations:^{
            self.view.alpha = 1;
        } completion:^(BOOL finished) {
            [imageView removeFromSuperview];
            self.view.userInteractionEnabled = YES;
        }];
    }];
}

- (void)_closeAnimationWith:(UIImageView *)photo completed:(void(^)())completed
{
    UIImageView *image = [self.dataSource imageViewer:self imageViewForIndex:self.currentPage];
    CGRect rect = [image convertRect:image.frame toView:nil];
    [UIView animateWithDuration:MGCAnimationTime animations:^{
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

#pragma mark - Calculations

- (void)_calculateCurrentPage:(CGFloat)page
{
    NSInteger currentPage = roundf(page);
    if (currentPage != self.currentPage)
    {
        self.currentPage = currentPage;
    }
}

- (void)_calculateNextPage:(CGFloat)page
{
    NSInteger nextPage = self.nextPage;
    
    if (page > self.currentPage)
    {
        nextPage = ceilf(page);
    }
    else if (page == self.currentPage)
    {
        nextPage = self.currentPage + 1;
    }
    
    if (nextPage != self.nextPage)
    {
        self.nextPage = nextPage;
        if (self.lastPage == nextPage - 2)
        {
            [self _prepareTwoPages];
        }
    }
}

- (void)_calculateLastPage:(CGFloat)page
{
    NSInteger lastPage = self.lastPage;
    if (page < self.currentPage)
    {
        lastPage = floorf(page);
    }
    else if (page == self.currentPage)
    {
        lastPage = self.currentPage - 1;
    }
    
    if (lastPage != self.lastPage)
    {
        self.lastPage = lastPage;
        if (self.nextPage == lastPage + 2)
        {
            [self _prepareTwoPages];
        }
    }
}

#pragma mark - Private methods

- (void)_prepareTwoPages
{
    [self _preparePage:self.currentPage + 1];
    [self _preparePage:self.currentPage - 1];
}

- (void)_preparePage:(NSInteger)index
{
    NSInteger count = [self.dataSource numberOfItemsImageViewer:self];
    if (index < 0 || index >= count)
    {
        return;
    }
    ImagePage *page = self.pages[index];
    if (!page.image)
    {
        page.image = [self.dataSource imageViewer:self imageForIndex:index];
    }
    [page prepareForShow];
}

- (void)_createPages
{
    NSInteger count = [self.dataSource numberOfItemsImageViewer:self];
    NSMutableArray *pages = [NSMutableArray new];
    for (NSInteger index = 0; index < count; index++)
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

- (UIImageView *)_copyImageView:(UIImageView *)image
{
    CGRect rect = [image convertRect:image.frame toView:nil];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    imageView.image = image.image;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [RootView addSubview:imageView];
    return imageView;
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
