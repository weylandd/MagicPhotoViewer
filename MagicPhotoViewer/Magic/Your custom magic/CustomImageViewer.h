//
//  CustomImageViewer.h
//  MagicPhotoViewer
//
//  Created by Alex Kopachev on 13.02.16.
//  Copyright © 2016 Alex Kopachev. All rights reserved.
//

#import "ImageViewer.h"
@protocol CustomImageViewerDelegate;
@protocol CustomImageViewerDataSource;

@interface CustomImageViewer : ImageViewer

@property (nonatomic, weak) id <CustomImageViewerDelegate> customDelegate;
@property (nonatomic, weak) id <CustomImageViewerDataSource> customDataSource;

@end

@protocol CustomImageViewerDelegate <ImageViewerDelegate>

@end

@protocol CustomImageViewerDataSource <ImageViewerDataSource>

@end