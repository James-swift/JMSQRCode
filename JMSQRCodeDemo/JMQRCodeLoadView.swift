//
//  JMQRCodeLoadView.swift
//  JMSQRCodeDemo
//
//  Created by James on 2017/3/14.
//  Copyright © 2017年 James. All rights reserved.
//

import UIKit

private let kView_Size_W = 100
private let kView_Size_H = 40

class JMQRCodeLoadView : UIView {
    
    private(set) var indicatorView: UIActivityIndicatorView = {
        let tempView = UIActivityIndicatorView.init(activityIndicatorStyle: .white)
        
        return tempView
    }()
    
    private(set) var titleLabel: UILabel = {
        let tempLabel = UILabel.init(frame: CGRect.init(x: 0, y: 20, width: kView_Size_W, height: 20))
        tempLabel.textAlignment = .center
        tempLabel.textColor     = .white
        tempLabel.font          = UIFont.systemFont(ofSize: 15.0)
        tempLabel.text          = "正在加载..."
        
        return tempLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.backgroundColor = .clear
        
        indicatorView.center = CGPoint.init(x: self.center.x, y: self.center.y - indicatorView.frame.size.height - 5)
        indicatorView.startAnimating()
        self.addSubview(indicatorView)
        
        titleLabel.center = CGPoint.init(x: self.center.x, y: self.center.y + 5)
        self.addSubview(titleLabel)
    }
    
}
