//
//  ScreenCaptureView.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/19.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

class ScreenCaptureView: UIView {

    //底层的scrollview
    var scrollView: UIScrollView?
    // scrollView上的截图
    var bottomImageView: UIImageView?
    
    //画笔颜色
    var brushColor: UIColor?
    //画笔宽度
    var brushWidth: NSInteger = 0
    //是否是橡皮擦
    var isEraser: Bool = false
    
    //画板View
    var canvasView: CanvasView?
    //画笔容器
    var brushArray = [BrushTools]()

    
    static func initCaptureView(shotImage:UIImage) -> ScreenCaptureView{
        let shotView = ScreenCaptureView()
        shotView.setupUI(shotImage: shotImage)
        return shotView
    }
    
    func setupUI(shotImage:UIImage) {
        
        self.frame = CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight-50)
        
        scrollView = UIScrollView()
        scrollView?.frame = CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight-50)
        scrollView?.contentSize = CGSize(width: KScreenWidth, height: shotImage.size.height)
        self.addSubview(scrollView!)
        
        bottomImageView = UIImageView.init(frame:CGRect(x: 0, y: 0, width: KScreenWidth, height: shotImage.size.height))
        bottomImageView?.image = shotImage
        scrollView?.addSubview(bottomImageView!)
        
        // 画板
        canvasView = CanvasView()
        canvasView?.brushWidth = 10
        canvasView?.brushColor = self.brushColor
        canvasView?.frame = (bottomImageView?.bounds)!
        scrollView?.addSubview(canvasView!)
    }
    
}
