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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func generateQRCode(_ sender: Any) {
        navigationController?.pushViewController(JMSGenerateQRCodeVC(), animated: true)
    }
    
    @IBAction func scanQRCode(_ sender: Any) {
        JMSScanningQRCodeUtils.jm_cameraAuthStatus(success: { 
            self.navigationController?.pushViewController(JMSScanningQRCodeVC(), animated: true)
        }) { 
            
        }
    }

}

