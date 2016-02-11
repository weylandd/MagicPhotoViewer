//
//  PhotoContentView.m
//

#import "PhotoController.h"
#import "PhotoPage.h"

#define RootView [[UIApplication sharedApplication] keyWindow].rootViewController.view

static const NSInteger kPhotosOffset = 5;

@interface PhotoController () <UIScrollViewDelegate, PhotoViewDelegate>

@property (nonatomic, strong) NSArray<UIImageView *> *photos;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) CodeBlock closeBlock;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray<PhotoPage *> *pages;
@property (nonatomic, assign) BOOL isRotation;

@end

@implementation PhotoController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)openPhotos:(NSArray<UIImageView *> *)photos currentIndex:(NSInteger)index close:(CodeBlock)close
{
    self.photos = photos;
    self.currentPage = index;
    self.closeBlock = close;
    [self _layoutScrollView];
    [self _layoutPages];
    [self _openAnimation];
}

#pragma mark - setters UITableView

- (void)setPhotos:(NSArray<UIImageView *> *)photos
{
    _photos = photos;
    [self _createPages];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    [self.photos enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = NO;
    }];
    UIImageView *image = self.photos[self.currentPage];
    image.hidden = YES;
}

#pragma mark - > layout <

- (void)viewWillLayoutSubviews
{
    [self _layoutScrollView];
    [self _layoutPages];
}

- (void)_layoutScrollView
{
    CGRect rect = self.view.bounds;
    rect.origin.x -= kPhotosOffset;
    rect.size.width += kPhotosOffset * 2;
    self.scrollView.frame = rect;
}

- (void)_layoutPages
{
    __block CGRect rect = self.scrollView.bounds;
    NSInteger width = CGRectGetWidth(rect);
    rect.size.width -= kPhotosOffset * 2;
    [self.pages enumerateObjectsUsingBlock:^(PhotoPage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        rect.origin.x = width * idx + kPhotosOffset;
        obj.frame = rect;
    }];
    
    CGSize size = self.scrollView.bounds.size;
    size.width = self.pages.count * width;
    self.scrollView.contentSize = size;
    [self _scrollToIndex:self.currentPage animated:NO];
    self.isRotation = NO;
}

#pragma mark - actions

- (void)leftButtonDidPressed
{
    [self _closeAnimationCompleted:^{
        [self.delegate closeController];
        if (self.closeBlock)
        {
            self.closeBlock();
        }
    }];
}

- (void)actionButtonTapped
{
    UIImageView *image = self.photos[self.currentPage];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[image.image] applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - scroll

- (void)_scrollToIndex:(NSInteger)index animated:(BOOL)animated
{
    CGRect rect = self.scrollView.bounds;
    rect.origin.x = index * CGRectGetWidth(rect) + kPhotosOffset;
    rect.size.width -= kPhotosOffset * 2;
    [self.scrollView scrollRectToVisible:rect animated:animated];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.view.backgroundColor = [UIColor blackColor];
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (page != self.currentPage)
        {
            self.currentPage = page;
        }
    });
}

#pragma mark - Orientation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    self.isRotation = YES;
}

#pragma mark - <PhotoViewDelegate>

- (void)closePhoto:(UIImageView *)photo;
{
    [self _closeAnimationWith:photo completed:^{
        [self.delegate closeController];
        if (self.closeBlock)
        {
            self.closeBlock();
        }
    }];
}

- (void)photoWillDragging
{
    self.view.backgroundColor = [UIColor clearColor];
}

#pragma mark - animations

- (void)_openAnimation
{
    self.view.userInteractionEnabled = NO;
    self.view.alpha = 0;
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
    } completion:^(BOOL finished) {
        [photo removeFromSuperview];
        image.hidden = NO;
        if (completed)
        {
            completed();
        }
    }];
}

- (void)_closeAnimationCompleted:(void(^)())completed
{
    UIImageView *image = self.photos[self.currentPage];
    image.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        if (completed)
        {
            completed();
        }
    }];
}

#pragma mark - status bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - private methods

- (void)_scrollToLeft
{
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void)_createPages
{
    if (!self.photos)
    {
        return;
    }
    NSMutableArray *pages = [NSMutableArray new];
    for (UIImageView *imageView in self.photos)
    {
        PhotoPage *photoPage = [PhotoPage new];
        photoPage.delegate = self;
        photoPage.image = imageView.image;
        [self.scrollView addSubview:photoPage];
        [pages addObject:photoPage];
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

#pragma mark - lazy initialization

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
