//
//  JMSScanningQRCodeView.swift
//  JMSQRCodeDemo
//
//  Created by James on 2017/3/13.
//  Copyright © 2017年 James. All rights reserved.
//

import UIKit
import AVFoundation

private let jm_qr_cornerLineOffX: CGFloat = 0.7
private let jm_qr_cornerLineOffY: CGFloat = 0.7
private let jm_qr_scanLineOffY: CGFloat   = 2.0

public class JMSScanningQRCodeView : UIView, AVCaptureMetadataOutputObjectsDelegate {
    
    /// 透明区域
    var transparentArea: CGSize = .zero {
        didSet {
            scaMaxBorder = transparentOriginY + (transparentArea.height - jm_qr_scanLineOffY * 2);
        }
    }
    
    /// 透明的区域起始位置
    var transparentOriginY: CGFloat    = 0
    
    /// 扫描动画线条相关
    private(set) var qrLineImageView: UIImageView?
    private var qrLineY: CGFloat       = 0
    var qrLineColor: UIColor           = .clear
    var qrLineAnimateDuration          = 0.006
    var qrLineImageName                = ""
    var qrLineColorRed: CGFloat        = (9 / 255.0)
    var qrLineColorGreen: CGFloat      = (187 / 255.0)
    var qrLineColorBlue: CGFloat       = (7 / 255.0)
    var qrLineColorAlpha: CGFloat      = 1.0
    var qrLineSize: CGSize             = .zero {
        didSet {
            if qrLineImageView != nil {
                var frame = qrLineImageView!.frame
                frame.size.height = qrLineSize.height
                frame.origin.x = (self.frame.width - qrLineSize.width) / 2
                
                qrLineImageView?.frame = frame
            }
        }
    }

    /// 边角线条长度，默认15
    var cornerLineLength: CGFloat      = 15
    
    /// 扫描区域最大边界
    private var scaMaxBorder: CGFloat  = 0

    /// 是否扫描结束
    private var isScanResult           = false
    
    /// 配置
    private(set) var qrConfig: JMScanningQRCodeConfig?
    
    /// 计时器
    private var timer: Timer?
    
    /// 扫描结果
    var scanningQRCodeResult: ((_ result: String)->())?
    
    /// 打开照明
    var openSystemLight: Bool = false {
        didSet {
            if qrConfig?.device != nil  && (qrConfig?.device?.hasTorch)! {
                try! qrConfig?.device?.lockForConfiguration()
                
                if (openSystemLight) {
                    qrConfig?.device?.torchMode = .on
                } else {
                    qrConfig?.device?.torchMode = .off
                }
                
                qrConfig?.device?.unlockForConfiguration()
            }
        }
    }
    
    init() {
        super.init(frame: (UIApplication.shared.keyWindow?.bounds)!)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        let width               = self.bounds.size.width - self.bounds.size.width * 2 * 0.15
        transparentArea         = .init(width: width, height: width)
        transparentOriginY      = self.bounds.size.height / 2 - transparentArea.height / 2
        qrLineSize              = CGSize.init(width: width - 20, height: 2)
        scaMaxBorder            = transparentOriginY + (transparentArea.height - jm_qr_scanLineOffY * 2)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if qrLineImageView == nil {
            initQRLine()
        }
    }
    
    // MARK: - init
    private func initQRLine() {
        qrLineImageView  = UIImageView.init(frame: .init(x: self.bounds.size.width / 2 - qrLineSize.width / 2, y: transparentOriginY + jm_qr_scanLineOffY, width: qrLineSize.width, height: qrLineSize.height))
        qrLineImageView!.backgroundColor = qrLineColor
        qrLineImageView!.image           = UIImage.init(named: qrLineImageName)
        
        addSubview(qrLineImageView!)
        
        qrLineY = qrLineImageView!.frame.origin.y
    }
    
    public override func draw(_ rect: CGRect) {
        if transparentArea.equalTo(.zero) {
            return
        }
        
        let clearDrawRect = CGRect.init(x: self.bounds.size.width / 2 - self.transparentArea.width / 2, y: transparentOriginY, width: transparentArea.width, height: transparentArea.height)
        let contextRef = UIGraphicsGetCurrentContext()!
        
        addScreenFill(context: contextRef, rect: self.bounds)
        addCenterClear(context: contextRef, rect: clearDrawRect)
        addWhite(context: contextRef, rect: clearDrawRect)
        addCornerLine(context: contextRef, rect: clearDrawRect)
    }
    
    // MARK: - Public
    public func qrCornerLineColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        qrLineColorRed   = red;
        qrLineColorGreen = green;
        qrLineColorBlue  = blue;
        qrLineColorAlpha = alpha;
        
        setNeedsDisplay()
    }
    
    public func startRunning(config: JMScanningQRCodeConfig? = nil) {
        if qrConfig == nil {
            if config == nil {
                /// 默认
                qrConfig = JMScanningQRCodeConfig.init(qrCodeView: self, delegate: self)
            }else {
                qrConfig = config
            }
        }
        
        qrLineImageView?.isHidden = false
        isScanResult              = false
        
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: qrLineAnimateDuration, target: self, selector: #selector(animateQRLine), userInfo: nil, repeats: true)
            
            timer?.fire()
        }
        
        qrConfig?.session?.startRunning()
    }
    
    public func stopRunning() {
        qrLineImageView?.isHidden = true
        
        var frame               = qrLineImageView?.frame
        frame?.origin.y         = transparentOriginY + jm_qr_scanLineOffY
        qrLineImageView?.frame  = frame!
        
        timer?.invalidate()
        timer = nil
        
        qrConfig?.session?.stopRunning()
    }
    
    // MARK: - Private
    func animateQRLine() {
        UIView.animate(withDuration: qrLineAnimateDuration, animations: { 
            var rect                    = self.qrLineImageView?.frame
            rect?.origin.y              = self.qrLineY
            self.qrLineImageView?.frame = rect!
        }) { (finished) in
            if self.qrLineY > self.scaMaxBorder {
                self.qrLineY = self.transparentOriginY + jm_qr_scanLineOffY
            }
            
            self.qrLineY += 1
        }
    }
    
    private func handleScanResult(_ result: String) {
        if isScanResult {
            return
        }
        
        if result != "" {
            isScanResult = true

            // 处理扫描结果
            stopRunning()
            
            scanningQRCodeResult?(result)
        }else {
            isScanResult = false
        }
    }
    
    // MARK: - Draw
    private func addScreenFill(context: CGContext, rect: CGRect) {
        context.setFillColor(red: 40 / 255.0, green: 40 / 255.0, blue: 40 / 255.0, alpha: 0.5)
        context.fill(rect)
    }
    
    private func addCenterClear(context: CGContext, rect: CGRect) {
        context.clear(rect)
    }
    
    private func addWhite(context: CGContext, rect: CGRect) {
        context.stroke(rect)
        context.setStrokeColor(red: 1, green: 1, blue: 1, alpha: 1)
        context.setLineWidth(0.8)
        context.addRect(rect)
        context.strokePath()
    }

    private func addCornerLine(context: CGContext, rect: CGRect){
        context.setLineWidth(2)
        context.setStrokeColor(red: qrLineColorRed, green: qrLineColorGreen, blue: qrLineColorBlue, alpha: qrLineColorAlpha)
        
        /// 左上角
        let poinsTopLeftA = [CGPoint.init(x: rect.origin.x + jm_qr_cornerLineOffX, y: rect.origin.y + jm_qr_cornerLineOffY), CGPoint.init(x: rect.origin.x + jm_qr_cornerLineOffX, y: rect.origin.y + jm_qr_cornerLineOffY + cornerLineLength)]
        
         let poinsTopLeftB = [CGPoint.init(x: rect.origin.x + jm_qr_cornerLineOffX - 1, y: rect.origin.y + jm_qr_cornerLineOffY), CGPoint.init(x: rect.origin.x + jm_qr_cornerLineOffX + cornerLineLength, y: rect.origin.y + jm_qr_cornerLineOffY)]
        
        addLine(context: context, pointA: poinsTopLeftA, pointB: poinsTopLeftB)
        
        /// 左下角
        let poinsBottomLeftA = [
            CGPoint.init(x: rect.origin.x + jm_qr_cornerLineOffX, y: rect.origin.y + rect.size.height - jm_qr_cornerLineOffY - cornerLineLength),
            CGPoint.init(x: rect.origin.x + jm_qr_cornerLineOffX, y: rect.origin.y + rect.size.height - jm_qr_cornerLineOffY)
        ]
        
        let poinsBottomLeftB = [
            CGPoint.init(x: rect.origin.x + jm_qr_cornerLineOffX - 1,y: rect.origin.y + rect.size.height - jm_qr_cornerLineOffY),
            CGPoint.init(x: rect.origin.x + jm_qr_cornerLineOffX + cornerLineLength, y: rect.origin.y + rect.size.height - jm_qr_cornerLineOffY)
        ]
        
        addLine(context: context, pointA: poinsBottomLeftA, pointB: poinsBottomLeftB)
        
        /// 右上角
        let poinsTopRightA = [
            CGPoint.init(x: rect.origin.x + rect.size.width - jm_qr_cornerLineOffX - cornerLineLength, y: rect.origin.y + jm_qr_cornerLineOffY),
            CGPoint.init(x: rect.origin.x + rect.size.width - jm_qr_cornerLineOffX + 1, y: rect.origin.y + jm_qr_cornerLineOffY)
        ]
        
        let poinsTopRightB = [
            CGPoint.init(x: rect.origin.x + rect.size.width - jm_qr_cornerLineOffX, y: rect.origin.y + jm_qr_cornerLineOffY),
            CGPoint.init(x: rect.origin.x + rect.size.width - jm_qr_cornerLineOffX, y: rect.origin.y + cornerLineLength + jm_qr_cornerLineOffY)
        ]
        
        addLine(context: context, pointA: poinsTopRightA, pointB: poinsTopRightB)
        
        /// 右下角
        let poinsBottomRightA = [
            CGPoint.init(x: rect.origin.x + rect.size.width - jm_qr_cornerLineOffX, y: rect.origin.y + rect.size.height - jm_qr_cornerLineOffY - cornerLineLength),
            CGPoint.init(x: rect.origin.x + rect.size.width - jm_qr_cornerLineOffX, y: rect.origin.y + rect.size.height - jm_qr_cornerLineOffY)
        ]
        
        let poinsBottomRightB = [
            CGPoint.init(x: rect.origin.x + rect.size.width - jm_qr_cornerLineOffX - cornerLineLength, y: rect.origin.y + rect.size.height - jm_qr_cornerLineOffY),
            CGPoint.init(x: rect.origin.x + rect.size.width - jm_qr_cornerLineOffX + 1, y: rect.origin.y + rect.size.height - jm_qr_cornerLineOffY)
        ]
        
        addLine(context: context, pointA: poinsBottomRightA, pointB: poinsBottomRightB)
        
        context.strokePath()
    }
    
    private func addLine(context: CGContext, pointA: Array<CGPoint>, pointB: Array<CGPoint>) {
        context.addLines(between: pointA)
        context.addLines(between: pointB)
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects != nil && metadataObjects.count != 0 {
            let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
            self.handleScanResult(metadataObj?.stringValue ?? "")
        }
    }
    
}

public struct JMScanningQRCodeConfig {
    
    var device: AVCaptureDevice?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureMetadataOutput?
    var session: AVCaptureSession?
    var preview: AVCaptureVideoPreviewLayer?
    
    init(qrCodeView: JMSScanningQRCodeView, delegate: AVCaptureMetadataOutputObjectsDelegate!) {
        qrConfig(qrCodeView: qrCodeView, delegate: delegate)
    }
    
    mutating func qrConfig(qrCodeView: JMSScanningQRCodeView, delegate: AVCaptureMetadataOutputObjectsDelegate!) {
        /// 1.获取摄像头设备
        device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        /// 2.创建输入流
        input = try! AVCaptureDeviceInput.init(device: self.device)
        
        /// 3.创建输出流
        output = AVCaptureMetadataOutput()
        output!.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
        
        /// 4.创建会话对象
        session = AVCaptureSession()
        session!.sessionPreset = AVCaptureSessionPresetHigh
        
        if session!.canAddInput(input) {
            session!.addInput(input)
        }
        
        if session!.canAddOutput(output) {
            session!.addOutput(output)
        }
        
        /// 5.设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        output!.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]
        
        /// 6.实例化预览图层
        preview                             = AVCaptureVideoPreviewLayer.init(session: self.session)
        preview!.videoGravity               = AVLayerVideoGravityResize
        preview!.frame                      = qrCodeView.bounds
        
        qrCodeView.backgroundColor              = .clear
        qrCodeView.superview?.backgroundColor   = .clear
        
        qrCodeView.superview?.layer.insertSublayer(preview!, at: 0)
        
        preview!.connection.videoOrientation = videoOrientationFromCurrentDeviceOrientation()
        
        // 7.修正扫描区域
        let viewHeight = qrCodeView.frame.height
        let viewWidth  = qrCodeView.frame.width;
        let cropRect   = CGRect.init(x: (viewWidth - qrCodeView.transparentArea.width) / 2, y: qrCodeView.transparentOriginY, width: qrCodeView.transparentArea.width, height: qrCodeView.transparentArea.height)
        
        output!.rectOfInterest = CGRect.init(x: cropRect.origin.y / viewHeight, y: cropRect.origin.x / viewWidth, width: cropRect.size.height / viewHeight, height: cropRect.size.width / viewWidth)
    }
    
    private func videoOrientationFromCurrentDeviceOrientation() -> AVCaptureVideoOrientation {
        let orientation = UIApplication.shared.statusBarOrientation
    
        switch orientation {
        case .portrait:
            return .portrait
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portraitUpsideDown:
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
}
