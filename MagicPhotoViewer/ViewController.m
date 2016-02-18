//
//  ViewController.m
//  MagicPhotoViewer
//
//  Created by Alex Kopachev on 11.02.16.
//  Copyright © 2016 Alex Kopachev. All rights reserved.
//

#import "ViewController.h"
#import "View.h"
#import "ImageViewModel.h"

#import "CustomImageViewer.h"

static const NSInteger MGCCollectionViewNumberOfCells = 30;

@interface ViewController () <CollectionCellDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CustomImageViewerDelegate, CustomImageViewerDataSource>

@property (nonatomic, strong) View *mainView;
@property (nonatomic, strong) MGCImageViewer *imageViewer;

@property (nonatomic, strong) NSArray *imageModels;

@end

@implementation ViewController

- (void)cellDidSelectedWithIndex:(NSInteger)index
{
    MGCImageViewer *imageViewer = [MGCImageViewer new];
    imageViewer.delegate = self;
    imageViewer.dataSource = self;
    [imageViewer openFromViewController:self withCurrentIndex:index];
}

#pragma mark - <PhotoControllerDataSource>

- (UIImageView *)imageViewer:(MGCImageViewer *)imageViewer imageViewForAnimationWithIndex:(NSInteger)index
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    CollectionCell *cell = (CollectionCell *)[self.mainView.collectionView cellForItemAtIndexPath:path];
    return cell.imageView;
}

- (UIImage *)imageViewer:(MGCImageViewer *)imageViewer imageForIndex:(NSInteger)index
{
    ImageViewModel *imageModel = self.imageModels[index];
    return imageModel.imageForCollection;
}

- (NSUInteger)numberOfItemsImageViewer:(MGCImageViewer *)imageViewer
{
    return self.imageModels.count;
}

#pragma mark - <PhotoControllerDelegate>

- (void)imageViewer:(MGCImageViewer *)imageViewer prepareImageViewForAnimationWithIndex:(NSInteger)index
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:0];
    [self.mainView.collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (void)imageViewerWillClose:(MGCImageViewer *)imageViewer
{
    NSLog(@"imageViewerWillClose");
}





// it does not matter
// ----------------------------------------------------------------------------------------------

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _prepareModels];
    [self _setupInitialState];
}

#pragma mark - <CollectionCellDelegate>

- (void)cellDidSelected:(CollectionCell *)cell
{
    [self cellDidSelectedWithIndex:cell.index];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionCell *cell = [self.mainView.collectionView dequeueReusableCellWithReuseIdentifier:CollectionCellReuseIdentifier forIndexPath:indexPath];
    ImageViewModel *imageModel = self.imageModels[indexPath.row];
    cell.delegate = self;
    cell.index = indexPath.row;
    cell.imageView.image = imageModel.imageForCollection;
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

- (void)_setupInitialState
{
    self.view = self.mainView;
    self.mainView.collectionView.delegate = self;
    self.mainView.collectionView.dataSource = self;
}

- (void)_prepareModels
{
    NSMutableArray *models = [NSMutableArray new];
    for (NSInteger i = 0; i < MGCCollectionViewNumberOfCells; i++)
    {
        ImageViewModel *model = [ImageViewModel new];
        model.imageForCollection = [UIImage imageNamed:@"magicImage"];
        [models addObject:model];
    }
    self.imageModels = models;
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
