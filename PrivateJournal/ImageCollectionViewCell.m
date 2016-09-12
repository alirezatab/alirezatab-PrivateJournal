//
//  ImageCollectionViewCell.m
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 6/13/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import "ImageCollectionViewCell.h"

@implementation ImageCollectionViewCell
- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
}
@end
