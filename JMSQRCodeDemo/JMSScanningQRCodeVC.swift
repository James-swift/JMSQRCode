//
//  JMSScanningQRCodeVC.swift
//  JMSQRCodeDemo
//
//  Created by James.xiao on 2017/3/14.
//  Copyright © 2017年 James. All rights reserved.
//

import UIKit

class JMSScanningQRCodeVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var qrView: JMSScanningQRCodeView?
    private var firstLoad: Bool = true
    private var loadView: JMQRCodeLoadView?
    
    private var lightBtn: UIButton = {
        let tempView = UIButton.init(type: .system)
        
        return tempView
    }()
    
    private var isOpenLight = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopRunning()
    }
    
    func setupViews() {
        setupRightBarButtonItem()
        view.backgroundColor = .white
        self.title = "扫一扫"
        
        qrView = JMSScanningQRCodeView.init(frame: self.view.bounds)
        qrView?.qrLineImageName = "jm_qr_line"
        qrView?.backgroundColor = .clear
        qrView?.scanningQRCodeResult = { [weak self] (result) in
            print("扫描结果: %@", result)
            var type: JMSScanningResultType = .barCode
            if result.hasPrefix("http") {
                type = .qrCode
            }
            
            self?.push(type: type, result: result)
        }
        
        view.addSubview(qrView!)
        
        let infoLabel      = UILabel.init(frame: CGRect.init(x: 0, y: qrView!.transparentOriginY + qrView!.transparentArea.height + 10, width: self.view.bounds.size.width, height: 20))
        infoLabel.text          = "将二维码/条码放入框内，即可自动扫描"
        infoLabel.textAlignment = .center
        infoLabel.textColor     = .white
        infoLabel.font          = UIFont.systemFont(ofSize: 13.0)
        
        view.addSubview(infoLabel)
        
        lightBtn.frame = CGRect.init(x: (self.view.frame.width - 50) / 2, y: infoLabel.frame.origin.y + infoLabel.frame.size.height + 5, width: 50, height: 50)
        lightBtn.setTitleColor(.green, for: .normal)
        lightBtn.setTitle("开灯", for: .normal)
        lightBtn.addTarget(self, action: #selector(changeLightSwitch), for: .touchUpInside)
        
        view.addSubview(lightBtn)
        
        setupLoadView()
    }
    
    func setupLoadView() {
        if loadView == nil {
            loadView                   = JMQRCodeLoadView.init(frame: self.view.bounds)
            loadView!.backgroundColor  = .black
            
            self.view.addSubview(loadView!)
        }
    }
    
    func setupRightBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "相册", style: .done, target: self, action: #selector(handleRightBarButtonAction))
    }
    
    func startRunning() {
        if firstLoad {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                self.firstLoad          = false
                self.loadView?.isHidden = true
                self.loadView?.indicatorView.stopAnimating()
                self.loadView?.removeFromSuperview()
                
                self.qrView?.startRunning()
            })
        }else {
            qrView?.startRunning()
        }
    }

    func stopRunning() {
        qrView?.stopRunning()
    }
    
    // MARK: - Event Response
    func changeLightSwitch() {
        isOpenLight = !isOpenLight
        
        if (isOpenLight) {
            lightBtn.setTitle("关灯", for: .normal)
        }else {
            lightBtn.setTitle("开灯", for: .normal)
        }
        
        qrView!.openSystemLight = isOpenLight;
    }
    
    func push(type: JMSScanningResultType, result: String) {
        let resultVC        = JMSScanningResultVC()
        resultVC.resultType = type
        resultVC.resultInfo = result
        
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
    // MARK: - 相册
    func handleRightBarButtonAction() {
        let imagePicker = UIImagePickerController.init()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true) { 
            let result = JMSScanningQRCodeUtils.jm_scanQRCodeFromPhotosAlbum(info[UIImagePickerControllerOriginalImage] as! UIImage)
            print("扫描结果: %@", result)

            self.push(type: .qrCode, result: result)
        }
    }
    
}
