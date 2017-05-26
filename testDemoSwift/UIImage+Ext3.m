//
//  UIImage+Ext3.m
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/22.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

#import "UIImage+Ext3.h"

#define kBitsPerComponent (8)
#define kBitsPerPixel (32)
#define kPixelChannelCount (4)

@implementation UIImage (Ext3)


/*
 *转换成马赛克,level代表一个点转为多少level*level的正方形
 */
+ (UIImage *)transToMosaicImage:(UIImage*)orginImage blockLevel:(NSUInteger)level
{
    //获取BitmapData
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = orginImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  kBitsPerComponent,        //每个颜色值8bit
                                                  width*kPixelChannelCount, //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit
                                                  colorSpace,
                                                  kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    unsigned char *bitmapData = CGBitmapContextGetData (context);
    
    //这里把BitmapData进行马赛克转换,就是用一个点的颜色填充一个level*level的正方形
    unsigned char pixel[kPixelChannelCount] = {0};
    NSUInteger index,preIndex;
    for (NSUInteger i = 0; i < height - 1 ; i++) {
        for (NSUInteger j = 0; j < width - 1; j++) {
            index = i * width + j;
            if (i % level == 0) {
//                if (j % level == 0) {
//                    memcpy(pixel, bitmapData + kPixelChannelCount*index, kPixelChannelCount);
//                }else{
//                    memcpy(bitmapData + kPixelChannelCount*index, pixel, kPixelChannelCount);
//                }
            } else {
                preIndex = (i-1)*width +j;
                memcpy(bitmapData + kPixelChannelCount*index, bitmapData + kPixelChannelCount*preIndex, kPixelChannelCount);
            }
        }
    }
    
    NSInteger dataLength = width*height* kPixelChannelCount;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData, dataLength, NULL);
    //创建要输出的图像
    CGImageRef mosaicImageRef = CGImageCreate(width, height, kBitsPerComponent, kBitsPerPixel, width*kPixelChannelCount, colorSpace, kCGBitmapByteOrder32Little, provider, NULL, NO, kCGRenderingIntentDefault);
    
    CGContextRef outputContext = CGBitmapContextCreate(nil,
                                                       width,
                                                       height,
                                                       kBitsPerComponent,
                                                       width*kPixelChannelCount,
                                                       colorSpace,
                                                       kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(outputContext, CGRectMake(0.0f, 0.0f, width, height), mosaicImageRef);
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outputContext);
    UIImage *resultImage = nil;
    if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
        float scale = [[UIScreen mainScreen] scale];
        resultImage = [UIImage imageWithCGImage:resultImageRef scale:scale orientation:UIImageOrientationUp];
    } else {
        resultImage = [UIImage imageWithCGImage:resultImageRef];
    }
    //释放
    if(resultImageRef){
        CFRelease(resultImageRef);
    }
    if(mosaicImageRef){
        CFRelease(mosaicImageRef);
    }
    if(colorSpace){
        CGColorSpaceRelease(colorSpace);
    }
    if(provider){
        CGDataProviderRelease(provider);
    }
    if(context){
        CGContextRelease(context);
    }
    if(outputContext){
        CGContextRelease(outputContext);
    }
    return resultImage;
    
}

+ (UIImage *)scaleImage:(UIImage *)image toScale:(CGFloat)scaleSize
{
    //设置图片尺寸
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0.5*(image.size.width-image.size.width * scaleSize), 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //对图片包得大小进行压缩
    NSData *imageData = UIImageJPEGRepresentation(scaledImage,0.0001);
    UIImage *m_selectImage = [UIImage imageWithData:imageData];
    return m_selectImage;
}

+ (UIImage *)convertToBlurImage:(UIImage *)image{
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    CIImage *inputImage = [CIImage imageWithCGImage:[image CGImage]];
    [gaussianBlurFilter setValue:inputImage forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:@10 forKey:kCIInputRadiusKey];
    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context   = [CIContext contextWithOptions:nil];
    CGImageRef cgimg     = [context createCGImage:outputImage fromRect:[inputImage extent]];  // note, use input image extent if you want it the same size, the output image extent is larger
    UIImage *convertedImage = [UIImage imageWithCGImage:cgimg];
    return convertedImage;
}

//压缩图片
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

+ (UIImage*)imageProcess:(UIImage*)image{
    //第一步：确定图片的宽高
    /*
     两种方案
     1 image.size.width
     2 GImageGetWidth(<#CGImageRef  _Nullable image#>)
     
     */
    CGImageRef imageRef = image.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    //第二步：创建颜色空间
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    //第三部：创建图片上下文(解析图片信息，绘制图片)
    /*
     开辟内存空间，这块空间用于处理马赛克图片
     参数1：数据源
     参数2：图片宽
     参数3：图片高
     参数4：表示每一个像素点，每一个分量大小
     在我们图像学中，像素点：ARGB组成 每一个表示一个分量（例如，A，R，G，B）
     在我们计算机图像学中每一个分量的大小是8个字节
     参数5：每一行大小（其实图片是由像素数组组成的）
     如何计算每一行的大小，所占用的内存
     首先计算每一个像素点大小（我们取最大值）： ARGB是4个分量 = 每个分量8个字节 * 4
     参数6:颜色空间
     参数7:是否需要透明度
     
     */
    CGContextRef contextRef = CGBitmapContextCreate(nil, width, height, 8, width*4, colorSpaceRef, kCGImageAlphaPremultipliedLast);
    
    //第四步：根据图片上下文绘制图片
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    //第五步：获取图片的像素数组
    unsigned char * bitMapData = CGBitmapContextGetData(contextRef);
    
    //第六步：图片打码，加入马赛克
    /*
     核心算法
     马赛克：将图片模糊，（马赛克算法可以是可逆，也可以是不可逆，取决于打码的算法）
     对图片进行采样
     
     我们今天处理的原理：让一个像素点替换为和它相同的矩形区域（正方形，圆形都可以）
     矩形区域包含了N个像素点
     
     */
    
    //选择马赛克区域
    //矩形区域：认为是打码的级别，马赛克点的大小（失真的强度）
    //这里将级别写死了level
    //level 马赛克点的大小
    NSUInteger currentIndex , preCurrentIndex, level = 3;
    //像素点默认是4个通道,默认值是0
    unsigned char * pixels[4] = {0};
    for (NSUInteger i = 0; i < height - 1; i++) {
        for (NSUInteger j = 0; j < width - 1; j++) {
            //循环便利每一个像素点，然后筛选，打码
            //获取当前像素点坐标-》指针位移方式处理像素点-》修改
            //指针位移
            currentIndex = (i * width) + j ;
            //计算矩形的区域
            /*
             分析下面筛选算法（组成马赛克点，矩形算法）
             假设：level = 3 （3*3的矩形）
             
             
             宽的规律：========
             第一步：i=0 j=0 level=3  i%level = 0  j%level=0
             第一次运行循环：
             memcpy(pixels, bitMapData+4*currentIndex, 4) 给我们的像素点赋值
             在这里我们以字节作为单位来获取，一个像素=4个字节，bitMapData+4*currentIndex一个像素点的读取，每次读区4个字节（开始的位置）
             第一次运行结果：获取第一个像素点的值
             
             第二步循环结果：
             i=0 j=1 i%level=0 j%level=1
             memcpy(bitMapData+4*currentIndex, pixels, 4);将第一个像素点的值拷贝复制替换给第二个像素点（指针位移方式计算）
             循环结果：第一个像素点值 赋值给 第二个像素点
             
             
             第三次运行循环：第一行第三列
             i=0 j=2 level=3
             i%level=0 j%level=2
             循环结果：第三次像素点的值 = 第一次像素点的值
             
             
             
             高的规律：
             i=1 j=1
             
             
             preCurrentIndex = (i - 1) * width + j;
             memcpy(bitMapData+4*currentIndex, bitMapData+4*preCurrentIndex, 4);
             
             第二行第一个像素点的值 = 第一行i 一个像素点的值
             
             */
            
            //通过这个算法，截取了一个3*3的一个矩形
            
            if (i % level==0) {
                if (j % level==0) {
                    //拷贝区域 c语言拷贝数据的函数
                    /*
                     参数1:拷贝目标（像素点）
                     参数2:源文件
                     参数3:要截取的长度（字节计算）
                     */
                    memcpy(pixels, bitMapData+4*currentIndex, 4);
                    
                }else{
                    //将上一个像素点的值赋值给第二个（指针位移的方式计算原理）
                    memcpy(bitMapData+4*currentIndex, pixels, 4);
                }
                
            }else{
                /*
                 例如：i=1  j=0
                 preCurrentIndex = (i - 1) * width + j;
                 */
                preCurrentIndex = (i - 1) * width + j;
                memcpy(bitMapData+4*currentIndex, bitMapData+4*preCurrentIndex, 4);
            }
            
            
        }
    }
    
    //第七步：获取图片数据集合
    NSUInteger size = width * height * 4;
    CGDataProviderRef providerRef = CGDataProviderCreateWithData(NULL, bitMapData, size, NULL);
    //第八部：创建马赛克图片
    /*
     参数1:宽
     参数2:高
     参数3:表示每一个像素点，每一个分量的大小
     参数4:每一个像素点的大小
     参数5:每一行内存大小
     参数6:颜色空间
     参数7:位图信息
     参数8:数据源（数据集合）
     参数9:数据解码器
     参数10:是否抗锯齿
     参数11:渲染器
     */
    CGImageRef mossicImageRef = CGImageCreate(width,
                                              height,
                                              8,
                                              4*8,
                                              width*4,
                                              colorSpaceRef,kCGImageAlphaPremultipliedLast,
                                              providerRef,
                                              NULL,
                                              NO,
                                              kCGRenderingIntentDefault);
    
    //第九步：创建输出马赛克图片（填充颜色）
    CGContextRef outContextRef = CGBitmapContextCreate(nil,
                                                       width,
                                                       height,
                                                       8,
                                                       width*4,
                                                       colorSpaceRef,
                                                       kCGImageAlphaPremultipliedLast);
    //绘制图片
    CGContextDrawImage(outContextRef, CGRectMake(0, 0, width, height),mossicImageRef);
    
    //创建图片
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outContextRef);
    UIImage *outImage = [UIImage imageWithCGImage:resultImageRef];
    
    
    
    //释放内存
    CGImageRelease(resultImageRef);
    CGImageRelease(mossicImageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(providerRef);
    CGContextRelease(outContextRef);
    
    
    
    return outImage;
}

@end
