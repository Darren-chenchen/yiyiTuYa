//
//  CLWebProgressView.swift
//  CLWebProgressView
//
//  Created by darren on 16/10/20.
//  Copyright © 2016年 darren. All rights reserved.
//

import UIKit

class CLWebProgressView: UIView {
    fileprivate lazy var progressView:UIProgressView = {
        let progressView = UIProgressView.init(progressViewStyle: UIProgressViewStyle.default)
        progressView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: 2)
        progressView.progressTintColor = UIColor.green
        progressView.trackTintColor = UIColor.clear
        return progressView
    }()
    
    @available(iOS 10.0, *)
    fileprivate lazy var timer:Timer = {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer:Timer) in
            self.progressView.progress = self.progressView.progress+0.1
            
            if self.progressView.progress>0.8 {
                self.progressView.progress=0.8
            }
        })
        return timer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.progressView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CLWebProgressView{
    // 开启定时器
    func starTimer(){
        if #available(iOS 10.0, *) {
            self.timer.fire()
        } else {
            // Fallback on earlier versions
        }
    }
    // 开启定时器
    func stopTimer(){
        if #available(iOS 10.0, *) {
            self.timer.invalidate()
        } else {
            // Fallback on earlier versions
        }
        
        self.progressView.progress = 1
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.progressView.isHidden = true
        }
        
    }
}

