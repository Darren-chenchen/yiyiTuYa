//
//  InputView.swift
//  paso-ios
//
//  Created by darren on 2017/6/20.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class BoardInputView: UIView {
    
    var currentImage: UIImageView?

    
    // 定义一些重要的参数
    // 底部颜色选择的高度
    let bottomViewH: CGFloat = 40
    // 字体的大小
    let textF: CGFloat = 20
    // textView的初始化高度 间距+20字体高+间距
    let textViewInitH: CGFloat = 10+24+10
    
    let disposBag = DisposeBag()
    
    lazy var textView: UITextView = {
        let textView = UITextView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: self.textViewInitH))
        textView.backgroundColor = UIColor.white
        textView.textColor = UIColor.black
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: self.textF)
        return textView
    }()
    lazy var lineView: UIView = {
        let line = UIView.init(frame: CGRect(x: 0, y: self.textViewInitH, width: KScreenWidth, height: 0.5))
        line.backgroundColor = UIColor.white
        return line
    }()
    
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.frame = CGRect(x: 0, y: self.textViewInitH, width: self.frame.size.width, height: self.bottomViewH)
        scroll.showsHorizontalScrollIndicator = false
        scroll.backgroundColor = UIColor.clear
        return scroll
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0, alpha: 0.9)
        textView.inputView = nil
        textView.inputAccessoryView = nil
        // 文本框
        self.addSubview(textView)
        
        // 线
        self.addSubview(lineView)
        
        // 颜色选择
        self.addSubview(scrollView)
        
        let imageArr = ["clr_red","clr_orange","clr_blue","clr_green","clr_purple","clr_black"]
        
        let imgW: CGFloat = 20
        let imgH: CGFloat = 20
        let imgY: CGFloat = 0.5*(scrollView.cl_height-imgH)
        let magin: CGFloat = (KScreenWidth-CGFloat(imageArr.count)*imgW)/CGFloat(imageArr.count+1)
        for i in 0..<imageArr.count {
            let imgX: CGFloat = magin + (magin+imgW)*CGFloat(i)
            let img = UIImageView.init(frame: CGRect(x: imgX, y: imgY, width: imgW, height: imgH))
            img.image = UIImage(named: imageArr[i])
            img.isUserInteractionEnabled = true
            HDViewsBorder(img, borderWidth: 1.5, borderColor: UIColor.white, cornerRadius: 3)
            scrollView.addSubview(img)
            
            img.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(BoardInputView.clickPencilImageView(tap:))))
            
            // 默认选中红色
            if i == 0 {
                self.currentImage = img
                self.currentImage?.alpha = 0.5
                HDViewsBorder(self.currentImage!, borderWidth: 0, borderColor: UIColor.white, cornerRadius: 3)
                self.textView.textColor = UIColor.red
            }

        }
        
        scrollView.contentSize = CGSize(width: magin*CGFloat(imageArr.count+1)+imgW*CGFloat(imageArr.count)-KScreenWidth, height: 0)
        
        initEventHendle()
    }
    
    func clickPencilImageView(tap:UITapGestureRecognizer) {
        self.currentImage?.alpha = 1
        HDViewsBorder(self.currentImage!, borderWidth: 1.5, borderColor: UIColor.white, cornerRadius: 3)
        
        let imageView = tap.view as! UIImageView
        imageView.alpha = 0.5
        HDViewsBorder(imageView, borderWidth: 0, borderColor: UIColor.white, cornerRadius: 3)
        
        self.currentImage = imageView
        
        self.textView.textColor = UIColor(patternImage: imageView.image!)
    }
    
    fileprivate func initEventHendle() {
        // 颜色
        self.scrollView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(self.bottomViewH)
        }
        // 线条
        self.lineView.snp.makeConstraints { (make) in
            make.right.left.equalTo(self)
            make.bottom.equalTo(scrollView.snp.top)
            make.height.equalTo(0.5)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
