//
//  ShotImageView.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/18.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import Foundation

class ScreenShotView: UIView {
    
    // 存放所有路径
    var allLineArray = [UIBezierPath]()
    
    var eraseArray = [UIBezierPath]()

    // 线条颜色
    var drawColor: UIColor!
    // 线条粗细
    var lineWidth: CGFloat = 0
    // 是否是橡皮擦
    var isErase: Bool = false
    var drawImage: UIImageView?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 获得触摸对象
        let touch = touches.first
        // 获得触摸的点
        let startPoint = touch?.location(in: touch?.view)
        // 初始化一个UIBezierPath对象,用来存储所有的轨迹点
        let bezierPath = UIBezierPath()
        // 把起始点存储到UIBezierPath对象中
        bezierPath.move(to: startPoint!)
        // 把当前UIBezierPath对象存储到数组中
        self.allLineArray.append(bezierPath)
        
        if isErase {
            self.eraseArray.append(bezierPath)
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 获取触摸对象
        let touch = touches.first
        // 获得当前的点
        let currentPoint = touch?.location(in: touch?.view)
        // 获得数组中的最后一个UIBezierPath对象(因为我们每次都把UIBezierPath存入到数组最后一个,因此获取时也取最后一个)
        if isErase {
            let bezierPath = self.eraseArray.last
            bezierPath?.addLine(to: currentPoint!)
        }
        let bezierPath = self.allLineArray.last
        // 把当前点加入到bezierPath中
        bezierPath?.addLine(to: currentPoint!)
        // 每移动一次就重新绘制当前视图
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        //设置填充颜色
        drawColor?.setStroke()
        if self.allLineArray.count == 0 {
            return
        }
        for bezierPath in self.allLineArray {
            bezierPath.lineWidth = lineWidth // 设置画笔线条粗细
            bezierPath.stroke()
        }
        
    }
    
    //橡皮擦
    func setupEraseBrush(bezierPath:UIBezierPath) {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
//        self.drawImage?.image?.draw(in: self.bounds)
        UIColor.clear.set()
        bezierPath.lineWidth = 10
        bezierPath.stroke(with: .clear, alpha: 1)
        bezierPath.stroke()
//        self.drawImage?.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
    }
}
