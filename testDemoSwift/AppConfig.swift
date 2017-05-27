//
//  AppConfig.swift
//  CloudscmSwift
//
//  Created by RexYoung on 2017/2/21.
//  Copyright © 2017年 RexYoung. All rights reserved.
//

import UIKit

/**
 定义一些全局需要用的到常量, 类似于OC中的宏, 最好定义为常量
 *
 */

// 屏幕宽度
let KScreenHeight = UIScreen.main.bounds.height
// 屏幕高度
let KScreenWidth = UIScreen.main.bounds.width
//屏幕比例
let kScale = UIScreen.main.scale
//导航栏高度
let KNavgationBarHeight: CGFloat = 44.0
//tabbar高度
let KTabBarHeight: CGFloat = 49.0
//图片处理宽度自适应链接
let kOSS = "?x-oss-process=image/resize,w_"


//MARK: - RGBA颜色
var RGBAColor: (CGFloat, CGFloat, CGFloat, CGFloat) -> UIColor = {red, green, blue, alpha in
    return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha);
}

var mainColor: UIColor {
    return RGBAColor(212.0,35.0,122.0,1.0)
}


// MARK:- 设置圆角
func HDViewsBorder(_ view:UIView, borderWidth:CGFloat, borderColor:UIColor,cornerRadius:CGFloat){
    view.layer.borderWidth = borderWidth;
    view.layer.borderColor = borderColor.cgColor
    view.layer.cornerRadius = cornerRadius
    view.layer.masksToBounds = true
}


//阿里云图片上传oss
let kAccessKeyId = "QNHu4EkolmrtW1VA"
let kAccessKeySecret = "PsLrW91LiMM1fKoVCer6EIbPBVuT02"
let kBucketName = "scmapp"

//定义支付渠道
let KJZF = "DFTXYYH"       //快捷支付
let WXZF = "DFTWEPAYAPP"   //微信支付
let HDFK = "HDFK"          //货到付款
let NOFK = "NOTREQUIRED"   //不需要付款
let YEZF = "YEZF"          //余额支付


var dposUrl = "https://auth-test.1000sails.com/dpos-auth-web/s"
var dposSessionUrl = "https://s01c-test.1000sails.com/dpos-web/s"
//baseUrl
//54环境
//var baseURL = "http://172.18.1.54:1005/cvt-store/rest"
//45环境
//var baseURL = "http://172.18.1.45:8080/cloudscm-cvt-store-server/rest"
//云测试环境
//孙一
//var baseURL = "http://172.18.1.52:9980/cloudscm-cvt-store-server/rest"
//正式环境地址
//var baseURL = "http://scmopt.qianfan123.com/cloudscm-cvt-store-server/rest"

var baseURL = "http://scmopt-test.qianfan123.com/cloudscm-cvt-store-server/rest"

//运营商 - id
var rent_id = "-"


