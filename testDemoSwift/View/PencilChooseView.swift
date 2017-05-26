//
//  PencilChooseView.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/23.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

typealias clickPencilImageClouse = (UIImage) -> ()

class PencilChooseView: UIView {
    
    var scrollView: UIScrollView!
    
    var clickPencilImage: clickPencilImageClouse?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(white: 0, alpha: 0.1)
        
        scrollView = UIScrollView()
        scrollView?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView!)
        
        let imgW: CGFloat = 32
        let imgH: CGFloat = 32
        let imgY: CGFloat = 3
        let magin: CGFloat = 5
        for i in 0..<13 {
            let imgX: CGFloat = (magin+imgW)*CGFloat(i)
            let img = UIImageView.init(frame: CGRect(x: imgX, y: imgY, width: imgW, height: imgH))
            img.image = UIImage(named: "\(i)")
            img.isUserInteractionEnabled = true
            scrollView.addSubview(img)
            
            img.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(PencilChooseView.clickPencilImageView(tap:))))
        }
        
        scrollView.contentSize = CGSize(width: (magin+imgW)*13, height: 0)
    }
    
    func clickPencilImageView(tap:UITapGestureRecognizer) {
        if clickPencilImage != nil {
            let imageView = tap.view as! UIImageView
            self.clickPencilImage!(imageView.image!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
