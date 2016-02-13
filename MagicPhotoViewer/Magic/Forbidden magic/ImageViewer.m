//
//  PhotoContentView.m
//

#import "ImageViewer.h"
#import "ImagePage.h"

static const NSInteger MGCPhotosOffset = 5;
static const CGFloat MGCOpenAnimationTime = 0.3;

@interface ImageViewer () <UIScrollViewDelegate, ImagePageDelegate>

@property (nonatomic, assign) NSInteger nextPage;
@property (nonatomic, assign) NSInteger lastPage;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray<ImagePage *> *pages;
@property (nonatomic, assign) BOOL isRotation;

@end

@implementation ImageViewer

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setupInitialState
{
    self.contentView.alpha = 0;
    self.contentView.backgroundColor = [UIColor blackColor];
    self.contentView.userInteractionEnabled = NO;
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

- (void)closeWithImage:(UIImageView *)image
{
    [self _closeAnimationWith:image completed:^{
        [self _dismiss];
    }];
}

- (void)closeActionWithProgress:(CGFloat)progress
{
    CGFloat alpha = 1 - progress;
    self.contentView.alpha = alpha;
}

- (void)closeFailedAction
{
    [UIView animateWithDuration:MGCCloseAnimationDuration animations:^{
        self.contentView.alpha = 1;
    }];
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
    self.scrollView.hidden = YES;
    UIImageView *imageView = [self _copyImageView:image];
    
    CGRect newRect;
    newRect.size = [self _sizeForImage:imageView.image];
    newRect.origin = [self _originForSize:newRect.size];
    
    [UIView animateWithDuration:MGCOpenAnimationTime animations:^{
        imageView.frame = newRect;
        self.contentView.alpha = 1;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
        self.contentView.userInteractionEnabled = YES;
        self.scrollView.hidden = NO;
    }];
}

- (void)_closeAnimationWith:(UIImageView *)photo completed:(void(^)())completed
{
    UIImageView *image = [self.dataSource imageViewer:self imageViewForIndex:self.currentPage];
    CGRect rect = [image convertRect:image.frame toView:nil];
    [UIView animateWithDuration:MGCCloseAnimationDuration animations:^{
        photo.frame = rect;
        self.contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [photo removeFromSuperview];
        image.hidden = NO;
        if (completed)
        {
            completed();
        }
    }];
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
        page.image = [self.dataSource imageViewer:self imageViewForIndex:index].image;
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
        page.containerView = self.view;
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
    [self.view addSubview:imageView];
    [self.view bringSubviewToFront:imageView];
    return imageView;
}

#pragma mark - > Layout <

- (void)viewWillLayoutSubviews
{
    [self _layoutContentView];
    [self _layoutScrollView];
    [self _layoutPages];
}

- (void)_layoutContentView
{
    CGRect rect = self.view.bounds;
    self.contentView.frame = rect;
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

#pragma mark - Lazy initialization

- (UIView *)contentView
{
    if (!_contentView)
    {
        _contentView = [UIView new];
        [self.view addSubview:_contentView];
    }
    return _contentView;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [UIScrollView new];
        _scrollView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        [self.contentView addSubview:_scrollView];
    }
    return _scrollView;
}

@end
