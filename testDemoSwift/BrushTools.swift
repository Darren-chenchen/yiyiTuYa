//
//  BrushTools.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/19.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//  画笔工具

import UIKit

class BrushTools: NSObject {

    //画笔颜色
    var brushColor: UIColor?
    //画笔宽度
    var brushWidth: NSInteger = 0
    //是否是橡皮擦
    var isEraser: Bool = false
    //路径
    var bezierPath: UIBezierPath?
    //起点
    var beginPoint: CGPoint?
    //终点
    var endPoint: CGPoint?
}
