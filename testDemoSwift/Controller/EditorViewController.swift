//
//  EditorViewController.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/22.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController {

    // 画笔
    @IBOutlet weak var pencilBtn: UIButton!
    // 橡皮擦
    @IBOutlet weak var eraserBtn: UIButton!
    // 设置view
    @IBOutlet weak var settingView: UIView!
    // 需要编辑的图片
    var editorImage: UIImage!
    
    var scrollView: UIScrollView!
    // 画板
    var drawBoardImageView: DrawBoard!

    // 涂鸦的背景样式
    @IBOutlet weak var pencilImage: UIImageView!
    // 控制画笔的粗细
    @IBOutlet weak var slideView: UISlider!
    // 撤回
    @IBOutlet weak var backBtn: UIButton!
    // 前进
    @IBOutlet weak var forwardBtn: UIButton!
    // 还原
    @IBOutlet weak var returnBtn: UIButton!
    
    var lastScaleFactor : CGFloat! = 1  //放大、缩小
    
    lazy var choosePencilView: PencilChooseView = {
        let chooseView = PencilChooseView.init(frame: CGRect(x: 0, y: KScreenHeight, width: KScreenWidth, height: 40))
        chooseView.clickPencilImage = {[weak self] (img:UIImage) in
            self?.drawBoardImageView.strokeColor = UIColor(patternImage: img)
            self?.pencilImage.image = img
            self?.choosePencilViewDismiss()
            
            // 先判断是不是文本，如果是文本，直接设置文本的颜色
            if self?.drawBoardImageView.brush?.classForKeyedArchiver == InputBrush.classForCoder() {
                return
            }
            
            // 如果是模糊图片就设置RectangleBrush
            if img == UIImage(named: "11") {
                self?.drawBoardImageView?.brush = RectangleBrush()
            } else {
                self?.drawBoardImageView?.brush = PencilBrush()
            }
            self?.pencilBtn.isSelected = true
            self?.eraserBtn.isSelected = false
        }
        return chooseView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    func initView() {
        pencilBtn.setTitleColor(UIColor.red, for: .selected)
        pencilBtn.setTitleColor(UIColor.black, for: .normal)
        eraserBtn.setTitleColor(UIColor.red, for: .selected)
        eraserBtn.setTitleColor(UIColor.black, for: .normal)

        backBtn.isEnabled = false
        forwardBtn.isEnabled = false

        slideView.setThumbImage(UIImage(named:"dian"), for: .normal)
        slideView.value = 0.3

        pencilImage.layer.cornerRadius = 4
        pencilImage.layer.masksToBounds = true
        pencilImage.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(EditorViewController.clickPencilImageView)))
        
        let btnDownLoad = UIBarButtonItem.init(image: UIImage(named:"downLoad"), style: .done, target: self, action: #selector(EditorViewController.clickLoadBtn))
        let btnShare = UIBarButtonItem.init(image: UIImage(named:"share"), style: .done, target: self, action: #selector(EditorViewController.clickShareBtn))
        let btnEditor = UIBarButtonItem.init(image: UIImage(named:"editor"), style: .done, target: self, action: #selector(EditorViewController.clickEditorBtn))
        self.navigationItem.rightBarButtonItems = [btnDownLoad,btnShare,btnEditor]
        
        scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: 64, width: KScreenWidth, height: KScreenHeight-50-40-64)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 10
        self.view.addSubview(scrollView!)
        
        drawBoardImageView = DrawBoard.init(frame:scrollView.bounds)
        drawBoardImageView.isUserInteractionEnabled = true
        // 对长图压缩处理
        let scaleImage = UIImage.scaleImage(image: self.editorImage)
        drawBoardImageView.backgroundColor = UIColor(patternImage: scaleImage)
        scrollView?.addSubview(drawBoardImageView)
        drawBoardImageView.beginDraw = {[weak self]() in
            self?.backBtn.isEnabled = true
        }
        drawBoardImageView.unableDraw = {[weak self]() in
            self?.backBtn.isEnabled = false
        }
        drawBoardImageView.reableDraw = {[weak self]() in
            self?.forwardBtn.isEnabled = false
        }
        
        // 默认的画笔
        self.drawBoardImageView.strokeColor = UIColor(patternImage: UIImage(named: "6")!)
        self.pencilImage.image = UIImage(named: "6")!
    }
    //MARK: - 编辑,文本输入
    func clickEditorBtn() {
        self.scrollView.isScrollEnabled = false
        self.pencilBtn.isSelected = false
        self.eraserBtn.isSelected = false
        self.drawBoardImageView.brush = InputBrush()
    }
    
    //MARK: - 分享
    func clickShareBtn() {
        let win = UIApplication.shared.keyWindow
        let shareView = CLShareView()
        shareView.shareTitle = ""
        shareView.shareUrlStr = ""
        shareView.shareContent = ""
        shareView.shareImage = self.drawBoardImageView.takeImage()
        win?.addSubview(shareView)
    }
    
    //MARK: - 选择画笔颜色
    func clickPencilImageView(){
        self.view.addSubview(self.choosePencilView)
        self.view.bringSubview(toFront: self.settingView)
        self.choosePencilView.cl_y = self.settingView.cl_y
        UIView.animate(withDuration: 0.3) { 
            self.choosePencilView.cl_y = self.settingView.cl_y-40
        }
    }
    //MARK: - 选择画笔结束
    func choosePencilViewDismiss() {
        UIView.animate(withDuration: 0.3, animations: { 
            self.choosePencilView.cl_y = self.settingView.cl_y
        }) { (true) in
            self.choosePencilView.removeFromSuperview()
        }
    }
    
    //MARK: - 下载图片
    func clickLoadBtn(){
        let alertController = UIAlertController(title: "提示", message: "您确定要保存整个图片到相册吗？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: {
            action in

            UIImageWriteToSavedPhotosAlbum(self.drawBoardImageView.takeImage(), self, #selector(EditorViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    // 保存图片的结果
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if let err = error {
            UIAlertView(title: "错误", message: err.localizedDescription, delegate: nil, cancelButtonTitle: "确定").show()
        } else {
            UIAlertView(title: "提示", message: "保存成功", delegate: nil, cancelButtonTitle: "确定").show()
        }
    }

    //MARK: - 改变画笔大小
    @IBAction func clickSlide(_ sender: Any) {
        // 先判断是不是文本，如果是文本，直接设置文本的颜色
        if self.drawBoardImageView.brush?.classForKeyedArchiver == InputBrush.classForCoder() {
            drawBoardImageView.textFont = UIFont.systemFont(ofSize: CGFloat(self.slideView.value*50))
            return
        }
        drawBoardImageView.strokeWidth = CGFloat(self.slideView.value*15)
    }
    //MARK: - 点击了画笔
    @IBAction func clickPencilBtn(_ sender: Any) {
        
        self.pencilBtn?.isSelected = !(self.pencilBtn?.isSelected)!
        if (self.pencilBtn?.isSelected)! {
            self.scrollView.isScrollEnabled = false
            self.pencilBtn?.isSelected = true
            self.eraserBtn?.isSelected = false
            
            // 先判断是不是模糊矩形
            if self.pencilImage.image == UIImage(named: "11") {
                drawBoardImageView?.brush = RectangleBrush()
            } else {
                drawBoardImageView?.brush = PencilBrush()
            }
        } else {
            self.scrollView.isScrollEnabled = true
            self.pencilBtn?.isSelected = false
            drawBoardImageView?.brush = nil
        }
    }
    //MARK: - 点击了橡皮擦
    @IBAction func clickEraserBtn(_ sender: Any) {
        self.eraserBtn?.isSelected = !(self.eraserBtn?.isSelected)!
        if (self.eraserBtn?.isSelected)! {
            self.scrollView.isScrollEnabled = false
            self.pencilBtn?.isSelected = false
            self.eraserBtn?.isSelected = true
            drawBoardImageView?.brush = EraserBrush()
        } else {
            self.scrollView.isScrollEnabled = true
            self.pencilBtn?.isSelected = false
            drawBoardImageView?.brush = nil
        }
    }
    //MARK: - 撤回
    @IBAction func clickBackBtn(_ sender: Any) {
        if self.drawBoardImageView.canBack() {
            self.backBtn.isEnabled = true
            self.forwardBtn.isEnabled = true
            drawBoardImageView?.undo()
        } else {
            self.backBtn.isEnabled = false
        }
    }
    //MARK: - 向前
    @IBAction func clickForWardBtn(_ sender: Any) {
        if self.drawBoardImageView.canForward() {
            self.forwardBtn.isEnabled = true
            self.backBtn.isEnabled = true
            drawBoardImageView?.redo()
        } else {
            self.forwardBtn.isEnabled = false
        }
    }
    //MARK: - 还原
    @IBAction func ClickReturnBtn(_ sender: Any) {
        
        let alertController = UIAlertController(title: "提示",message: "您确定要还原图片吗？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "确定", style: .default, handler: {
            action in
            self.drawBoardImageView?.retureAction()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)

    }
}

extension EditorViewController:UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return drawBoardImageView
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        drawBoardImageView?.brush = nil
        self.pencilBtn?.isSelected = false
        self.eraserBtn?.isSelected = false
        self.scrollView.isScrollEnabled = true
    }
}
