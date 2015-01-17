//
//  PCPhotoCollectionViewCell.m
//  PhotoCarousel
//
//  Created by Darshan K N on 11/01/15.
//  Copyright (c) 2015 Darshan K N. All rights reserved.
//

#import "PCPhotoCollectionViewCell.h"

@implementation PCPhotoCollectionViewCell

-(id) initWithFrame:(CGRect)frame {
    
    if(self = [super initWithFrame:frame]){
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.imageView];
        
        self.clearView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.clearView setBackgroundColor:[UIColor clearColor]];

        [self.contentView addSubview:self.clearView];
        
        self.selectionIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.clearView addSubview:self.selectionIcon];
    
    }
    return self;
}

-(void)layoutSubviews{
    
    [super layoutSubviews];

    if(self.clearView.bounds.size.width <= SELECTION_ICON_BUFFER + CAROUSEL_PADDING ){
        
        //  calculate the displacement to set the new bounds origin, so that the selection icon moves smoothly out of visible area.
        CGFloat displacement = SELECTION_ICON_BUFFER + CAROUSEL_PADDING - self.clearView.bounds.size.width;
        self.clearView.bounds = CGRectMake(self.clearView.frame.origin.x - displacement, self.clearView.frame.origin.y, self.clearView.bounds.size.width, self.clearView.bounds.size.height)  ;
    }
    
    [self.selectionIcon setFrame:CGRectMake(self.clearView.bounds.size.width - SELECTION_ICON_BUFFER, self.clearView.bounds.size.height - SELECTION_ICON_BUFFER, SELECTION_ICON_WIDTH, SELECTION_ICON_HEIGHT)];
    
  
}

//Method provides the content to fit in each collection View cell

-(void)setCellContentWithPhoto:(PCPhoto *) photo{
    
    [self.clearView setFrame:self.bounds];
    [self.imageView setFrame: self.bounds];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ALAssetRepresentation *assetRepresentation = [[photo asset] defaultRepresentation];
        UIImage *image = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage]];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageView setImage:image];
        });
    });
    
// Images which are less wider than DEFAULT_PHOTO_WIDTH are set to UIViewContentModeScaleAspectFit to render full image without clipping
// Where as wider images are set to UIViewContentModeScaleAspectFill so that edges are clipped to fit into view of width MAX_PHOTO_WIDTH
    
    [self.imageView setContentMode:(self.bounds.size.width <= DEFAULT_PHOTO_WIDTH ) ? UIViewContentModeScaleAspectFit :UIViewContentModeScaleAspectFill ];
    [self.imageView setClipsToBounds:YES];

    if([photo isSelected]){
        [self.selectionIcon setImage:[UIImage imageNamed:@"SelectionOn.png"]];
    }
    else{
        [self.selectionIcon setImage:[UIImage imageNamed:@"SelectionOff.png"]];

    }
    [self.selectionIcon setFrame:CGRectMake(self.clearView.bounds.size.width - SELECTION_ICON_BUFFER, self.clearView.bounds.size.height - SELECTION_ICON_BUFFER, SELECTION_ICON_WIDTH, SELECTION_ICON_HEIGHT)];
    
}

@end
