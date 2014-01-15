//
//  HDBoardScrollView.m
//  HDPaint
//
//  Created by Hoang Thanh Doan on 12/20/13.
//  Copyright (c) 2013 Hoang Thanh Doan. All rights reserved.
//

#import "HDBoardScrollView.h"
#import "HDHistory.h"

@interface HDBoardScrollView(){
    CGPoint prePreviousPoint;
    CGPoint previousPoint;
    float hue;
    BOOL justTouchBegin;
}
@property (nonatomic, strong) NSMutableArray *listImageView;

@end

@implementation HDBoardScrollView
@synthesize undoManager;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self doInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self doInit];
    }
    return self;
}

- (void)doInit{
    self.listCanvas = [[NSMutableArray alloc] init];
    self.listImageView = [[NSMutableArray alloc] init];
    self.heightForCanvas = 500;
    self.widthForCanvas = 0;
    self.undoManager = [[NSUndoManager alloc] init];
    [self.undoManager setLevelsOfUndo:20];
    self.endPointY = 0;
    self.lineWidth = 10;
    self.lineWidthForEraser = 50;
    
    self.exclusiveTouch = YES;
}

- (void)clear{
    //remove all history
    [self.undoManager removeAllActions];
    
    //remove all canvas
    for (HDPaintCanvasContext *canvas in _listCanvas) {
        [canvas removeFromSuperview];
    }
    [_listCanvas removeAllObjects];
    
    //remove all imageView
    for (UIImageView *imageView in _listImageView) {
        [imageView removeFromSuperview];
    }
    [_listImageView removeAllObjects];
    
    //set default scroll's content
    [self setEndPointY:0];
    self.lastDrawInRect = CGRectZero;
    [self setContentSize:self.bounds.size];
    [self setContentOffset:CGPointMake(0, 0)];
}

- (void)addCanvas: (HDPaintCanvasContext *) canvas{
    [self.listCanvas addObject:canvas];
    canvas.frame = CGRectMake(0,
                              (_listCanvas.count-1)*_heightForCanvas,
                              _widthForCanvas>0?_widthForCanvas:self.frame.size.width,
                              _heightForCanvas);
    [self addSubview:canvas];
    self.contentSize = CGSizeMake(self.frame.size.width, canvas.frame.origin.y + canvas.frame.size.height);
}

- (NSArray *)canvasInRect: (CGRect) rect{
    float minY = rect.origin.y;
    float maxY = rect.origin.y + rect.size.height;
    
    int minRow = minY/_heightForCanvas;
    int maxRow = maxY/_heightForCanvas;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = minRow; i < maxRow + 1; i++) {
        if (i < _listCanvas.count) {
            HDPaintCanvasContext *canvas = [_listCanvas objectAtIndex:i];
            [array addObject:canvas];
        }
    }
    return array;
}

#pragma mark - overwrite
/*
- (void)setContentOffset:(CGPoint)contentOffset{
    [super setContentOffset:contentOffset];
    
    NSArray *arrayToBackup = [self canvasInRect:CGRectMake(0,
                                                           contentOffset.y,
                                                           self.frame.size.width,
                                                           self.frame.size.height)];
    
    for (HDPaintCanvasContext *canvas in _listCanvas) {
        if (![arrayToBackup containsObject:canvas]) {
            [canvas removeFromSuperview];
        }else{
            [self addSubview:canvas];
        }
    }
    
}*/

#pragma mark - napshot

- (UIImage *)snapShot{
    CGRect rect = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    NSArray *arrayToSnapShot = [self canvasInRect:rect];
    for (HDPaintCanvasContext *canvas in arrayToSnapShot) {
        
    }
}

#pragma mark - draw
- (void)insertImageView: (UIImageView *) imageView{
    [self saveJustInsertImageToUndo:imageView];
    [_listImageView addObject:imageView];
    [self insertSubview:imageView atIndex:0];
    [self updateRectToDraw:imageView.frame];
}

- (void)renderImage: (UIImage *) image inRect: (CGRect) rectDraw{
    NSArray *arrayToBackup = [self canvasInRect:CGRectMake(0,
                                                   self.contentOffset.y,
                                                   self.frame.size.width,
                                                   self.frame.size.height)];
    
    [self saveToUndo:arrayToBackup];
    
    NSArray *array = [self canvasInRect:rectDraw];
    for (int i = 0; i < array.count; i++) {
        HDPaintCanvasContext *canvas = [array objectAtIndex:i];
        CGRect rect = rectDraw;
        CGRect rectResult = [canvas renderImage:image inRect:CGRectMake(rect.origin.x - canvas.frame.origin.x,
                                                                  rect.origin.y - canvas.frame.origin.y,
                                                                  rect.size.width,
                                                                  rect.size.height)];
        rectResult.origin.y = rectResult.origin.y + canvas.frame.origin.y;
        rectResult.origin.x = rectResult.origin.x + canvas.frame.origin.x;
        
        [self updateRectToDraw:rect];
    }
}

- (void)renderLineFromPoint:(CGPoint)_point0 toPoint:(CGPoint)_point1 toPoint:(CGPoint)_point2{
    UIColor *color = _brushColor;
    if (!_brushColor) {
        hue += 0.005;
        if(hue > 1.0) hue = 0.0;
        color = [UIColor colorWithHue:hue saturation:0.7 brightness:1.0 alpha:1.0];
    }
    
    int lineWidth = _lineWidth;
    if (_isEraser) {
        lineWidth = _lineWidthForEraser;
    }
    
    int heigh = 0;
    [self renderLineFromPoint:CGPointMake(_point0.x, _point0.y - heigh)
                          toPoint:CGPointMake(_point1.x, _point1.y - heigh)
                          toPoint:CGPointMake(_point2.x, _point2.y - heigh)
                         isEraser:_isEraser
                    withLineWidth:lineWidth
                        withColor:color];
    
}

- (void) renderLineFromPoint:(CGPoint)_point0
                     toPoint:(CGPoint)_point1
                     toPoint:(CGPoint)_point2
                    isEraser: (BOOL) isEraser
               withLineWidth: (int) lineWidth
                   withColor: (UIColor *) color{
    NSArray *array = [self canvasInRect:CGRectMake(0,
                                                   self.contentOffset.y,
                                                   self.frame.size.width,
                                                   self.frame.size.height/* + self.contentOffset.y*/)];
    for (int i = 0; i < array.count; i++) {
        HDPaintCanvasContext *canvas = [array objectAtIndex:i];
        
        int heigh = canvas.frame.origin.y;
        CGRect rect = [canvas renderLineFromPoint:CGPointMake(_point0.x, _point0.y - heigh)
                              toPoint:CGPointMake(_point1.x, _point1.y - heigh)
                              toPoint:CGPointMake(_point2.x, _point2.y - heigh)
                             isEraser:isEraser
                        withLineWidth:lineWidth
                            withColor:color];
        rect.origin.y = rect.origin.y + canvas.frame.origin.y;
        if (!_isEraser) {
            [self updateRectToDraw:rect];
        }
    }
}

- (void) updateRectToDraw: (CGRect) rect{
    if (_lastDrawInRect.size.width == 0) {
        _lastDrawInRect = rect;
    }else{
        CGPoint dirtyPoint1 = CGPointMake(MIN(rect.origin.x, _lastDrawInRect.origin.x), MIN(rect.origin.y, _lastDrawInRect.origin.y));
        CGPoint dirtyPoint2 = CGPointMake(MAX(_lastDrawInRect.origin.x + _lastDrawInRect.size.width,
                                              rect.origin.x + rect.size.width),
                                          MAX(_lastDrawInRect.origin.y + _lastDrawInRect.size.height,
                                              rect.origin.y + rect.size.height));
        self.lastDrawInRect = CGRectMake(dirtyPoint1.x, dirtyPoint1.y, dirtyPoint2.x - dirtyPoint1.x, dirtyPoint2.y - dirtyPoint1.y);
    }
    _endPointY = MAX(_lastDrawInRect.origin.y + _lastDrawInRect.size.height, _endPointY);
}


#pragma mark - event draw

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    justTouchBegin = YES;
    NSSet *touches1= [event allTouches];
    if (touches1.count> 1) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        return;
    }
    _lastDrawInRect = CGRectZero;
    UITouch *touch = [touches anyObject];
    previousPoint = [touch locationInView:self];
    [self performSelector:@selector(firstTouch:) withObject:@[[NSNumber numberWithFloat:previousPoint.x],[NSNumber numberWithFloat:previousPoint.y]] afterDelay:0.3];
}

- (void)firstTouch: (NSArray *)arrayPoint{
    if (arrayPoint.count <= 1) {
        return;
    }
    [self backUp];
    CGPoint _point = CGPointMake([arrayPoint[0] floatValue], [arrayPoint[1] floatValue]);
    [self renderLineFromPoint:_point
                      toPoint:_point
                      toPoint:_point];
}

- (void)backUp{
    NSArray *array = [self canvasInRect:CGRectMake(0,
                                                   self.contentOffset.y,
                                                   self.frame.size.width,
                                                   self.frame.size.height)];
    
    [self saveToUndo:array];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSSet *touches1= [event allTouches];
    if (touches1.count> 1) {
        return;
    }
    
    if (justTouchBegin) {
        [self backUp];
        justTouchBegin = NO;
    }
    
    UITouch *touch = [touches anyObject];
    
    prePreviousPoint = previousPoint;
    previousPoint = [touch previousLocationInView:self];
    CGPoint currentPoint = [touch locationInView:self];
	
    [self renderLineFromPoint:prePreviousPoint toPoint:previousPoint toPoint:currentPoint];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSSet *touches1= [event allTouches];
    if (touches1.count> 1) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    prePreviousPoint = previousPoint;
    previousPoint = [touch previousLocationInView:self];
    CGPoint currentPoint = [touch locationInView:self];
	
    [self renderLineFromPoint:prePreviousPoint toPoint:previousPoint toPoint:currentPoint];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

#pragma mark - undo manager

- (void) saveJustInsertImageToUndo: (UIImageView *) imageView{
    HDHistory *history = [[HDHistory alloc] init];
    history.contentOffset = self.contentOffset;
    history.endPointY = _endPointY;
    
    HDHistoryItem *item = [[HDHistoryItem alloc] init];
    item.object = imageView;
    item.historyType = HDHistoryTypeInsertImage;
    
    [history.arrayHistoryItem addObject:item];
    
    [self.undoManager registerUndoWithTarget:self selector:@selector(undoHistory:) object:history];
}

- (void) saveToUndo: (NSArray *) arrayCanvas{
    HDHistory *history = [[HDHistory alloc] init];
    history.contentOffset = self.contentOffset;
    history.endPointY = _endPointY;
    for (HDPaintCanvasContext *canvas in arrayCanvas) {
        HDHistoryItem *item = [[HDHistoryItem alloc] init];
        item.point = canvas.frame.origin;
        item.image = [canvas snapshot];
        item.object = canvas;
        item.historyType = HDHistoryTypeCanvas;
        
        [history.arrayHistoryItem addObject:item];
    }
    [self.undoManager registerUndoWithTarget:self selector:@selector(undoHistory:) object:history];
}

- (void) undoHistory: (HDHistory *) history{
    [self setContentOffset:history.contentOffset animated:YES];
    self.endPointY = history.endPointY;
    for (HDHistoryItem *item in history.arrayHistoryItem) {
        if (item.historyType == HDHistoryTypeCanvas) {
            HDPaintCanvasContext *canvas = (HDPaintCanvasContext *)item.object;
            [canvas clear];
            [canvas replaceImage:item.image fromPoint:CGPointMake(item.point.x - canvas.frame.origin.x, item.point.y - canvas.frame.origin.y)];
        }else if (item.historyType == HDHistoryTypeInsertImage){
            UIImageView *imageView = (UIImageView *)item.object;
            if (imageView) {
                if ([_listImageView containsObject:imageView]) {
                    [imageView removeFromSuperview];
                    [_listImageView removeObject:imageView];
                }else{
                    [_listImageView addObject:imageView];
                    [self insertSubview:imageView atIndex:0];
                }
            }
        }
    }
}

@end
