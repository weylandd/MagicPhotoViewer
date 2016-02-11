//
//  View.m
//  MagicPhotoViewer
//
//  Created by Alex Kopachev on 11.02.16.
//  Copyright © 2016 Alex Kopachev. All rights reserved.
//

#import "View.h"

NSString *const CollectionCellReuseIdentifier = @"CollectionCellReuseIdentifier";

@implementation View

#pragma mark - > Layout <

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self _layoutCollectionView];
}

- (void)_layoutCollectionView
{
    CGRect rect = self.bounds;
    rect.origin.x = 2;
    rect.size.width -= 4;
    self.collectionView.frame = rect;
}

#pragma mark - Lazy initialization

- (UICollectionView *)collectionView
{
    if (!_collectionView)
    {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[CollectionCell class] forCellWithReuseIdentifier:CollectionCellReuseIdentifier];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

@end
