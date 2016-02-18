//
//  ImageViewModel.h
//  MagicPhotoViewer
//
//  Created by Alex Kopachev on 18.02.16.
//  Copyright © 2016 Alex Kopachev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewModel : NSObject

@property (nonatomic, strong) UIImage *imageForCollection;
@property (nonatomic, strong) UIImage *imageForViewer;

@end
