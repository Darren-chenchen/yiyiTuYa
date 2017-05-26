//
//  UIViewExt.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/24.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

extension UIView {
    
    func getPixelColor(pos:CGPoint,image:UIImage)-> UIColor {
        let pixelData=image.cgImage!.dataProvider!.data
        let data:UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = ((Int(image.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    
    func colorOfPoint(point: CGPoint) -> UIColor {
        
//        let pixel
        var obj = 4
        var array = [0]

//        let pixel = UnsafeMutableRawPointer.init(bitPattern: obj)
//        let pixel = getMutablePointer(ptr: &array)
//        let pixel = UnsafeMutablePointer<Int>.allocate(capacity: 4)
        
//        var unf = UnsafePointer<CUnsignedChar>.alloc(4)

//        var pixel = UnsafeMutableRawPointer.init(mutating: UnsafeRawPointer.)
//        let pixel =  UnsafeMutableRawPointer(calloc(4, MemoryLayout<Float>.size))
        
//        let pixel = UnsafePointer<CUnsignedChar>.alloc(4)
        let pixel = UnsafeMutablePointer<Int>.allocate(capacity: 4)


        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

//        CGContextRef context = CGBitmapContextCreate(<#void * _Nullable data#>, <#size_t width#>, <#size_t height#>, <#size_t bitsPerComponent#>, <#size_t bytesPerRow#>, <#CGColorSpaceRef  _Nullable space#>, <#uint32_t bitmapInfo#>)
//CGContext.init(data: UnsafeMutableRawPointer?, width: <#T##Int#>, height: <#T##Int#>, bitsPerComponent: <#T##Int#>, bytesPerRow: <#T##Int#>, space: <#T##CGColorSpace#>, bitmapInfo: <#T##UInt32#>)
        let context = CGContext.init(data: pixel, width: 1, height: 1, bitsPerComponent: Int(8), bytesPerRow: Int(4), space: colorSpace, bitmapInfo: UInt32(bitmapInfo.rawValue))
        
        context?.translateBy(x: -point.x, y:  -point.y)
        
        
        self.layer.render(in: context!)
        
        print("\(pixel[0])--\(pixel.advanced(by: 1).pointee)--\(pixel[2])--\(pixel[3])")

//        print("\(pixel[0])--\(pixel[1])--\(pixel[2])--\(pixel[3])")
        
//        return UIColor.red        
        return  UIColor(red: CGFloat(pixel[0])/255.0, green:  CGFloat(pixel[1])/255.0, blue:  CGFloat(pixel[2])/255.0, alpha: 1)
    }
    func blankof<T>(type:T.Type) -> T {
        let ptr = UnsafeMutablePointer<T>.allocate(capacity: MemoryLayout<T>.size)
        let val = ptr.pointee
        ptr.deinitialize()
        return val
    }
    public func getMutablePointer<T>(ptr: UnsafeMutablePointer<T>) -> UnsafeMutablePointer<T> {
        return ptr
    }
    
//    - (UIColor *) colorOfPoint:(CGPoint)point
//    {
//    unsigned char pixel[4] = {0};
//    CGColorSpaceRef colorSpace =  ();
//    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast);
//    
//    CGContextTranslateCTM(context, -point.x, -point.y);
//    
//    [self.layer renderInContext:context];
//    
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
//    
//    NSLog(@"pixel: %d %d %d %d", pixel[0], pixel[1], pixel[2], pixel[3]);
//    
//    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
//    
//    return color;
//    }
}
