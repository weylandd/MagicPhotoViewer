//
//  CollectionCell.m
//  MagicPhotoViewer
//
//  Created by Alex Kopachev on 11.02.16.
//  Copyright © 2016 Alex Kopachev. All rights reserved.
//

#import "CollectionCell.h"

@interface CollectionCell ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation CollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    [self button];
}

#pragma mark - PrepareForReuse

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
}

#pragma mark - Actions

- (void)buttonAction
{
    [self.delegate cellDidSelected:self];
}

#pragma mark - > Layout <

- (void)_layoutImageView
{
    CGRect rect = self.bounds;
    _imageView.frame = rect;
}

- (void)_layoutButton
{
    CGRect rect = self.bounds;
    self.button.frame = rect;
}

#pragma mark - Lazy initialization

- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [UIImageView new];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        [self _layoutImageView];
    }
    return _imageView;
}

- (UIButton *)button
{
    if (!_button)
    {
        _button = [UIButton new];
        [_button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
        [self bringSubviewToFront:_button];
        [self _layoutButton];
    }
    return _button;
}

@end
