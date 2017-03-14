//
//  JMSGenerateQRCodeUtils.swift
//  JMSQRCode
//
//  Created by James on 2017/3/12.
//  Copyright © 2017年 James. All rights reserved.
//

import Foundation
import UIKit

struct JMSGenerateQRCodeUtils {
    
    /**
     生成一张普通的或者带有logo的二维码
     
     - parameter string:    传入你要生成二维码的数据
     - parameter imageSize: 生成的二维码图片尺寸
     - parameter logoImageName: logo图片名称
     - parameter logoImageSize: logo图片尺寸（注意尺寸不要太大（最大不超过二维码图片的%30），太大会造成扫不出来）
     
     - returns: UIImage
     */
    static func jms_generateQRCode(string: String, imageSize: CGSize, logoImageName: String = "", logoImageSize: CGSize = .zero) -> UIImage? {
        guard let outputImage = self.outputNormalImage(string: string, imageSize: imageSize) else {
            return nil
        }
        
        guard let scaledImage = self.createNonInterpolatedImage(outputImage, imageSize) else {
            return nil
        }
        
        return self.createLogoImage(scaledImage, imageSize, logoImageSize: logoImageSize, logoImageName: logoImageName)
    }
    
    /**
     生成一张彩色的或者带有logo的二维码
     
     - parameter string:    传入你要生成二维码的数据
     - parameter imageSize: 生成的二维码图片尺寸
     - parameter rgbColor:  rgb颜色
     - parameter bgColor:   背景颜色
     - parameter logoImageName: logo图片名称
     - parameter logoImageSize: logo图片尺寸（注意尺寸不要太大（最大不超过二维码图片的%30），太大会造成扫不出来）
     
     - returns: UIImage
     */
    static func jms_generateColorQRCode(string: String, imageSize: CGSize, rgbColor: CIColor, bgColor: CIColor = CIColor.init(red: 1, green: 1, blue: 1), logoImageName: String = "", logoImageSize: CGSize = .zero) -> UIImage? {
        guard let outputImage = self.outputColorImage(string: string, imageSize: imageSize, rgbColor: rgbColor, backgroundColor: bgColor) else {
            return nil
        }
        
        return self.createLogoImage(UIImage.init(ciImage: outputImage), imageSize, logoImageSize: logoImageSize, logoImageName: logoImageName)
    }
    
    // MARK: - Private
    /**
     获得滤镜输出的图像
     
     - parameter string:    传入你要生成二维码的数据
     - parameter imageSize: 生成的二维码图片尺寸
     
     - returns: CIImage
     */
    private static func outputNormalImage(string: String, imageSize: CGSize) -> CIImage? {
        /// 1.设置数据
        let data = string.data(using: .utf8)
        
        /// 2.创建滤镜对象
        guard let filter = CIFilter.init(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        filter.setDefaults()
        filter.setValue(data, forKey: "inputMessage") // 通过kvo方式给一个字符串，生成二维码
        filter.setValue("H", forKey: "inputCorrectionLevel") // 设置二维码的纠错水平，越高纠错水平越高，可以污损的范围越大
        
        /// 3.获得滤镜输出对象(拿到二维码图片)
        guard let outputImage = filter.outputImage else {
            return nil
        }
        
        return outputImage
    }
    
    /**
     获得彩色滤镜输出的图像
     
     - parameter string:    传入你要生成二维码的数据
     - parameter imageSize: 生成的二维码图片尺寸
     
     - returns: CIImage
     */
    private static func outputColorImage(string: String, imageSize: CGSize, rgbColor: CIColor, backgroundColor: CIColor = CIColor.init(red: 1, green: 1, blue: 1)) -> CIImage? {
        guard let outputImage = self.outputNormalImage(string: string, imageSize: imageSize) else {
            return nil
        }
        
        /// 创建颜色滤镜
        let colorFilter = CIFilter.init(name: "CIFalseColor")
        colorFilter?.setDefaults()
        colorFilter?.setValue(outputImage, forKey: "inputImage")
        /// 替换颜色
        colorFilter?.setValue(rgbColor, forKey: "inputColor0")
        /// 替换背景颜色
        colorFilter?.setValue(backgroundColor, forKey: "inputColor1")
        
        return colorFilter?.outputImage
    }
    
    /**
     根据CIImage生成指定大小的UIImage
     
     - parameter image:    CIImage对象
     - parameter imageSize: 生成的二维码图片尺寸
     
     - returns: UIImage
     */
    private static func createNonInterpolatedImage(_ image: CIImage, _ imageSize: CGSize) -> UIImage? {
        /// 1.创建bitmap
        let context = CIContext(options: nil)
        let bitmapImage = context.createCGImage(image, from: image.extent)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapContext = CGContext(data: nil, width: Int(imageSize.width), height: Int(imageSize.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)
        
        let scale = min(imageSize.width / image.extent.width, imageSize.height / image.extent.height)
        bitmapContext!.interpolationQuality = CGInterpolationQuality.none
        bitmapContext?.scaleBy(x: scale, y: scale)
        bitmapContext?.draw(bitmapImage!, in: image.extent)
        
        /// 2.保存bitmap到图片
        guard let scaledImage = bitmapContext?.makeImage() else {
            return nil
        }
        
        /// 3.生成原图
        return UIImage.init(cgImage: scaledImage)
    }
    
    /**
     生成带有logo二维码图片
     
     - parameter image:         UIImage对象
     - parameter imageSize:     UIImage对象尺寸
     - parameter logoImageName: logo图片名称
     - parameter logoImageSize: logo图片尺寸（注意尺寸不要太大（最大不超过二维码图片的%30），太大会造成扫不出来）

     - returns: UIImage
     */
    private static func createLogoImage(_ image: UIImage, _ imageSize: CGSize, logoImageSize: CGSize = .zero, logoImageName: String = "") -> UIImage {
        if logoImageSize.equalTo(.zero) && logoImageName == "" {
            return image
        }
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
        image.draw(in: CGRect.init(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        
        let waterimage = UIImage.init(named: logoImageName)
        waterimage?.draw(in: CGRect.init(x: (imageSize.width - logoImageSize.width) / 2.0, y: (imageSize.height - logoImageSize.height) / 2.0, width: logoImageSize.width, height: logoImageSize.height))
        
        let newPic = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newPic!
    }
    
}
