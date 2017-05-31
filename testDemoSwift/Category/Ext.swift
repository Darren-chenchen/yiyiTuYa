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
    static func scaleImage(image: UIImage) -> UIImage {
        // 画板高度
        let boardH = KScreenHeight-64-50-40
        // 图片大小   UIScreen.main.scale屏幕密度，不加这个图片会不清晰
        UIGraphicsBeginImageContextWithOptions(CGSize(width:KScreenWidth,height:boardH), false, UIScreen.main.scale)
        // 真正图片显示的位置
        // 图片的宽高比
        let picBili: CGFloat = image.size.width/image.size.height
        // 画板的宽高比
        let boardBili: CGFloat = KScreenWidth/boardH
        
        // 如果图片太长，以高为准,否则以宽为准
        if picBili<=boardBili {
            image.draw(in: CGRect(x: 0.5*(KScreenWidth-boardH*picBili), y: 0, width: boardH*picBili, height: boardH))
        } else {
            image.draw(in: CGRect(x: 0, y:0.5*(boardH-KScreenWidth/picBili) , width: KScreenWidth, height: KScreenWidth/picBili))
        }
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        //对图片包得大小进行压缩
        let imageData =  UIImagePNGRepresentation(scaledImage!)
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
