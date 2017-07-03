//
//  AppDelegate.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/18.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        ShareSDK.registerApp("f109cb4e5028", activePlatforms: [SSDKPlatformType.typeSinaWeibo.rawValue,SSDKPlatformType.typeWechat.rawValue,SSDKPlatformType.typeQQ.rawValue,SSDKPlatformType.typeSMS.rawValue], onImport: { (platformType:SSDKPlatformType) in
            switch (platformType)
            {
            case .typeWechat:
                ShareSDKConnector.connectWeChat(WXApi.classForCoder())
                break
            case .typeQQ:
                ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
                break
                
            case .typeSinaWeibo:
                ShareSDKConnector.connectWeibo(WeiboSDK.classForCoder())
                break
            case .typeSMS:
                break
            default:
                break
            }
            
        }) { (platformType:SSDKPlatformType, appInfo:NSMutableDictionary?) in
            switch (platformType)
            {
            case .typeSinaWeibo:
                //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                appInfo?.ssdkSetupSinaWeibo(byAppKey: "1761000454", appSecret: "5ec7659fb98cefcc72c9092615ab4e2d", redirectUri: "http://sns.whalecloud.com/sina2/callback", authType: SSDKAuthTypeBoth)
                break
            case .typeWechat:
                appInfo?.ssdkSetupWeChat(byAppId: "wx5076ee2f2a49f3ea", appSecret: "1dc9b22d6c5a07b95cdf02da8e340ea9")
                break
            case .typeQQ:
                appInfo?.ssdkSetupQQ(byAppId: "1104976467", appKey: "Nlf38gsPZHZMwX1b", authType: SSDKAuthTypeBoth)
                break
            case .typeSMS:
                appInfo?.ssdkSetupSMSParams(byText: "开心一刻", title: "开心一刻", images: "", attachments: "开心一刻", recipients: ["开心一刻"], type: SSDKContentType.text)
                break
            default:
                break
            }
            
        }
        
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}



