//
//  PCViewController.m
//  PhotoCarousel
//
//  Created by Darshan K N on 11/01/15.
//  Copyright (c) 2015 Darshan K N. All rights reserved.
//

#import "PCViewController.h"
#import "PCPhoto.h"
#import "PCPhotoCollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PCCollectionViewFlowLayout.h"

@interface PCViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) NSMutableArray *photos;
@property (nonatomic, strong) UICollectionView *collectionView;
@property NSInteger selectionCounter;

@end

@implementation PCViewController
@synthesize photos;
@synthesize selectionCounter;

#pragma mark - Lifecycle methods

-(id) init{
    if(self = [super init]){
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void) loadView{
    
    [super loadView];
    self.title =NSLocalizedString(@"AppTitle", "")  ;
    self.view = [[UIView alloc] initWithFrame:[self usefulScreenSpace]];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // Load photos from Device Library
    [self loadPhotosFromDeviceLibrary];
    [self configureCollectionView];


}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Load Media

-(void) loadPhotosFromDeviceLibrary {
    
    photos = [[NSMutableArray alloc] init];
    
    ALAssetsLibrary *assetsLibrary = [PCViewController sharedAssetsLibrary];
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                 usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop) {
                                     if (assetsGroup != nil) {
                                         // set the filter to select Photos alone
                                         [assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                                         
                                         [assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                                             if (asset) {
                                                 PCPhoto *photo = [[PCPhoto alloc] init];
                                                 [photo setImageName:[[asset defaultRepresentation] filename]];
                                                 [photo setSelected:NO];
                                                 [photo setAsset:asset];
                                                 [photos addObject:photo];
                                             }
                                         }];
                                         
                                     }
                                     else{
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if ([photos count]) {
                                                 [self configureButton];
                                                 [self.collectionView reloadData];

                                             }
                                             else{
                                                  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NoPhotoTitle", @"") message:NSLocalizedString(@"NoPhotoMessage", @"")  delegate:self cancelButtonTitle:NSLocalizedString(@"CancelButtonTitle", @"")otherButtonTitles:nil];
                                                 [alertView show];
                                             }
                                            
                                         });

                                        
                                     }
                                     *stop = NO;
                                 } failureBlock:^(NSError *error) {
                                     NSString *alertTitle = @"", *alertMessage = @"";
                                     if (error.code == ALAssetsLibraryAccessUserDeniedError) {
                                         alertTitle = NSLocalizedString(@"PermissionDeniedTitle", @"");
                                         alertMessage =  NSLocalizedString(@"PermissionDeniedMessage", @"");
                                     }else{
                                         alertTitle = NSLocalizedString(@"GenericErrorTitle", @"");
                                         alertMessage =  NSLocalizedString(@"GenericErroMessage", @"");
                                     }
                                     
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage  delegate:self cancelButtonTitle:NSLocalizedString(@"CancelButtonTitle", @"")otherButtonTitles:nil];
                                         [alertView show];
                                     });
                                    
                                 }];
}


+ (ALAssetsLibrary *)sharedAssetsLibrary
{
    static dispatch_once_t once = 0;
    static ALAssetsLibrary *sharedAssetsLibrary = nil;
    dispatch_once(&once, ^{
        sharedAssetsLibrary = [[ALAssetsLibrary alloc] init];
    });
    return sharedAssetsLibrary;
}

#pragma mark - Collection View setup

-(void)configureCollectionView {
    
    PCCollectionViewFlowLayout *flowLayout = [[PCCollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:CAROUSEL_PADDING];
    [flowLayout setMinimumLineSpacing:CAROUSEL_PADDING];
    
    self.collectionView =[[UICollectionView alloc] initWithFrame:CGRectMake(0, CAROUSEL_ORIGIN_Y, SCREEN_WIDTH, CAROUSEL_HEIGHT) collectionViewLayout:flowLayout];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setContentOffset:CGPointMake(0, 0)];
    [self.collectionView setBounces: YES];
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    [self.collectionView registerClass:[PCPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.collectionView setPagingEnabled:NO];
    [self.collectionView setDecelerationRate:UIScrollViewDecelerationRateFast];
    [self.collectionView setClipsToBounds:NO];
    [self.collectionView setCollectionViewLayout:flowLayout];
    [self.view addSubview:self.collectionView];

}

#pragma mark - Count Button

-(void) configureButton {
    
    UIButton *countButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [countButton addTarget:self action:@selector(countButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [countButton setBackgroundColor:[UIColor colorWithRed:0.0 green:111.0/255.0 blue:225.0/255.0 alpha:1.0]];
    [countButton setTitle:NSLocalizedString(@"CountButtonTitle", @"") forState:UIControlStateNormal];
    [countButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [countButton setFrame: CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)];
    [countButton setCenter:CGPointMake(self.view.bounds.size.width/2.0, self.collectionView.frame.origin.y + self.collectionView.frame.size.height + BUTTON_TOP_BUFFER)];
    [self.view addSubview:countButton];
}

-(void) countButtonTapped:(id) sender {
    NSString *alertMessage =  @"";

    if(self.selectionCounter == 0){
        alertMessage =  NSLocalizedString(@"NoPhotoSelectedMessage", @"");
    }
    else if (self.selectionCounter == 1){
        alertMessage =  NSLocalizedString(@"SinglePhotoSelectedMessage", @""); ;
    }
    else{
        alertMessage =  [NSString stringWithFormat: NSLocalizedString(@"MultiplePhotoSelectedMessage", @""),(long)self.selectionCounter];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CountButtonTitle", @"") message:alertMessage  delegate:self cancelButtonTitle:NSLocalizedString(@"CancelButtonTitle", @"")otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - UICollectionViewDataSource Methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.photos count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PCPhotoCollectionViewCell *cell = (PCPhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setCellContentWithPhoto:(PCPhoto *)[photos objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
/*
    In photos app, photo can be selected only if it is completely visible. And the selected item is centered.
     If photo is not fully visible, scroll the tapped item to center of the view without selecting it.
*/
    if([self isCellCompletelyVisibleAtIndex:indexPath]){
        
        //photo is fully visible, update the selectionCounter and selection tick mark.
        PCPhoto *photo = (PCPhoto *)[photos objectAtIndex:indexPath.row];
        if([photo isSelected]){
            self.selectionCounter -- ;
        }
        else{
            self.selectionCounter ++ ;

        }
        [photo setSelected:![photo isSelected]];
        
         PCPhotoCollectionViewCell *cell = (PCPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [cell setCellContentWithPhoto:(PCPhoto *)[photos objectAtIndex:indexPath.row]];

    }

    [self.collectionView scrollToItemAtIndexPath:indexPath
                               atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                       animated:YES];
    
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
/*
     Below calculation is to find the appropriate width for photo constraining to fixed height.
     For reference::
     -   iPhone Images have an aspect ratio of 4:3.
     -   Most of DSLR images have an aspect ratio of 3: 2
     -    Panorama images' ratio will be x : y , where x is  higher than y compared to above said ratios
     DEFAULT_PHOTO_WIDTH  - corresponds to images with ratio 3:2 . Width of iPhone images taken in landscape mode or any portrait images will be lesser than DEFAULT_PHOTO_WIDTH based on their ratio.
     If width calculated is more than DEFAULT_PHOTO_WIDTH, it's a panorama image and we set the width to MAX_PHOTO_WIDTH
     If width calculated is less than DEFAULT_PHOTO_WIDTH, it's well under the limits and we set that as photo's width.
*/
    CGFloat width = 0;
    ALAsset *asset = [(PCPhoto *)[photos objectAtIndex:indexPath.row] asset];
    width = (asset.defaultRepresentation.dimensions.width * DEFAULT_PHOTO_HEIGHT )/ asset.defaultRepresentation.dimensions.height;

    return CGSizeMake((width> MAX_PHOTO_WIDTH)?MAX_PHOTO_WIDTH : ((width> DEFAULT_PHOTO_WIDTH)? DEFAULT_PHOTO_WIDTH: width), DEFAULT_PHOTO_HEIGHT);
    
}

- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0,EDGE_INSET,0,EDGE_INSET);  // top, left, bottom, right
}

#pragma mark - UIScrollViewDelegate methods
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self handleSelectionIconAnimation ];
}

/*
    To implement animation of selection icon as in Photos.app share option, below approach is used.
    First, get hold of visible photo cells.
    Find the right most cell and set the bounds of that cell to that of visible width of the cell.
    Bounds of rest of visible cells remain same as before.
*/
-(void) handleSelectionIconAnimation {
    
    CGRect collectionViewVisibleRect = (CGRect){.origin = self.collectionView.contentOffset, .size = self.collectionView.bounds.size};
    
    NSArray *visibleCells = [self.collectionView.collectionViewLayout layoutAttributesForElementsInRect:collectionViewVisibleRect];
    
    if (visibleCells != nil) {
        [visibleCells enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *layoutAttributesOfCell, NSUInteger index, BOOL *stop) {
            PCPhotoCollectionViewCell *cell = (PCPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:layoutAttributesOfCell.indexPath];
            CGFloat visibleCellWidth = cell.contentView.bounds.size.width;
            
            if (index ==[visibleCells count] - 1 && (![self isCellCompletelyVisibleAtIndex:layoutAttributesOfCell.indexPath])){
                visibleCellWidth = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width - layoutAttributesOfCell.frame.origin.x;
              
            }
            
            cell.clearView.bounds = (CGRect){.origin = cell.clearView.frame.origin, .size = CGSizeMake(visibleCellWidth, cell.clearView.frame.size.height)};
            [cell layoutSubviews];
            
        }];
    }
}

#pragma mark - Utility Methods

-(CGRect) usefulScreenSpace {
    
    CGFloat wastedHeight = 0;
    wastedHeight += self.navigationController.navigationBar.frame.size.height;
    wastedHeight += [UIApplication sharedApplication].statusBarFrame.size.height;
    
    return CGRectMake(0, wastedHeight, SCREEN_WIDTH, SCREEN_HEIGHT - wastedHeight);
}

-(BOOL) isCellCompletelyVisibleAtIndex:(NSIndexPath *) indexPath {
    
    CGRect visibleRect = (CGRect){.origin = self.collectionView.contentOffset, .size = self.collectionView.bounds.size};
    visibleRect = [self.collectionView convertRect:visibleRect toView:self.collectionView.superview];

    CGRect selectedCellFrame = [[self.collectionView layoutAttributesForItemAtIndexPath:indexPath] frame];
    selectedCellFrame = [self.collectionView convertRect:selectedCellFrame toView:self.collectionView.superview];
    return  CGRectContainsRect(visibleRect, selectedCellFrame);
}




@end
