//
//  CustomImageViewer.m
//  MagicPhotoViewer
//
//  Created by Alex Kopachev on 13.02.16.
//  Copyright © 2016 Alex Kopachev. All rights reserved.
//

#import "CustomImageViewer.h"

@implementation CustomImageViewer

- (void)setupInitialState
{
    [super setupInitialState];
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

@end
