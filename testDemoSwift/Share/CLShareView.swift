//
//  CLShareView.swift
//  relex_swift
//
//  Created by Darren on 16/10/23.
//  Copyright © 2016年 darren. All rights reserved.
//

import UIKit
import MessageUI

class CLShareView: UIView {
    
    var imgArr = [String]()
    var titleArr = [String]()
    
    // 分享内容
    var shareContent = ""
    // 分享url
    var shareUrlStr:String?
    // 分享标题
    var shareTitle = ""
    // 分享图片
    var shareImage: UIImage!
    
    var tipViews = UIView()


    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 创建一个阴影
        let win = UIApplication.shared.keyWindow!
        let cover = UIView(frame: UIScreen.main.bounds)
        cover.backgroundColor = UIColor.black
        cover.tag = 100
        cover.alpha = 0.8
        win.addSubview(cover)
        // 创建一个提示框
        let tipX: CGFloat = 0
        let tipW: CGFloat = cover.frame.size.width - 2 * tipX
        let tipH: CGFloat = 280
        let tipViews = UIView(frame: CGRect(x: tipX, y: KScreenHeight, width: tipW, height: tipW))
        tipViews.backgroundColor = UIColor(white: 1, alpha: 0.9)
        win.addSubview(tipViews)
        self.tipViews = tipViews
        UIView.animate(withDuration: 0.25, animations: { 
            let tipY: CGFloat = (KScreenHeight - tipH)
            tipViews.frame = CGRect(x: tipX, y: tipY, width: tipW, height: tipH)
            }) { (finished: Bool) in
                
        }
        
        let lable = UILabel(frame: CGRect(x: 0, y: 10, width: tipViews.frame.size.width, height: 30))
        lable.text = "分享到"
        lable.textAlignment = .center
        lable.font = UIFont.systemFont(ofSize: 15)
        tipViews.addSubview(lable)
        
        if (!WXApi.isWXAppInstalled() && QQApiInterface.isQQInstalled()) { // 没装微信 装qq
            self.imgArr = ["share_qq", "share_qzone", "share_sina_on"]
            self.titleArr = ["QQ好友", "QQ空间", "新浪微博"]
        } else if !WXApi.isWXAppInstalled() && !QQApiInterface.isQQInstalled() { //没装微信 没装q
            self.imgArr = ["share_sina_on"]
            self.titleArr = ["新浪微博"]
        } else if WXApi.isWXAppInstalled() && !QQApiInterface.isQQInstalled() { //装微信 没装qq
            self.imgArr = ["share_wechat_icon", "share_wechat_timeline_icon", "share_wechat_favorite_icon", "share_sina_on"]
            self.titleArr = ["微信好友", "微信朋友圈", "微信收藏", "新浪微博"]
        } else if WXApi.isWXAppInstalled() && QQApiInterface.isQQInstalled() { //装微信 装q
            self.imgArr = ["share_wechat_icon", "share_wechat_timeline_icon", "share_wechat_favorite_icon","share_qq", "share_qzone", "share_sina_on"]
            self.titleArr = ["微信好友", "微信朋友圈", "微信收藏","QQ好友", "QQ空间","新浪微博"]
        }
        for i in 0..<self.titleArr.count {
            let line = 3
            let btnW: CGFloat = tipViews.frame.size.width/CGFloat(line)
            let btnX: CGFloat = CGFloat(i%Int(line)) * btnW
            
            let btnImageW:CGFloat = btnW*0.4
            let btnImageH:CGFloat = btnImageW
            let btnImageX:CGFloat = (btnW-btnImageW)*0.5
            let btnImageY:CGFloat = 5
            
            let btnH = btnImageH+5+20+5;
            let btnY: CGFloat = CGFloat(i/line) * (btnH+5)

            let btnShare = CLCoustomButton()
            btnShare.initTitleFrameAndImageFrame(CGRect(x: btnX, y: 50+btnY, width: btnW, height: btnH), imageFrame: CGRect(x: btnImageX, y: btnImageY, width: btnImageW,height: btnImageH), titleFrame: CGRect(x: 0, y: btnImageH+5+5, width: btnW, height: 15))
            btnShare.tag = i + 100
            btnShare.imageView!.contentMode = .scaleAspectFit
            btnShare.setTitle(self.titleArr[i], for: .normal)
            btnShare.setImage(UIImage(named: self.imgArr[i])!, for: .normal)
            btnShare.addTarget(self, action: #selector(self.clickBtn), for: .touchUpInside)
            tipViews.addSubview(btnShare)
        }

        let cancelBtn = UIButton(frame: CGRect(x: (tipViews.frame.size.width - 80) * 0.5, y: tipViews.frame.size.height - 45, width: 80, height: 30))
        cancelBtn.backgroundColor = UIColor.purple
        cancelBtn.setTitle("取消分享", for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cancelBtn.layer.cornerRadius = 3
        cancelBtn.layer.masksToBounds = true
        cancelBtn.addTarget(self, action: #selector(self.clickCancel), for: .touchUpInside)
        tipViews.addSubview(cancelBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clickCancel() {
        UIView.animate(withDuration: 0.25, animations: {
            let tipY: CGFloat = KScreenHeight
            self.tipViews.frame = CGRect(x: 0, y: tipY, width: KScreenWidth, height: 0)
        }) { (finished: Bool) in
            let win = UIApplication.shared.keyWindow!
            win.subviews.last!.removeFromSuperview()
            let win2 = UIApplication.shared.keyWindow!
            win2.subviews.last!.removeFromSuperview()
            let win3 = UIApplication.shared.keyWindow!
            win3.subviews.last!.removeFromSuperview()
        }
    }
    
    func clickBtn(_ btn: UIButton) {
        self.initWithBtn(btn)
    }
    func initWithBtn(_ btn: UIButton) {
        //创建分享参数
        let shareParams = NSMutableDictionary()
        shareParams.ssdkEnableUseClientShare()
        guard let urlStr = self.shareUrlStr else {
            return
        }
        

        shareParams.ssdkSetupShareParams(byText: self.shareContent, images: self.shareImage, url: NSURL(string:urlStr) as URL!, title: self.shareTitle, type: SSDKContentType.image)
        if (btn.titleLabel!.text! == "QQ好友") {
            //QQ
            ShareSDK.share(.typeQQ, parameters: shareParams, onStateChanged: { (state:SSDKResponseState, userData:[AnyHashable : Any]?, contentEntity:SSDKContentEntity?, error:Error?) in
                if state == SSDKResponseState.success {
//                    SVProgressHUD.showSuccess(withStatus: "分享成功")
                }
            })
        }
        
        if (btn.titleLabel!.text! == "QQ空间") {
            //QQ
            ShareSDK.share(.subTypeQZone, parameters: shareParams, onStateChanged: { (state:SSDKResponseState, userData:[AnyHashable : Any]?, contentEntity:SSDKContentEntity?, error:Error?) in
                if state == SSDKResponseState.success {
//                    SVProgressHUD.showSuccess(withStatus: "分享成功")
                }
            })
        }

        if (btn.titleLabel!.text! == "微信好友") {
            //QQ
            ShareSDK.share(.typeWechat, parameters: shareParams, onStateChanged: { (state:SSDKResponseState, userData:[AnyHashable : Any]?, contentEntity:SSDKContentEntity?, error:Error?) in
                if state == SSDKResponseState.success {
//                    SVProgressHUD.showSuccess(withStatus: "分享成功")
                }
            })
        }

        
        if (btn.titleLabel!.text! == "微信朋友圈") {
            //QQ
            ShareSDK.share(.subTypeWechatTimeline, parameters: shareParams, onStateChanged: { (state:SSDKResponseState, userData:[AnyHashable : Any]?, contentEntity:SSDKContentEntity?, error:Error?) in
                if state == SSDKResponseState.success {
//                    SVProgressHUD.showSuccess(withStatus: "分享成功")
                }
            })
        }

        
        if (btn.titleLabel!.text! == "微信收藏") {
            //QQ
            ShareSDK.share(.subTypeWechatFav, parameters: shareParams, onStateChanged: { (state:SSDKResponseState, userData:[AnyHashable : Any]?, contentEntity:SSDKContentEntity?, error:Error?) in
                if state == SSDKResponseState.success {
//                    SVProgressHUD.showSuccess(withStatus: "收藏成功")
                }
            })
        }

        if (btn.titleLabel!.text! == "新浪微博") {
            //QQ
            ShareSDK.share(.typeSinaWeibo, parameters: shareParams, onStateChanged: { (state:SSDKResponseState, userData:[AnyHashable : Any]?, contentEntity:SSDKContentEntity?, error:Error?) in
                if state == SSDKResponseState.success {
//                    SVProgressHUD.showSuccess(withStatus: "分享成功")
                }
            })
        }
        self.clickCancel()
    }
}
