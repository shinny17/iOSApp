//
// ScanVC.swift
// BookProject
// referenced from Pham et. al., 2018
// miscellaneous files from above reference (Pham et. al., 2018) in folder BarcodeScanner.

import UIKit
import BarcodeScanner

class ScanVC: UIViewController {
    
    @IBOutlet var btnScanHistory : UIButton!
    @IBOutlet var btnBack : UIButton!
    
    var viewController : BarcodeScannerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        btnScanHistory.layer.borderWidth = 0.5
        btnScanHistory.layer.cornerRadius = 5
        
        btnBack.layer.borderWidth = 0.5
        btnBack.layer.cornerRadius = 5
        
        btnScanHistory.isAccessibilityElement = true
        btnScanHistory.accessibilityLabel = "Scan History"
        btnScanHistory.accessibilityTraits = UIAccessibilityTraits.button
        btnScanHistory.accessibilityHint = "Click to view previously scanned books"
        
        btnBack.isAccessibilityElement = true
        btnBack.accessibilityLabel = "Back"
        btnBack.accessibilityTraits = UIAccessibilityTraits.button
        btnBack.accessibilityHint = "Click to navigate to search tab"
        
    }
    
    
    func setupCamera()
    {
        viewController = makeBarcodeScannerViewController()
        viewController.view.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.view.frame.size.height - 60)
        self.view.addSubview(viewController.view)
        self.addChild(viewController)
        viewController.didMove(toParent: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.setupCamera()
        
        self.navigationItem.title = "Barcode Scanner"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.isTranslucent = false
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.isHidden = true

    }
    
    private func makeBarcodeScannerViewController() -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.codeDelegate = self
        viewController.errorDelegate = self
        return viewController
    }
    
    @IBAction func clickOnScanHistory(sender:UIButton)
    {
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
        
        let scanHistoryVC = self.storyboard?.instantiateViewController(withIdentifier: "ScanHistoryVC") as! ScanHistoryVC
        self.navigationItem.title = "Scanner"
        self.navigationController?.pushViewController(scanHistoryVC, animated: true)
    }
    
    @IBAction func clickOnBack(sender:UIButton)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.setupTabbarcontroller(index: 0)
    }
    
    
}
// MARK: - BarcodeScannerCodeDelegate

extension ScanVC: BarcodeScannerCodeDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print("Barcode Data: \(code)")
        print("Symbology Type: \(type)")
                    
        let bookDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "BookDetailViewController") as! BookDetailViewController
        bookDetailVC.isbn = code
        bookDetailVC.isFromScan = true
        self.navigationItem.title = "Scanner"
        bookDetailVC.strTitle = "Scan History"
        bookDetailVC.hidesBottomBarWhenPushed = false
        self.navigationController?.pushViewController(bookDetailVC, animated: true)
        
        controller.reset()

    }
}

// MARK: - BarcodeScannerErrorDelegate

extension ScanVC: BarcodeScannerErrorDelegate {
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
        
    }
}
