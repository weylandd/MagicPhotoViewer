//
//  CustomImageViewer.h
//  MagicPhotoViewer
//
//  Created by Alex Kopachev on 13.02.16.
//  Copyright © 2016 Alex Kopachev. All rights reserved.
//

#import "MGCImageViewer.h"
@protocol CustomImageViewerDelegate;
@protocol CustomImageViewerDataSource;

@interface CustomImageViewer : MGCImageViewer

@property (nonatomic, weak) id <CustomImageViewerDelegate> customDelegate;
@property (nonatomic, weak) id <CustomImageViewerDataSource> customDataSource;

@end

@protocol CustomImageViewerDelegate <MGCImageViewerDelegate>

@end

@protocol CustomImageViewerDataSource <MGCImageViewerDataSource>

@end