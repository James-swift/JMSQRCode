//
//  JMSScanningQRCodeUtils.swift
//  JMSQRCodeDemo
//
//  Created by James on 2017/3/13.
//  Copyright © 2017年 James. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

struct JMSScanningQRCodeUtils {
    
    /**
     获取图片包含的二维码信息
     
     - parameter image:     图片对象
     
     - returns: UIImage
     */
    static func jm_scanQRCodeFromPhotosAlbum(_ image: UIImage) -> String {
        var resultString = ""
        
        guard let ciimage = CIImage.init(image: image) else {
            return resultString
        }
        
        let detector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
        
        guard let features = detector?.features(in: ciimage) else {
            return resultString
        }
        
        guard let feature = features[0] as? CIQRCodeFeature else {
            return resultString
        }
        
        resultString = feature.messageString ?? ""
        
        return resultString
    }
    
    /**
     检查相机授权状态
     
     - parameter success:     授权成功
     - parameter failure:     授权失败

     - returns: Void
     */
    static func jm_cameraAuthStatus(success: (()->())?, failure: (()->())?) {
        if let _ = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) {
            let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            
            switch status {
            case .notDetermined:
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                    if granted {
                        DispatchQueue.main.async {
                            /// 第一次询问用户允许当前应用访问相机
                            success?()
                        }
                    }else {
                        /// 第一次询问用户不允许当前应用访问相机
                        failure?()
                    }
                })
            case .authorized:
                /// 用户允许当前应用访问相机
                success?()
            case .denied, .restricted:
                /// 用户不允许当前应用访问相机
                failure?()
            }
        }else {
            let alertVC = UIAlertController.init(title: "提示", message: "未检测到您的摄像头, 请在真机上测试", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction.init(title: "确定", style: .destructive, handler: { (action) in
                
            }))
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alertVC, animated: true, completion: nil)
        }
    }
    
    /**
     检查相册授权状态
     
     - parameter success:     授权成功
     - parameter failure:     授权失败
     
     - returns: Void
     */
    static func jm_albumAuthStatus(success: (()->())?, failure: (()->())?) {
        if let _ = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) {
            let status = PHPhotoLibrary.authorizationStatus()
            
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == .authorized  {
                        DispatchQueue.main.async {
                            /// 第一次询问用户允许当前应用访问相册
                            success?()
                        }
                    }else {
                        /// 第一次询问用户不允许当前应用访问相册
                        failure?()
                    }
                })
            case .authorized:
                /// 用户允许当前应用访问相册
                success?()
            case .denied, .restricted:
                /// 用户不允许当前应用访问相册
                failure?()
            }
        }else {
            failure?()
        }
        
    }

    
}
