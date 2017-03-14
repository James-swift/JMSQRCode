//
//  JMSScanningResultVC.swift
//  JMSQRCodeDemo
//
//  Created by James.xiao on 2017/3/14.
//  Copyright © 2017年 James. All rights reserved.
//

import UIKit
import WebKit

enum JMSScanningResultType {
    case qrCode, barCode
}

class JMSScanningResultVC : UIViewController {
    
    var resultType: JMSScanningResultType = .qrCode
    var resultInfo: String                = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = .white
        
        switch resultType {
        case .qrCode:
            setupWebView()
        default:
            setupLabel()
        }
    }
    
    func setupLabel() {
        let titleLabel = UILabel()
        titleLabel.frame = CGRect.init(x: 0, y: 200, width: self.view.frame.size.width, height: 30)
        titleLabel.text          = "您扫描的条形码结果如下： "
        titleLabel.textColor     = .red
        titleLabel.textAlignment = .center
    
        view.addSubview(titleLabel)
    
        // 扫描结果
        let contentLabel            = UILabel()
        contentLabel.frame          = CGRect.init(x: 0, y: titleLabel.frame.maxY, width: self.view.frame.size.width, height: 30)
        contentLabel.text           = self.resultInfo
        contentLabel.textAlignment  = .center
    
        view.addSubview(contentLabel)
    }
    
    func setupWebView() {
        guard let url = URL.init(string: resultInfo) else {
            return
        }
        let webView = WKWebView.init(frame: self.view.bounds)
        webView.load(URLRequest.init(url: url))
        
        view.addSubview(webView)
    }
    
}
