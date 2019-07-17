//
//  HelpViewController.swift
//  BookProject
//
//

import UIKit

class HelpViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tblView : UITableView!

    var arrExpandedObjects = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        // Do any additional setup after loading the view.
        
        tblView.estimatedRowHeight = 44
        tblView.rowHeight = UITableView.automaticDimension
        
        tblView.tableFooterView = UIView()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.title = "Help"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if arrExpandedObjects.contains(NSNumber.init(value: section)){
            return 1
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
       
        
        let lblDesc = cell.contentView.viewWithTag(1001) as! UILabel
        lblDesc.isAccessibilityElement = true
        //print(indexPath.section)
        
        lblDesc.numberOfLines = 0
        
        if indexPath.section == 0{
           
            lblDesc.text = "This is the search tab where you can search for a book and find its details such as author, title, ISBN, etc. On the top of the screen there is a searh bar right below the navigation title. And at the bottom of the page is a voice recording button right above the tab bar which begins recording your voice once you click it."
            
            lblDesc.accessibilityLabel = lblDesc.text
        }
        else if indexPath.section == 1{
           
            lblDesc.text = "This is the My books tab where the user can view saved books and create a collection of favourite books. The more information button shows more details of the book and the remove button removes the book from your collection.On clicking the remove button, an alert message will appear to conform the book deletion. Click OK to confirm and click cancel to undo the action."
            lblDesc.accessibilityLabel = lblDesc.text
        }
        else if indexPath.section == 2{
          
            lblDesc.text = "This is the scan tab where you can scan the barcode of a book to view its information. Place the barcode of the book to your device camera and it will scan the barcode automatically. The application will then scan the barcode to show the details. Click on the scan history button to view previously scanned books and the back button to navigate back to the search page. "
            lblDesc.accessibilityLabel = lblDesc.text
        }
        
        lblDesc.sizeToFit()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tblView.frame.size.width, height: 50))
        headerView.backgroundColor = UIColor.init(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1.0)
        
        let lblTitle = UILabel()
        lblTitle.frame = CGRect.init(x: 10, y: 0, width: 150, height: 50)
        
        if section == 0{
            lblTitle.text = "Search"
        }
        else if section == 1{
            lblTitle.text = "My Books"
        }
        else{
            lblTitle.text = "Scan"
        }
        
        
        
        let lblLine = UILabel.init(frame: CGRect.init(x: 0, y: 49, width: headerView.frame.size.width, height: 1))
        lblLine.backgroundColor = UIColor.black
        
        headerView.addSubview(lblLine)
        
        headerView.addSubview(lblTitle)
       
        headerView.tag = section
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnHeader(gesture:)))
        headerView.isUserInteractionEnabled = true
        headerView.isAccessibilityElement = true
        headerView.accessibilityLabel = lblTitle.text
        headerView.accessibilityTraits = UIAccessibilityTraits.button
        headerView.accessibilityHint = "Click to view text"
        headerView.addGestureRecognizer(tapGesture)
        
        return headerView
    }
    
    
    @objc func tapOnHeader(gesture:UITapGestureRecognizer)
    {
        let tag: Int = gesture.view!.tag
        let section = NSNumber.init(value: tag)
        
        tblView.beginUpdates()
        
        if arrExpandedObjects.contains(section) {
            
            deleteRows(section: section.intValue)
            
            let elementIndex = arrExpandedObjects.index(of: section)
            arrExpandedObjects.removeObject(at: elementIndex)
            
        } else {
            
            arrExpandedObjects.removeAllObjects()
            self.deleteAllRows()
            
            arrExpandedObjects.add(section)
            insertRow(section: section.intValue)
        }
        
        tblView.endUpdates()
        
    }
    
    
    func insertRow(section:NSInteger)
    {
        let count: Int = 1
        
        for i in 0..<count {
            
            let indexpath = IndexPath(row: i, section: section)
            tblView.insertRows(at: [indexpath], with: .none)
        }
        
    }
    
    func deleteAllRows() {
        
        let section: Int = tblView.numberOfSections
        
        for i in 0..<section {
            
            deleteRows(section: i)
        }
    }
    
    func deleteRows(section:NSInteger)
    {
        let numberOfRowsInSection: Int = tblView.numberOfRows(inSection: section)
        
        for i in 0..<numberOfRowsInSection {
            
            let indexpath = IndexPath(row: i, section: section)
            tblView.deleteRows(at: [indexpath], with: .none)
        }
        
    }
    
    
    
}
