//
//  Ext.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/22.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

let kBitsPerComponent:CGFloat = 8
let kBitsPerPixel = 32
let kPixelChannelCount:CGFloat = 4

extension UIImage {
    /*
    *转换成马赛克,level代表一个点转为多少level*level的正方形  经测试不适用于ios8
     */
    static func transToMosaicImage(orginImage: UIImage,level: NSInteger) -> UIImage {
        
        //获取BitmapData
        let colorSpace: CGColorSpace? = CGColorSpaceCreateDeviceRGB()
        let imgRef: CGImage? = orginImage.cgImage
        let width: CGFloat = CGFloat(imgRef!.width)
        let height: CGFloat = CGFloat(imgRef!.height)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: Int(kBitsPerComponent), bytesPerRow: Int(width * kPixelChannelCount), space: colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard context != nil else {
            return UIImage()
        }
        
        context?.draw(imgRef!, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let bitmapData = context!.data
        
        //这里把BitmapData进行马赛克转换,就是用一个点的颜色填充一个level*level的正方形
        var index: Int = 0
        var preIndex: Int = 0
        for i in 0..<Int(height)-1 {
            print(i)
            for j in 0..<Int(width) - 1 {
                index = i * Int(width) + j
                if level != 0 {
                    if i % level == 0 {
                        
                    } else {
                        let number = Int(kPixelChannelCount) * index + (bitmapData?.hashValue)!
                        let numberPointer = UnsafeMutablePointer<Any>.init(bitPattern: number)
                        preIndex = (i - 1) * Int(width) + j
                        
                        let number2 = Int(kPixelChannelCount) * preIndex + (bitmapData?.hashValue)!
                        let numberPointer2 = UnsafeMutablePointer<Any>.init(bitPattern: number2)
                        
                        memcpy(numberPointer, numberPointer2, Int(kPixelChannelCount))
                    }
                }
                
            }
        }
        
        let dataLength: Int = Int(width * height * kPixelChannelCount)
        let provider: CGDataProvider = CGDataProvider(dataInfo: nil, data: bitmapData!, size: dataLength) { (Mpoint, RawPoint, index) in
            }!

        //创建要输出的图像        
        let mosaicImageRef = CGImage.init(width: Int(width), height: Int(height), bitsPerComponent: Int(kBitsPerComponent), bitsPerPixel: kBitsPerPixel, bytesPerRow: Int(width * kPixelChannelCount), space: colorSpace!, bitmapInfo: CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue), provider: provider, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
        
        let outputContext = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: Int(kBitsPerComponent), bytesPerRow: Int(width * kPixelChannelCount), space: colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard mosaicImageRef != nil else {
            return UIImage()
        }
        outputContext?.draw(mosaicImageRef!, in: CGRect(x: 0, y: 0, width: width, height: height))
        let resultImageRef: CGImage = outputContext!.makeImage()!
        var resultImage: UIImage? = nil
        if UIImage.responds(to: #selector(UIImage.init(cgImage:scale:orientation:))) {
            let scale: Float = Float(UIScreen.main.scale)
            resultImage = UIImage(cgImage: resultImageRef, scale: CGFloat(scale), orientation: .up)
        } else {
            resultImage = UIImage(cgImage: resultImageRef)
        }
        return resultImage!
    }
    
    // 对截取的长图进行压缩，因为项目中的长图是设置为背景颜色，如果不压缩到适当的尺寸图片就会平铺
    static func scaleImage(image: UIImage,scaleSize:CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width:image.size.width,height:image.size.height*scaleSize))
        image.draw(in: CGRect(x: 0.5*(image.size.width-image.size.width * scaleSize), y: 0, width: image.size.width * scaleSize, height: image.size.height*scaleSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        //对图片包得大小进行压缩
        let imageData =  UIImageJPEGRepresentation(scaledImage!,1)
        let m_selectImage = UIImage.init(data: imageData!)
        return m_selectImage!
    }
    
    // 截取一部分
    static func screenShotForPart(view:UIView,size:CGSize) -> UIImage{
        var image = UIImage()
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
}
