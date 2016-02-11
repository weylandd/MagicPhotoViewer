//
//  CollectionCell.h
//  MagicPhotoViewer
//
//  Created by Alex Kopachev on 11.02.16.
//  Copyright © 2016 Alex Kopachev. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CollectionCellDelegate;

@interface CollectionCell : UICollectionViewCell

@property (nonatomic, weak) id <CollectionCellDelegate> delegate;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) NSInteger index;

@end

@protocol CollectionCellDelegate <NSObject>

- (void)cellDidSelected:(CollectionCell *)cell;

@end