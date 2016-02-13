//
//  CustomImageViewer.m
//  MagicPhotoViewer
//
//  Created by Alex Kopachev on 13.02.16.
//  Copyright © 2016 Alex Kopachev. All rights reserved.
//

#import "CustomImageViewer.h"

@interface CustomImageViewer ()

@end

@implementation CustomImageViewer

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setupInitialState
{
    [super setupInitialState];
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

#pragma mark - Animations

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

@end
