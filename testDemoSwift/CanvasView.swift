//
//  CanvasView.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/19.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
// 

import UIKit

class CanvasView: UIView {
    
    //画笔颜色
    var brushColor: UIColor?
    //画笔宽度
    var brushWidth: NSInteger = 0
    //是否是橡皮擦
    var isEraser: Bool = false
    
    //画笔容器
    var brushArray = [BrushTools]()
    
    //合成View
    var composeView: UIImageView?

    func setupBrushWith(brush:BrushTools) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.lineWidth = 10
        
        if (!brush.isEraser){
            shapeLayer.path = brush.bezierPath?.cgPath
        }
        
        self.layer.addSublayer(shapeLayer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 获得触摸对象
        let touch = touches.first
        // 获得触摸的点
        let startPoint = touch?.location(in: touch?.view)
        
        let brush = BrushTools()
        brush.brushColor = self.brushColor
        brush.brushWidth = self.brushWidth
        brush.isEraser = self.isEraser
        brush.beginPoint = startPoint
        
        brush.bezierPath = UIBezierPath()
        brush.bezierPath?.move(to: startPoint!)
        self.brushArray.append(brush)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 获取触摸对象
        let touch = touches.first
        // 获得当前的点
        let currentPoint = touch?.location(in: touch?.view)
        
        let brush = self.brushArray.last
        
        if self.isEraser {
            brush?.bezierPath?.addLine(to: currentPoint!)
            self.setupEraseBrush(bezierPath: (brush?.bezierPath)!)
        } else {
//            brush?.bezierPath?.removeAllPoints()
//            brush?.bezierPath?.move(to: (brush?.beginPoint)!)
            brush?.bezierPath?.addLine(to: currentPoint!)
        }
        
        //在画布上画线
        self.setupBrushWith(brush: brush!)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesMoved(touches, with: event)
    }
    
    //橡皮擦
    func setupEraseBrush(bezierPath:UIBezierPath) {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
//        self.bottomImageView?.image?.draw(in: self.bounds)
        UIColor.clear.set()
        bezierPath.lineWidth = 10
        bezierPath.stroke(with: .clear, alpha: 1)
        bezierPath.stroke()
//        self.bottomImageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
    }


}
