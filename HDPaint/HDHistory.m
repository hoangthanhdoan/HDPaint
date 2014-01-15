//
//  HDHistory.m
//  HDPaint
//
//  Created by Hoang Thanh Doan on 12/21/13.
//  Copyright (c) 2013 Hoang Thanh Doan. All rights reserved.
//

#import "HDHistory.h"

@implementation HDHistory

- (id)init
{
    self = [super init];
    if (self) {
        [self doInit];
    }
    return self;
}

- (void)doInit{
    self.arrayHistoryItem = [[NSMutableArray alloc] init];
}

@end

@implementation HDHistoryItem



@end
