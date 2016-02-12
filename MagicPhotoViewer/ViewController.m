//
//  ViewController.m
//  MagicPhotoViewer
//
//  Created by Alex Kopachev on 11.02.16.
//  Copyright © 2016 Alex Kopachev. All rights reserved.
//

#import "ViewController.h"
#import "View.h"

#import "PhotosHelper.h"

@interface ViewController () <CollectionCellDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) View *mainView;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view = self.mainView;
    self.mainView.collectionView.delegate = self;
    self.mainView.collectionView.dataSource = self;
}

#pragma mark - <CollectionCellDelegate>

- (void)cellDidSelected:(CollectionCell *)cell
{
    [PhotosViewer openPhotos:[self _imageViewsWithSelectedCell:cell] currentIndex:self.currentIndex close:nil];
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionCell *collectionCell = (CollectionCell *)cell;
    collectionCell.imageView.image = [UIImage imageNamed:@"magicImage"];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 30;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionCell *cell = [self.mainView.collectionView dequeueReusableCellWithReuseIdentifier:CollectionCellReuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.index = indexPath.row;
    return cell;
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger size = CGRectGetWidth(self.view.bounds)/3 - 2.5;
    return CGSizeMake(size, size);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 2, 0);
}

#pragma mark - Private

- (NSArray *)_visibleCells
{
    NSMutableArray *cells = [NSMutableArray arrayWithArray:self.mainView.collectionView.visibleCells];
    [cells sortUsingComparator:^NSComparisonResult(CollectionCell * _Nonnull obj1, CollectionCell * _Nonnull obj2) {
        return obj1.index > obj2.index;
    }];
    return cells;
}

- (NSArray *)_imageViewsWithSelectedCell:(CollectionCell *)selectedCell
{
    NSMutableArray *imageViews = [NSMutableArray new];
    [[self _visibleCells] enumerateObjectsUsingBlock:^(CollectionCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        [imageViews addObject:cell.imageView];
        if ([cell isEqual:selectedCell])
        {
            self.currentIndex = idx;
        }
    }];
    return imageViews;
}

#pragma mark - Lazy initialization

- (View *)mainView
{
    if (!_mainView)
    {
        _mainView = [View new];
    }
    return _mainView;
}

@end
