//
//  Ext.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/22.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

extension UIImage {
    // 对截取的长图进行压缩，因为项目中的长图是设置为背景颜色，如果不压缩到适当的尺寸图片就会平铺
    static func scaleImage(image: UIImage,scaleSize:CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width:image.size.width,height:image.size.height*scaleSize))
        image.draw(in: CGRect(x: 0.5*(KScreenWidth-image.size.width * scaleSize), y: 0, width: image.size.width * scaleSize, height: image.size.height*scaleSize))
        
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
