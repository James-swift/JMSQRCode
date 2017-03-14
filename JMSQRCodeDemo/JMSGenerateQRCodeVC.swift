//
//  JMSGenerateQRCodeVC.swift
//  JMSQRCodeDemo
//
//  Created by James.xiao on 2017/3/14.
//  Copyright © 2017年 James. All rights reserved.
//

import UIKit

class JMSGenerateQRCodeVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "二维码"

        generateQRCode()
    }
    
    func generateQRCode() {
        let size            = CGSize.init(width: 120, height: 120)
        let off: CGFloat    = 30.0
        let string          = "https://github.com/James-swift/JMSQRCode.git"
        let logoName        = "logo"
        let logoSize        = CGSize.init(width: 30, height: 30)
        
        let tempX           = (self.view.bounds.size.width - size.width * 2 - off) / 2
        for i in 0...3 {
            var originX: CGFloat  = tempX
            var originY: CGFloat  = 80
            var image: UIImage?
            
            switch i {
            case 0:
                image = JMSGenerateQRCodeUtils.jms_generateQRCode(string: string, imageSize: size)
            case 1:
                image = JMSGenerateQRCodeUtils.jms_generateQRCode(string: string, imageSize: size, logoImageName: logoName, logoImageSize: logoSize)
                originX += size.width + off
            case 2:
                image = JMSGenerateQRCodeUtils.jms_generateColorQRCode(string: string, imageSize: size, rgbColor: CIColor.init(red: 200.0/255.0, green: 70.0/255.0, blue: 189.0/255.0), bgColor: CIColor.init(red: 0, green: 0, blue: 0))
                originY += size.height + off
            case 3:
                image = JMSGenerateQRCodeUtils.jms_generateColorQRCode(string: string, imageSize: size, rgbColor: CIColor.init(red: 200.0/255.0, green: 70.0/255.0, blue: 189.0/255.0), logoImageName: logoName, logoImageSize: logoSize)
                originX += size.width + off
                originY += size.height + off
            default:
                break
            }
            
            let imageView = UIImageView.init(frame: CGRect.init(x: originX, y: originY, width: size.width, height: size.height))
            imageView.image = image
            view.addSubview(imageView)
        }
    }
    
}
