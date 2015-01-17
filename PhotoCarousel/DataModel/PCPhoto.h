//
//  PCPhoto.h
//  PCPhotoCarousel
//
//  Created by Darshan K N on 11/01/15.
//  Copyright (c) 2015 Darshan K N. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PCPhoto : NSObject

@property(nonatomic, strong) ALAsset *asset;
@property (nonatomic,strong) NSString *imageName;
@property (nonatomic,assign, getter=isSelected) BOOL selected;

@end
