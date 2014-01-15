//
//  HDPaintCanvasContext.m
//  HDPaint
//
//  Created by Hoang Thanh Doan on 12/19/13.
//  Copyright (c) 2013 Hoang Thanh Doan. All rights reserved.
//

#import "HDPaintCanvasContext.h"

#define scaleScreen 1

static inline double radians (double degrees) {return degrees * M_PI/180;}

@interface HDPaintCanvasContext(){
    void *cacheBitmap;
    CGContextRef cacheContext;
}

@end

@implementation HDPaintCanvasContext


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
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

- (void) doInit{
    self.name = [NSString stringWithFormat:@"%p", self];
}

- (void) initContextIfNeed{
    if (cacheContext == NULL) {
        [self initContext:self.frame.size];
    }
    
    
}

- (void)initContext:(CGSize)size{
    CGColorSpaceRef colorSpace;
    
    [self releaseContext];
    
    CGFloat scale = scaleScreen;
	int bitmapByteCount;
	int	bitmapBytesPerRow;
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow = (size.width * 4)*scale;
	bitmapByteCount = (bitmapBytesPerRow * size.height)*scale;
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	cacheBitmap = malloc( bitmapByteCount );
	if (cacheBitmap == NULL){
		return;
	}
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
	cacheContext = CGBitmapContextCreate (cacheBitmap, size.width*scale, size.height*scale, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClearRect(cacheContext, CGRectMake(0, 0, size.width*scale, size.height*scale));
    
    CGColorSpaceRelease(colorSpace);
    return;
}

- (void) releaseContext{
    if (cacheContext != NULL) {
        free (cacheBitmap);
        CGContextRelease(cacheContext);
        cacheContext = NULL;
    }
}

- (void)setIsNeed:(BOOL)isNeed{
    if (_isNeed == isNeed) {
        return;
    }
    _isNeed = isNeed;
    if (_isNeed) {
//        [self canPerformAction:@selector(saveContextToLocal) withSender:nil];
//        [self canPerformAction:@selector(loadContextFromLocal) withSender:nil];
//        [self performSelector:@selector(loadContextFromLocal) withObject:nil afterDelay:0.1];
//        [self loadContextFromLocal];
//         [self loadContextFromLocal];
    }else{
//        [self canPerformAction:@selector(saveContextToLocal) withSender:nil];
//        [self canPerformAction:@selector(loadContextFromLocal) withSender:nil];
//        [self performSelector:@selector(saveContextToLocal) withObject:nil afterDelay:5];
//        [self saveContextToLocal];
    }
}

- (void)loadContextFromLocal{
    if (cacheContext != NULL) {
        return;
    }
    UIImage *image = [self loadImage];
    if (!image) {
        return;
    }
    [self renderImage:image fromPoint:CGPointMake(0, 0)];
}

- (void)saveContextToLocal{
    
    UIImage *image = [self snapshot];
    if (!image) {
        return;
    }
    BOOL success = [self saveImage:image];
    if (success) {
        [self releaseContext];
    }
   
    

}

- (void) renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end{
    [self initContextIfNeed];
    UIColor *color = [UIColor redColor];
    int lineWidth = 5;
    
    CGContextSetStrokeColorWithColor(cacheContext, [color CGColor]);
    CGContextSetLineCap(cacheContext, kCGLineCapRound);
    CGContextSetLineWidth(cacheContext, lineWidth);
    
    CGContextMoveToPoint(cacheContext, start.x*scaleScreen, start.y*scaleScreen);
    CGContextAddLineToPoint(cacheContext, end.x*scaleScreen, end.y*scaleScreen);
    CGContextStrokePath(cacheContext);
    
    
    int minX = MIN(start.x, end.x)-lineWidth;
    int minY = MIN(start.y, end.y)-lineWidth;
    
    int maxX = MAX(start.x, end.x)+lineWidth;
    int maxY = MAX(start.y, end.y)+lineWidth;
    
    CGRect rectRefresh = CGRectMake(minX,
                                    minY,
                                    maxX - minX,
                                    maxY - minY);
    [self setNeedsDisplayInRect:rectRefresh];
}

- (CGRect) renderLineFromPoint:(CGPoint)_point0 toPoint:(CGPoint)_point1 toPoint:(CGPoint)_point2 isEraser: (BOOL) isEraser withLineWidth: (int) lineWidth withColor: (UIColor *) color{

    [self initContextIfNeed];
    
    CGContextSetLineCap(cacheContext, kCGLineCapRound);
    CGContextSetLineWidth(cacheContext, lineWidth);
    if (isEraser) {
        CGContextSetBlendMode(cacheContext,kCGBlendModeClear);
        CGContextSetStrokeColorWithColor(cacheContext, [[UIColor clearColor] CGColor]);
    }else{
        CGContextSetBlendMode(cacheContext,kCGBlendModeNormal);
        CGContextSetStrokeColorWithColor(cacheContext, [color CGColor]);
    }
    
    CGPoint mid1 = [self calculateMidPointForPoint:_point0 andPoint:_point1];
    CGPoint mid2 = [self calculateMidPointForPoint:_point1 andPoint:_point2];
    
    
    CGContextMoveToPoint(cacheContext, mid1.x*scaleScreen, mid1.y*scaleScreen);
    // Use QuadCurve is the key
    CGContextAddQuadCurveToPoint(cacheContext, _point1.x*scaleScreen, _point1.y*scaleScreen, mid2.x*scaleScreen, mid2.y*scaleScreen);
    CGContextStrokePath(cacheContext);
    
    CGRect dirtyPoint1 = CGRectMake(mid1.x-lineWidth, mid1.y-lineWidth, lineWidth*2, lineWidth*2);
    CGRect dirtyPoint2 = CGRectMake(mid2.x-lineWidth, mid2.y-lineWidth, lineWidth*2, lineWidth*2);
    CGRect rectToRefresh = CGRectUnion(dirtyPoint1, dirtyPoint2);
    [self setNeedsDisplayInRect:rectToRefresh];
    CGContextSetBlendMode(cacheContext,kCGBlendModeNormal);
    return rectToRefresh;
}

- (CGPoint)calculateMidPointForPoint:(CGPoint)p1 andPoint:(CGPoint)p2 {
    return CGPointMake((p1.x+p2.x)/2, (p1.y+p2.y)/2);
}

- (void) renderLineFromPoint:(CGPoint)point0 toPoint:(CGPoint)point1 toPoint:(CGPoint)point2 toPoint:(CGPoint)point3{
    if(point1.x > -1){
        
        [self initContextIfNeed];
        
        UIColor *color = [UIColor redColor];
        
        
        CGContextSetStrokeColorWithColor(cacheContext, [color CGColor]);
        CGContextSetLineCap(cacheContext, kCGLineCapRound);
        CGContextSetLineWidth(cacheContext, 15);
        
        double x0 = (point0.x > -1) ? point0.x : point1.x; //after 4 touches we should have a back anchor point, if not, use the current anchor point
        double y0 = (point0.y > -1) ? point0.y : point1.y; //after 4 touches we should have a back anchor point, if not, use the current anchor point
        double x1 = point1.x;
        double y1 = point1.y;
        double x2 = point2.x;
        double y2 = point2.y;
        double x3 = point3.x;
        double y3 = point3.y;
        // Assume we need to calculate the control
        // points between (x1,y1) and (x2,y2).
        // Then x0,y0 - the previous vertex,
        //      x3,y3 - the next one.
        
        double xc1 = (x0 + x1) / 2.0;
        double yc1 = (y0 + y1) / 2.0;
        double xc2 = (x1 + x2) / 2.0;
        double yc2 = (y1 + y2) / 2.0;
        double xc3 = (x2 + x3) / 2.0;
        double yc3 = (y2 + y3) / 2.0;
        
        double len1 = sqrt((x1-x0) * (x1-x0) + (y1-y0) * (y1-y0));
        double len2 = sqrt((x2-x1) * (x2-x1) + (y2-y1) * (y2-y1));
        double len3 = sqrt((x3-x2) * (x3-x2) + (y3-y2) * (y3-y2));
        
        double k1 = len1 / (len1 + len2);
        double k2 = len2 / (len2 + len3);
        
        double xm1 = xc1 + (xc2 - xc1) * k1;
        double ym1 = yc1 + (yc2 - yc1) * k1;
        
        double xm2 = xc2 + (xc3 - xc2) * k2;
        double ym2 = yc2 + (yc3 - yc2) * k2;
        double smooth_value = 0.8;
        // Resulting control points. Here smooth_value is mentioned
        // above coefficient K whose value should be in range [0...1].
        float ctrl1_x = xm1 + (xc2 - xm1) * smooth_value + x1 - xm1;
        float ctrl1_y = ym1 + (yc2 - ym1) * smooth_value + y1 - ym1;
        
        float ctrl2_x = xm2 + (xc2 - xm2) * smooth_value + x2 - xm2;
        float ctrl2_y = ym2 + (yc2 - ym2) * smooth_value + y2 - ym2;
        
        CGContextMoveToPoint(cacheContext, point1.x, point1.y);
        CGContextAddCurveToPoint(cacheContext, ctrl1_x, ctrl1_y, ctrl2_x, ctrl2_y, point2.x, point2.y);
        CGContextStrokePath(cacheContext);
        
        CGRect dirtyPoint1 = CGRectMake(point1.x-10, point1.y-10, 20, 20);
        CGRect dirtyPoint2 = CGRectMake(point2.x-10, point2.y-10, 20, 20);
        [self setNeedsDisplayInRect:CGRectUnion(dirtyPoint1, dirtyPoint2)];
    }
}

- (UIImage *)snapshot{
    if (cacheContext == NULL) {
        return nil;
    }
    CGImageRef cacheImage = CGBitmapContextCreateImage(cacheContext);
    UIImage *image = [UIImage imageWithCGImage:cacheImage scale:1 orientation:UIImageOrientationUpMirrored];
    CGImageRelease(cacheImage);
    return image;
}

- (CGRect)editFromRect: (CGRect) rect withScale: (float) scale{
    CGRect newRect = rect;
    newRect.origin.x = rect.origin.x*scale;
    newRect.origin.y = rect.origin.y*scale;
    newRect.size.width = rect.size.width*scale;
    newRect.size.height = rect.size.height*scale;
    return newRect;
}

- (CGRect)renderImage: (UIImage *) image fromPoint: (CGPoint) pointToDraw{
    
    CGRect rectToDraw = CGRectMake(pointToDraw.x, pointToDraw.y, image.size.width, image.size.height);
    return [self renderImage:image inRect:rectToDraw];
}

- (CGRect)renderImage: (UIImage *) image inRect: (CGRect) rect{
    
    [self initContextIfNeed];
    UIImage *image2 = [self mirrorFromImage:image];
    CGContextDrawImage(cacheContext, [self editFromRect:rect withScale:scaleScreen], image2.CGImage);
    [self setNeedsDisplayInRect:rect];
    return rect;
}

- (CGRect)replaceImage: (UIImage *) image fromPoint: (CGPoint) pointToDraw{
    
    CGRect rectToDraw = CGRectMake(pointToDraw.x, pointToDraw.y, image.size.width, image.size.height);
    return [self replaceImage:image inRect:rectToDraw];
}

- (CGRect)replaceImage: (UIImage *) image inRect: (CGRect) rect{
    
    [self initContextIfNeed];
    CGContextDrawImage(cacheContext, rect, image.CGImage);
    [self setNeedsDisplayInRect:rect];
    return rect;
}

-(UIImage*) mirrorFromImage:(UIImage*) src
{
    UIGraphicsBeginImageContext(src.size);
    
    CGContextRef context=(UIGraphicsGetCurrentContext());
    CGContextRotateCTM (context, 90/180*M_PI) ;
    CGContextDrawImage(context, CGRectMake(0, 0, src.size.width, src.size.height), src.CGImage);

    UIImage *img=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
    
}

- (void)clear{
    if (cacheContext != NULL) {
        CGContextClearRect(cacheContext, [self editFromRect:self.bounds withScale:scaleScreen]);
        [self setNeedsDisplay];
    }
}

- (void) drawRect:(CGRect)rect {
    if (cacheContext != NULL) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGImageRef cacheImage = CGBitmapContextCreateImage(cacheContext);
        CGContextDrawImage(context, self.bounds, cacheImage);
        CGImageRelease(cacheImage);
    }
    
}

- (void)dealloc{
    [self releaseContext];
}


- (BOOL)saveImage: (UIImage*)image{
    if (image != nil)
    {
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:
                          _name];
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
        [data writeToFile:path options:NSDataWritingAtomic error:&error];
        if (error) {
            return NO;
        }
        return YES;
    }
    return NO;
}

- (UIImage*)loadImage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      _name];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

@end
