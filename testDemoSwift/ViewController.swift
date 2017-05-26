//
//  ViewController.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/18.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    @IBOutlet weak var cutBtn: UIButton!
    @IBOutlet weak var editorBtn: UIButton!
        
    lazy var webView: UIWebView = {
        let web = UIWebView.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
        web.backgroundColor = UIColor.white
        return web
    }()
    
    fileprivate lazy var progressView:CLWebProgressView = {
        let progressView = CLWebProgressView.init(frame: CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: 2))
        return progressView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL.init(string: "https://darren-chenchen.github.io/testWeb/index.html")
        let req = URLRequest.init(url: url!)
        self.webView.scrollView.bounces = false
        self.webView.loadRequest(req)
        self.webView.delegate = self
        self.view.addSubview(self.webView)
        
        self.view.addSubview(self.progressView)
        
        self.editorBtn.isEnabled = false
        self.cutBtn.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func clickBtn(_ sender: Any) {
        
        let editorVC = EditorViewController(nibName: "EditorViewController", bundle: nil)
        editorVC.editorImage = self.screenShot()
        self.navigationController?.pushViewController(editorVC, animated: true)
    }
    
    // 截取webview所有的内容
    func screenShot() -> UIImage {
        var image = UIImage()
        UIGraphicsBeginImageContextWithOptions(self.webView.scrollView.contentSize, true, 0)
        //保存webView当前的偏移量
        let savedContentOffset = self.webView.scrollView.contentOffset
        let saveFrame = self.webView.scrollView.frame
        
        //将webView的偏移量设置为(0,0)
        self.webView.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        self.webView.frame = CGRect(x: 0, y: 0, width:
        self.webView.scrollView.contentSize.width, height: self.webView.scrollView.contentSize.height)
        
        //在当前上下文中渲染出webView
        self.webView.scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)

        //截取当前上下文生成Image
        image = UIGraphicsGetImageFromCurrentImageContext()!
        
        //恢复webview的偏移量
        self.webView.scrollView.contentOffset = savedContentOffset
        self.webView.frame = saveFrame
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    //MARK: - 截取屏幕图片
    func screenCut() -> UIImage {
        return UIImage.screenShotForPart(view: self.view, size: self.view.bounds.size)
    }
    
    //MARK: - 截取屏幕图片
    @IBAction func clickShotBtn(_ sender: Any) {
        let editorVC = EditorViewController()
        editorVC.editorImage = self.screenCut()
        self.navigationController?.pushViewController(editorVC, animated: true)
    }
    
}

extension ViewController:UIWebViewDelegate{
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        self.progressView.starTimer()
        return true
    }
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.progressView.stopTimer()
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.progressView.stopTimer()
        self.editorBtn.isEnabled = true
        self.cutBtn.isEnabled = true
    }
}


