//
//  PCPhotoCollectionViewCell.h
//  PhotoCarousel
//
//  Created by Darshan K N on 11/01/15.
//  Copyright (c) 2015 Darshan K N. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCPhoto.h"
@interface PCPhotoCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImageView *selectionIcon;
@property (strong , nonatomic) UIView *clearView;

-(void)setCellContentWithPhoto:(PCPhoto *) photo;

@end
