//
//  DrawBoard.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/19.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
// 参考：http://blog.csdn.net/zhangao0086/article/details/43836789

import UIKit
import RxCocoa
import RxSwift
import IQKeyboardManager

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
    fileprivate var realImage: UIImage?
    var strokeWidth: CGFloat = 3
    // 画笔颜色，文本输入框的字体颜色
    var strokeColor: UIColor = UIColor.black
    // 文本编辑状态,文本的字体大小
    var textFont: UIFont = UIFont.systemFont(ofSize: 16)
    // 释放
    let disposBag = DisposeBag()
    // 键盘高度
    var kBoardH: CGFloat = 0
    // 展示文字的label
    var lableArray = [UILabel]()
    var currentLable: UILabel!
    // 用于记录文本输入后的image
    var textImageFlag: UIImage!
    // 键盘文本输入
    lazy var drawIputView: BoardInputView = {
        let input = BoardInputView.init(frame: CGRect(x: 0, y: KScreenHeight, width: KScreenWidth, height: 10+24+10+0.5+40))
        win?.addSubview(input)
        return input
    }()
    // 橡皮擦效果图片
    lazy var eraserImage: UIImageView = {
        let img = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.addSubview(img)
        return img
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initEventHendle()
        setupIQBoard()
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
            } else {
                self.drawingImage()
            }
        }
    }
    
    //MARK: - 写文字
    fileprivate func drawingText() {
        var flag = 0
        // 遍历数组，判断触摸点是否在绘制文字所在的文本框内
        for label in lableArray {
            if label.frame.contains((self.brush?.beginPoint)!){
                self.currentLable = label
                flag = flag + 1
            }
        }
        // 没有触摸到label就让currentLable置nil
        if flag == 0 {
            self.currentLable = nil
        }
        
        // 说明是要画文字
        if self.currentLable == nil {
            let lable = UILabel.init(frame: CGRect(x: (self.brush?.beginPoint.x)!, y: (self.brush?.beginPoint.y)!, width: KScreenWidth-30, height: 0))
            lable.numberOfLines = 0
            lable.font = textFont
            lable.isUserInteractionEnabled = true
            lable.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(clickContentLable(tap:))))
            lable.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(contentLablePan(pan:))))
            self.drawIputView.textView.text = ""
            self.drawIputView.textView.becomeFirstResponder()
            self.addSubview(lable)
            self.currentLable = lable
            self.lableArray.append(lable)
        } else {  // 说明是要编辑某一个label
            
        }
    }
    
    // 点击文本
    func clickContentLable(tap:UITapGestureRecognizer) {
        self.drawIputView.textView.text = self.currentLable.text
        self.drawIputView.textView.becomeFirstResponder()
    }
    // 移动文本
    func contentLablePan(pan:UIPanGestureRecognizer) {
        //得到拖的过程中的xy坐标
        let point : CGPoint = pan.translation(in: self.currentLable)
        self.currentLable.transform = self.currentLable.transform.translatedBy(x: point.x, y: point.y);
        pan.setTranslation(CGPoint(x:0,y:0), in: self.currentLable)
    }
    
    //MARK: - 返回画板上的图片，用于保存
    func takeImage() -> UIImage {
        
        // 保存之前先把文字和图片绘制到一起
        if self.lableArray.count > 0 {
            self.DrawTextAndImage()
        }
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        self.backgroundColor?.setFill()
        UIRectFill(self.bounds)
        
        if self.lableArray.count > 0 {
            self.textImageFlag?.draw(in: self.bounds)
        } else {
            self.image?.draw(in: self.bounds)
        }
        
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
    deinit {
        //移除通知
        NotificationCenter.default.removeObserver(self)
    }

}

//MARK: - 绘图的2个主要方法
extension DrawBoard {
    //MARK: - 将文本与图片融合
    fileprivate func DrawTextAndImage(){
        //开启图片上下文
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        //图形重绘
        self.draw(self.bounds)
        //水印文字属性
        let att = [NSForegroundColorAttributeName:self.strokeColor,NSFontAttributeName:self.textFont,NSBackgroundColorAttributeName:UIColor.clear] as [String : Any]
        for lable in self.lableArray {
            //水印文字大小
            let text = NSString(string: lable.text!)
            //绘制文字 ,文字显示的位置，要在textview的适当位置
            text.draw(in: lable.frame, withAttributes: att)
        }
        
        //从当前上下文获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        self.textImageFlag = image
    }
    
    // MARK: - drawing
    fileprivate func drawingImage() {
        if let brush = self.brush {
            
            // 1.开启一个新的ImageContext，为保存每次的绘图状态作准备。
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
            
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

}

//MARK: - 监听键盘的出现与消失，文本输入
extension DrawBoard {
    
    func setupIQBoard() {
        IQKeyboardManager.shared().toolbarDoneBarButtonItemText = "完成"
        self.drawIputView.textView.addDoneOnKeyboard(withTarget: self, action: #selector(clickDoneBtn))
    }
    /// 点击完成
    func clickDoneBtn() {
        self.drawIputView.textView.endEditing(true)
        
        self.currentLable.text = self.drawIputView.textView.text
        self.currentLable.cl_width = KScreenWidth-30
        self.currentLable.textColor = self.drawIputView.textView.textColor
        self.currentLable.sizeToFit()
    }

    func initEventHendle() {
        
        CLNotificationCenter.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        CLNotificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        weak var weakSelf = self
        self.drawIputView.textView.rx.text.subscribe(onNext: {(str : String?) in
            // 计算文本高度
            let textH = String.getTextSize(labelStr: str!, font: UIFont.systemFont(ofSize: 20),maxW:KScreenWidth,maxH: CGFloat(MAXFLOAT)).height
            if weakSelf?.kBoardH == 0 {
                weakSelf?.drawIputView.cl_y = KScreenHeight
            } else {
                weakSelf?.drawIputView.textView.cl_height = textH+20
                weakSelf?.drawIputView.cl_height = textH+20+0.5+40
                weakSelf?.drawIputView.cl_y = KScreenHeight-(weakSelf?.kBoardH)!-(weakSelf?.drawIputView.cl_height)!
            }
        }).addDisposableTo(disposBag)
    }
    
    //键盘的出现
    func keyBoardWillShow(_ notification: Notification){
        //获取userInfo
        let kbInfo = notification.userInfo
        //获取键盘的size
        let kbRect = (kbInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        kBoardH = kbRect.size.height
        //键盘弹出的时间
        let duration = kbInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double

        //界面偏移动画
        UIView.animate(withDuration: duration) {
            self.drawIputView.cl_y = KScreenHeight-self.kBoardH-self.drawIputView.cl_height
        }
    }
    
    //键盘的隐藏
    func keyBoardWillHide(_ notification: Notification){
        self.kBoardH = 0
        let kbInfo = notification.userInfo
        let duration = kbInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) {
            self.drawIputView.cl_y = KScreenHeight
        }
    }
}
