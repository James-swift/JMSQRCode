//
//  ViewController.swift
//  JMSQRCode
//
//  Created by James on 2017/3/12.
//  Copyright © 2017年 James. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        generateQRCode()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private
    func generateQRCode() {
        let size         = CGSize.init(width: 120, height: 120)
        let off: CGFloat = 30
        let string       = "https://github.com/xiaobs/JMQRCode.git"
        let logoName     = "logo"
        let logoSize     = CGSize.init(width: 30, height: 30)
        
        let tempX        = (self.view.bounds.size.width - size.width * 2 - off) / 2
        for i in 0...3 {
            var originX          = tempX
            var originY: CGFloat = 80
            var image: UIImage?
            
            switch i {
            case 0:
                image = JMSGenerateQRCodeUtils.jms_generateQRCode(string: string, imageSize: size)
            case 1:
                image = JMSGenerateQRCodeUtils.jms_generateQRCode(string: string, imageSize: size, logoImageName: logoName, logoImageSize: logoSize)
                originX += size.width + off;
            case 2:
                image = JMSGenerateQRCodeUtils.jms_generateColorQRCode(string: string, imageSize: size, rgbColor: CIColor.init(red: 200.0/255.0, green: 70.0/255.0, blue: 189.0/255.0))
                originY += size.height + off;
            case 3:
                image = JMSGenerateQRCodeUtils.jms_generateColorQRCode(string: string, imageSize: size, rgbColor: CIColor.init(red: 200.0/255.0, green: 70.0/255.0, blue: 189.0/255.0), logoImageName: logoName, logoImageSize: logoSize)
                originX += size.width + off;
                originY += size.height + off;
            default:
                break
            }
            
            let imageView = UIImageView.init(frame: .init(x: originX, y: originY, width: size.width, height: size.height))
            imageView.image = image
            self.view.addSubview(imageView)
        }
    }

}

