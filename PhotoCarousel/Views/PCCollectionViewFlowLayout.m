//
//  PCCollectionViewFlowLayout.m
//  PhotoCarousel
//
//  Created by Darshan K N on 13/01/15.
//  Copyright (c) 2015 Darshan K N. All rights reserved.
//

#import "PCCollectionViewFlowLayout.h"

@implementation PCCollectionViewFlowLayout

// override below method to set the photo to center of the screen on scroll
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat offsetAdjustLargeFloat = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustLargeFloat)) {
            offsetAdjustLargeFloat = itemHorizontalCenter - horizontalCenter;
        }
    }
    return CGPointMake(proposedContentOffset.x + offsetAdjustLargeFloat, proposedContentOffset.y);
}

@end
