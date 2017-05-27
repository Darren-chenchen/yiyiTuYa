//
//  DrawBoard.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/19.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
// 参考：http://blog.csdn.net/zhangao0086/article/details/43836789

import UIKit

// 开始编辑就改变撤销按钮的状态，让其可以点击
typealias beginDrawClouse = () -> ()
// 当撤销到第一张图片，
typealias undoUnableActionClouse = () -> ()
// 前进到最后一张图片就让按钮不可点击
typealias redoUnableActionClouse = () -> ()

enum DrawingState {
    case began, moved, ended
}

class DrawBoard: UIImageView {
    
    fileprivate class DBUndoManager {
        fileprivate var index = -1
        // 数组中保存图片
        var imageArray = [UIImage]()
        
        var canUndo: Bool {
            get {
                return index != -1
            }
        }
        
        var canRedo: Bool {
            get {
                return index + 1 <= imageArray.count
            }
        }
        
        func addImage(_ image: UIImage) {
            // 添加之前先判断是不是还原到最初的状态
            if index == -1 {
                imageArray.removeAll()
            }
            
            imageArray.append(image)
            index = imageArray.count - 1
        }
        
        func imageForUndo() -> UIImage? {
            index = index-1
            if index>=0 {
                return imageArray[index]
            } else {
                index = -1
                return nil
            }
        }
        
        func imageForRedo() -> UIImage? {
            index = index+1
            if index<=imageArray.count-1 {
                return imageArray[index]
            } else {
                index = imageArray.count-1
                return imageArray[imageArray.count-1]
            }
        }
    }
    
    // 开始绘画就让控制器中的返回按钮可点击
    var beginDraw: beginDrawClouse?
    // 不能再撤销或者前进
    var unableDraw: undoUnableActionClouse?
    var reableDraw: redoUnableActionClouse?

    fileprivate var boardUndoManager = DBUndoManager() // 缓存或Undo控制器
    var canUndo: Bool {
        get {
            return self.boardUndoManager.canUndo
        }
    }
    
    var canRedo: Bool {
        get {
            return self.boardUndoManager.canRedo
        }
    }
    
    // 绘图状态
    fileprivate var drawingState: DrawingState!
    // 绘图的基类
    var brush: BaseBrush?
    //保存当前的图形
    private var realImage: UIImage?
    var strokeWidth: CGFloat = 4.5
    // 画笔颜色，文本输入框的字体颜色
    var strokeColor: UIColor = UIColor.black
    // 文本编辑状态,文本的字体大小
    var textFont: UIFont = UIFont.systemFont(ofSize: 16)
    // 文本输入
    lazy var textView: UITextView = {
        let textView = UITextView.init(frame: CGRect(x: (self.brush?.beginPoint.x)!, y: (self.brush?.beginPoint.y)!, width: KScreenWidth-(self.brush?.endPoint.x)!-10, height: 200))
        textView.backgroundColor = UIColor.clear
        textView.delegate = self
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.red.cgColor
        return textView
    }()
    // 橡皮擦效果图片
    lazy var eraserImage: UIImageView = {
        let img = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.addSubview(img)
        return img
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.lastPoint = nil
            
            brush.beginPoint = touches.first!.location(in: self)
            brush.endPoint = brush.beginPoint
            
            self.drawingState = .began
            
            // 如果是橡皮擦，展示橡皮擦的效果
            if self.brush?.classForKeyedArchiver == EraserBrush.classForCoder() {
                self.eraserImage.isHidden = false
                let imageW = self.strokeWidth*3
                self.eraserImage.frame = CGRect(origin: brush.beginPoint, size: CGSize(width: imageW, height: imageW))
                self.eraserImage.layer.cornerRadius = imageW*0.5
                self.eraserImage.layer.masksToBounds = true
                self.eraserImage.backgroundColor = mainColor
            }
            
            // 如果是文本输入就展示文本，其他的是绘图
            if self.brush?.classForKeyedArchiver == InputBrush.classForCoder()  {
                self.drawingText()
            } else {
                self.drawingImage()
                if beginDraw != nil {
                    self.beginDraw!()
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.endPoint = touches.first!.location(in: self)
            
            self.drawingState = .moved
            
            // 如果是模糊矩形 就取到手指触摸哪一点的颜色值，讲那个颜色值填满整个小矩形
            if self.brush?.classForKeyedArchiver == RectangleBrush.classForCoder()  {
                self.strokeColor = self.color(of: brush.endPoint)
            }
            
            // 如果是橡皮擦，展示橡皮擦的效果
            if self.brush?.classForKeyedArchiver == EraserBrush.classForCoder() {
                let imageW = self.strokeWidth*3
                self.eraserImage.frame = CGRect(origin: brush.endPoint, size: CGSize(width: imageW, height: imageW))
            }

            if self.brush?.classForKeyedArchiver == InputBrush.classForCoder()  {
                self.drawingText()
            } else {
                self.drawingImage()
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.endPoint = nil
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.endPoint = touches.first!.location(in: self)
            
            self.drawingState = .ended
            
            // 如果是橡皮擦，展示橡皮擦的效果
            if self.brush?.classForKeyedArchiver == EraserBrush.classForCoder() {
                self.eraserImage.isHidden = true
            }
            
            if self.brush?.classForKeyedArchiver == InputBrush.classForCoder()  {
                self.drawingText()
            } else {
                self.drawingImage()
            }
        }
    }
    
    //MARK: - 写文字
    fileprivate func drawingText() {
        self.textView.text = nil
        self.textView.textColor = self.strokeColor
        self.textView.font = self.textFont
        self.addSubview(self.textView)
        self.textView.frame = CGRect(x: (self.brush?.beginPoint.x)!, y: (self.brush?.beginPoint.y)!, width: KScreenWidth-(self.brush?.endPoint.x)!-10, height: 200)
        self.textView.becomeFirstResponder()
    }
    
    //MARK: - 将文本与图片融合
    fileprivate func DrawTextAndImage(text: String){
        //开启图片上下文
        UIGraphicsBeginImageContext(self.bounds.size)
        //图形重绘
        self.draw(self.bounds)
        //水印文字属性
        let att = [NSForegroundColorAttributeName:self.strokeColor,NSFontAttributeName:self.textFont,NSBackgroundColorAttributeName:UIColor.clear] as [String : Any]
        //水印文字大小
        let text = NSString(string: text)
        //绘制文字 ,文字显示的位置，要在textview的适当位置
        text.draw(in: CGRect(x:self.textView.frame.origin.x+5,y:self.textView.frame.origin.y+10,width:self.textView.frame.width,height:self.textView.frame.height), withAttributes: att)
        //从当前上下文获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        self.image = image
        
        self.realImage = image
        
        // 缓存图片
        // 如果是第一次绘制,同时让前进按钮处于不可点击状态
        if self.boardUndoManager.index == -1 {
            if self.reableDraw != nil {
                self.reableDraw!()
            }
        }
        self.boardUndoManager.addImage(self.image!)
        if beginDraw != nil {
            self.beginDraw!()
        }
    }
    
    // MARK: - drawing
    fileprivate func drawingImage() {
        if let brush = self.brush {
            
            // 1.开启一个新的ImageContext，为保存每次的绘图状态作准备。
            UIGraphicsBeginImageContext(self.bounds.size)
            
            // 2.初始化context，进行基本设置（画笔宽度、画笔颜色、画笔的圆润度等）。
            let context = UIGraphicsGetCurrentContext()
            
            UIColor.clear.setFill()
            UIRectFill(self.bounds)
            
            context?.setLineCap(CGLineCap.round)
            context?.setLineWidth(self.strokeWidth)
            context?.setStrokeColor(self.strokeColor.cgColor)
            
            // 模糊矩形可以用到，用于填充矩形
            context?.setFillColor(self.strokeColor.cgColor)
            
            // 3.把之前保存的图片绘制进context中。
            if let realImage = self.realImage {
                realImage.draw(in: self.bounds)
            }
            
            // 4.设置brush的基本属性，以便子类更方便的绘图；调用具体的绘图方法，并最终添加到context中。
            brush.strokeWidth = self.strokeWidth
            brush.drawInContext(context!)
            context?.strokePath()

            // 5.从当前的context中，得到Image，如果是ended状态或者需要支持连续不断的绘图，则将Image保存到realImage中。
            let previewImage = UIGraphicsGetImageFromCurrentImageContext()
            if self.drawingState == .ended || brush.supportedContinuousDrawing() {
                self.realImage = previewImage
            }
            UIGraphicsEndImageContext()
            // 6.实时显示当前的绘制状态，并记录绘制的最后一个点
            self.image = previewImage;
            
            // 用 Ended 事件代替原先的 Began 事件
            if self.drawingState == .ended {
                // 如果是第一次绘制,同时让前进按钮处于不可点击状态
                if self.boardUndoManager.index == -1 {
                    if self.reableDraw != nil {
                        self.reableDraw!()
                    }
                }
                self.boardUndoManager.addImage(self.image!)
            }
            
            brush.lastPoint = brush.endPoint
        }
    }
    
    //MARK: - 返回画板上的图片，用于保存
    func takeImage() -> UIImage {
        UIGraphicsBeginImageContext(self.bounds.size)
        
        self.backgroundColor?.setFill()
        UIRectFill(self.bounds)
        
        self.image?.draw(in: self.bounds)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    // 撤销
    func undo() {
        if self.canUndo == false {
            return
        }
        self.image = self.boardUndoManager.imageForUndo()
        self.realImage = self.image
        
        // 已经撤销到第一张图片
        if self.boardUndoManager.index == -1 {
            if self.unableDraw != nil {
                self.unableDraw!()
            }
        }
    }
    // 前进
    func redo() {
        if self.canRedo == false {
            return
        }
        self.image = self.boardUndoManager.imageForRedo()
        self.realImage = self.image
        
        // 已经撤前进到最后一张图片
        if self.boardUndoManager.index == self.boardUndoManager.imageArray.count-1 {
            if self.reableDraw != nil {
                self.reableDraw!()
            }
        }
    }
    // 还原
    func retureAction() {
        self.image = nil
        self.realImage = self.image
    }
    
    // 是否可以撤销
    func canBack() -> Bool {
        return self.canUndo
    }
    // 是否可以前进
    func canForward() -> Bool {
        return self.canRedo
    }

}

//MARK: - UITextViewDelegate
extension DrawBoard:UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        self.DrawTextAndImage(text: textView.text)
        self.textView.removeFromSuperview()
    }
}
