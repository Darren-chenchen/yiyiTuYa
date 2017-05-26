//
//  RectangleBrush.swift
//  DrawingBoard
//
//  Created by ZhangAo on 15-2-16.
//  Copyright (c) 2015年 zhangao. All rights reserved.
// 连续矩形

import UIKit

class RectangleBrush: BaseBrush {
   
    override func drawInContext(_ context: CGContext) {
        // 矩形  不填充
//        context.addRect(CGRect(origin: CGPoint(x: min(beginPoint.x, endPoint.x), y: min(beginPoint.y, endPoint.y)),
//            size: CGSize(width: abs(endPoint.x - beginPoint.x), height: abs(endPoint.y - beginPoint.y))))
        //        context.addRect(CGRect(x: pointX!, y: pointY!, width: 8, height: 8))

        // 模糊矩形  填充 画完一个小正方形之后把终点赋值为起点继续画
        let Width:CGFloat = 10
        var pointX: CGFloat?
        if abs(endPoint.x-beginPoint.x)>Width {
            pointX = endPoint.x
        } else {
            pointX = beginPoint.x
        }
        
        var pointY: CGFloat?
        if abs(endPoint.y-beginPoint.y)>Width {
            pointY = endPoint.y
        } else {
            pointY = beginPoint.y
        }
        context.fill(CGRect(x: pointX!, y: pointY!, width: Width, height: Width))
    }
    
    override func supportedContinuousDrawing() -> Bool {
        return true
    }
}
