//
//  HDHistory.h
//  HDPaint
//
//  Created by Hoang Thanh Doan on 12/21/13.
//  Copyright (c) 2013 Hoang Thanh Doan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, HDHistoryType) {
    HDHistoryTypeInsertImage,
    HDHistoryTypeCanvas
};

@interface HDHistory : NSObject

@property (nonatomic, strong) NSMutableArray *arrayHistoryItem;
@property (nonatomic) CGPoint contentOffset;
@property (nonatomic) float endPointY;

@end

@interface HDHistoryItem : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic) CGPoint point;
@property (nonatomic, strong) NSObject *object;
@property (nonatomic) HDHistoryType historyType;

@end
