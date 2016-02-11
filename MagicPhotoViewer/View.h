//
//  View.h
//  MagicPhotoViewer
//
//  Created by Alex Kopachev on 11.02.16.
//  Copyright © 2016 Alex Kopachev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionCell.h"

extern NSString *const CollectionCellReuseIdentifier;

@interface View : UIView

@property (nonatomic, strong) UICollectionView *collectionView;

@end
