//
//  ScanViewController.swift
//  BookProject
//


import UIKit
import BarcodeScanner

class ScanViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
       
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let scanVC = self.storyboard?.instantiateViewController(withIdentifier: "ScanVC") as! ScanVC
        scanVC.hidesBottomBarWhenPushed  = true
        self.tabBarController?.tabBar.isTranslucent = false
        self.navigationController?.pushViewController(scanVC, animated: false)
    }
    
}

