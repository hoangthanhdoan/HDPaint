//
//  HDBoardScrollView.h
//  HDPaint
//
//  Created by Hoang Thanh Doan on 12/20/13.
//  Copyright (c) 2013 Hoang Thanh Doan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDPaintCanvasContext.h"

@interface HDBoardScrollView : UIScrollView{
    NSUndoManager *undoManager;
}

@property (nonatomic, strong) NSMutableArray *listCanvas;
@property (nonatomic) int heightForCanvas;
@property (nonatomic) int widthForCanvas;
@property (nonatomic) BOOL isEraser;
@property (nonatomic) float endPointY;
@property (nonatomic) int lineWidth;
@property (nonatomic) int lineWidthForEraser;
@property (nonatomic, strong) UIColor *brushColor;
@property (nonatomic, strong) NSUndoManager *undoManager;
@property (nonatomic) CGRect lastDrawInRect;

- (void)clear;
- (void)addCanvas: (HDPaintCanvasContext *) canvas;
- (NSArray *)canvasInRect: (CGRect) rect;
- (void)insertImageView: (UIImageView *) imageView;
- (void)renderImage: (UIImage *) image inRect: (CGRect) rect;
- (UIImage *)snapShot;

@end
