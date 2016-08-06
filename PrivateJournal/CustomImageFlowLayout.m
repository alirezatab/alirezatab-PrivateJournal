//
//  CustomImageFlowLayout.m
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 6/13/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import "CustomImageFlowLayout.h"

@implementation CustomImageFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.minimumLineSpacing = 1.0;
        self.minimumInteritemSpacing = 1.0;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return self;
}

- (CGSize)itemSize
{
    NSInteger numberOfColumns = 2;
    
    CGFloat itemWidth = (CGRectGetWidth(self.collectionView.frame) - (numberOfColumns - 1)) / numberOfColumns;
    return CGSizeMake(itemWidth, itemWidth);
}


@end
