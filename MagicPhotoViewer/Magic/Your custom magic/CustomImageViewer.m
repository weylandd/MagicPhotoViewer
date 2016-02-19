//
//  CustomImageViewer.m
//  MagicPhotoViewer
//
//  Created by Alex Kopachev on 13.02.16.
//  Copyright © 2016 Alex Kopachev. All rights reserved.
//

#import "CustomImageViewer.h"

@interface CustomImageViewer ()

@property (nonatomic, strong) UINavigationBar *navigationBar;

@end

@implementation CustomImageViewer

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)openFromViewController:(UIViewController *)viewController withCurrentIndex:(NSInteger)currentIndex
{
    [self _setup];
    [super openFromViewController:viewController withCurrentIndex:currentIndex];
}

#pragma mark - Actions

- (void)tapAction
{
    self.navigationBar.hidden = !self.navigationBar.hidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)leftButtonDidPressed
{
    [self _closeAnimationCompleted:^{
        [self _dismiss];
    }];
}

- (void)actionButtonTapped
{
    UIImage *image = [self.customDataSource imageViewer:self imageForIndex:self.currentPage];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - Setters

- (void)setCustomDelegate:(id<CustomImageViewerDelegate>)customDelegate
{
    _customDelegate = customDelegate;
    self.delegate = customDelegate;
}

- (void)setCustomDataSource:(id<CustomImageViewerDataSource>)customDataSource
{
    _customDataSource = customDataSource;
    self.dataSource = customDataSource;
}

#pragma mark - Status bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return self.navigationBar.hidden;
}

#pragma mark - Animations

- (void)_closeAnimationCompleted:(void(^)())completed
{
    UIImageView *image = [self.customDataSource imageViewer:self imageViewForAnimationWithIndex:self.currentPage];
    image.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        if (completed)
        {
            completed();
        }
    }];
}

#pragma mark - Private

- (void)_setup
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.contentView addGestureRecognizer:tap];
}

- (void)_dismiss
{
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(imageViewerWillClose:)])
        {
            [self.delegate imageViewerWillClose:self];
        }
    }];
}

#pragma mark - > Layout <

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self _layoutNavigationBar];
}

- (void)_layoutNavigationBar
{
    CGRect rect = self.view.bounds;
    rect.size.height = CGRectGetWidth(rect) < CGRectGetHeight(rect)? 64: 30;
    self.navigationBar.frame = rect;
}

#pragma mark - Lazy initialization

- (UINavigationBar *)navigationBar
{
    if (!_navigationBar)
    {
        _navigationBar = [UINavigationBar new];
        _navigationBar.barTintColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        _navigationBar.tintColor = [UIColor whiteColor];
        [_navigationBar setBackgroundImage:[UIImage imageNamed:@"background"] forBarMetrics:UIBarMetricsDefault];
        _navigationBar.shadowImage = [UIImage new];
        _navigationBar.translucent = YES;
        _navigationBar.hidden = YES;
        
        UINavigationItem *navItem = [UINavigationItem new];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0,0, 50, 38);
        [btn addTarget:self action:@selector(leftButtonDidPressed) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *image = [UIImageView new];
        image.frame = CGRectMake(0, 4, 18, 30);
        image.image = [UIImage imageNamed:@"backArrow"];
        [btn addSubview:image];
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                     target:self
                                                                                     action:@selector(actionButtonTapped)];
        navItem.leftBarButtonItem = leftButton;
        navItem.rightBarButtonItem = rightButton;
        _navigationBar.items = @[navItem];
        [self.view addSubview:_navigationBar];
        [self.view bringSubviewToFront:_navigationBar];
    }
    return _navigationBar;
}

@end
