//
//  HDPaintCanvasContext.h
//  HDPaint
//
//  Created by Hoang Thanh Doan on 12/19/13.
//  Copyright (c) 2013 Hoang Thanh Doan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDPaintCanvasContext : UIView

@property (nonatomic) BOOL isNeed;
@property (nonatomic, strong) NSString *name;

- (void) renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end;
- (CGRect) renderLineFromPoint:(CGPoint)_point0
                     toPoint:(CGPoint)_point1
                     toPoint:(CGPoint)_point2
                    isEraser: (BOOL) isEraser
               withLineWidth: (int) lineWidth
                   withColor: (UIColor *) color;
- (void) renderLineFromPoint:(CGPoint)point0 toPoint:(CGPoint)point1 toPoint:(CGPoint)point2 toPoint:(CGPoint)point3;
- (CGRect)renderImage: (UIImage *) image fromPoint: (CGPoint) pointToDraw;
- (CGRect)renderImage: (UIImage *) image inRect: (CGRect) rect;
- (CGRect)replaceImage: (UIImage *) image fromPoint: (CGPoint) pointToDraw;
- (CGRect)replaceImage: (UIImage *) image inRect: (CGRect) rect;
- (UIImage *)snapshot;
- (void)clear;

@end
