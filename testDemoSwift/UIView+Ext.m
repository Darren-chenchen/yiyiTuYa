//
//  UIView+Ext.m
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/24.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

#import "UIView+Ext.h"

@implementation UIView (Ext)
- (UIColor*) getPixelColorAtLocation:(CGPoint)point inImage:(UIImage *)image {
    UIColor* color = nil;
    CGImageRef inImage = image.CGImage;
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    
    if (cgctx == NULL) {
        return nil; /* error */
    }
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    CGContextDrawImage(cgctx, rect, inImage);
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        int offset = 4*((w*round(point.y))+round(point.x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:
                 (blue/255.0f) alpha:(alpha/255.0f)];
    }
    CGContextRelease(cgctx);
    if (data) {
        free(data);
    }
    return color;
}
- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    bitmapBytesPerRow = (pixelsWide * 4);
    bitmapByteCount = (bitmapBytesPerRow * pixelsHigh);
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL){
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL){
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    context = CGBitmapContextCreate (bitmapData,pixelsWide,pixelsHigh,8,bitmapBytesPerRow,colorSpace,kCGImageAlphaPremultipliedFirst);
    if (context == NULL){
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    CGColorSpaceRelease( colorSpace );
    return context;
}

- (UIColor *) colorOfPoint:(CGPoint)point
{
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
//    NSLog(@"pixel: %d %d %d %d", pixel[0], pixel[1], pixel[2], pixel[3]);
    
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    

    
    return color;
}
@end
