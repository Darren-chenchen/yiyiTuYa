//
//  MosaicView.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/22.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import AVFoundation

class MosaicView: UIView {

    /**
     要刮的底图.
     */
    var image: UIImage? {
        didSet{
            self.imageLayer?.contents = image?.cgImage
        }
    }
    /**
     涂层图片.
     */
    var surfaceImage: UIImage? {
        didSet{
            self.surfaceImageView?.image = surfaceImage
        }
    }
    
    var surfaceImageView: UIImageView?
    
    var imageLayer: CALayer?

    var shapeLayer: CAShapeLayer?
    //设置手指的涂抹路径
    var path: CGMutablePath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //添加imageview（surfaceImageView）到self上
        self.surfaceImageView = UIImageView.init(frame: self.bounds)
        self.addSubview(self.surfaceImageView!)
        
        //添加layer（imageLayer）到self上
        self.imageLayer = CALayer()
        self.imageLayer?.frame = self.bounds
        self.layer.addSublayer(self.imageLayer!)
        
        self.shapeLayer = CAShapeLayer()
        self.shapeLayer?.frame = self.bounds
        self.shapeLayer?.lineCap = kCALineCapRound
        self.shapeLayer?.lineJoin = kCALineJoinRound
        self.shapeLayer?.lineWidth = 10
        self.shapeLayer?.strokeColor = UIColor.blue.cgColor
        self.shapeLayer?.fillColor = nil //此处设置颜色有异常效果，可以自己试试
        
        self.layer.addSublayer(self.shapeLayer!)
        self.imageLayer?.mask = self.shapeLayer
        self.path = CGMutablePath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first
        let point = touch?.location(in: self)
        
        self.path?.move(to: CGPoint(x: (point?.x)!, y: (point?.y)!))
        self.shapeLayer?.path = self.path
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        let touch = touches.first
        let point = touch?.location(in: self)

        self.path?.addLine(to: CGPoint(x: (point?.x)!, y: (point?.y)!))
        self.shapeLayer?.path = self.path


    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

    }
}
