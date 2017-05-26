//
//  CLCoustomButton.swift
//  haihang_swift
//
//  Created by darren on 16/8/16.
//  Copyright © 2016年 shanku. All rights reserved.
//

import UIKit

class CLCoustomButton: UIButton {
    
    var imageF = CGRect()
    var titleF = CGRect()

    func initTitleFrameAndImageFrame(_ buttomFrame:CGRect, imageFrame:CGRect, titleFrame:CGRect) {
        imageF = imageFrame
        self.frame = buttomFrame
        titleF = titleFrame
        
        self.titleLabel!.textAlignment = NSTextAlignment.center
        self.titleLabel!.font = UIFont.systemFont(ofSize: 15)
        self.setTitleColor(UIColor.black, for: UIControlState())
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return imageF
    }
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return titleF
    }
}
