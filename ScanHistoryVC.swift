//
// ScanHistoryVC.swift
// BookProject
//referenced from Pham et. al., 2018
// miscellaneous files from above reference (Pham et. al., 2018) in folder BarcodeScanner.


import UIKit
import CoreData

class ScanHistoryVC: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet var tblView : UITableView!

    private let sortByTitleIndex = NSSortDescriptor(key: "titleIndex", ascending: true)
    private let sortByAuthor = NSSortDescriptor(key: "authors", ascending: true)
    private let sortByTitle = NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
    
    
    fileprivate var stack: CoreDataStack {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    fileprivate var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, execute the search and reload the data
            fetchedResultsController?.delegate = self
            executeSearch()
            tblView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        // Do any additional setup after loading the view.
        
        self.tabBarController?.tabBar.isHidden = false

        tblView.tableFooterView = UIView()
        
        fetchRequest.sortDescriptors = [sortByTitleIndex, sortByTitle]
        fetchRequest.predicate = NSPredicate(format: "isScan == %@", "1")
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: #keyPath(BookCoreData.titleIndex), cacheName: nil)
        
        
    }
    
    fileprivate var inSearchMode: Bool = false {
        didSet {
            // disable segment control while searching
            if inSearchMode {
                // while in search mode sort results just by title
                fetchRequest.sortDescriptors = [sortByTitle]
            } else {
                // reset search predicate
                fetchRequest.predicate = nil
            }
        }
        
    }
    
    private func executeSearch() {
        if let fc = fetchedResultsController {
            try? fc.performFetch()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationItem.title = "Scan History"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        guard !inSearchMode else { return 1 }
        guard let sections = fetchedResultsController?.sections else { return 0 }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sectionInfo = fetchedResultsController?.sections?[section] else { fatalError("Unexpected Section") }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
        
        let mainView = cell.contentView.viewWithTag(1000) as UIView?
        let lblBookName = cell.contentView.viewWithTag(1002) as! UILabel
        let lblISBN = cell.contentView.viewWithTag(1004) as! UILabel
        let btnMoreInfo = cell.contentView.viewWithTag(1005) as! UIButton
        let btnRemove = cell.contentView.viewWithTag(1006) as! UIButton

        
        mainView?.layer.borderWidth = 0.5
        mainView?.layer.cornerRadius = 5
        
        btnMoreInfo.layer.cornerRadius = 5
        btnRemove.layer.cornerRadius = 5
        
        btnMoreInfo.addTarget(self, action: #selector(self.clickOnMoreInfo(sender:)), for: UIControl.Event.touchUpInside)
        
        btnRemove.addTarget(self, action: #selector(self.clickOnRemove(sender:)), for: UIControl.Event.touchUpInside)
        
        let book = fetchedResultsController?.object(at: indexPath) as! Book
        
        lblBookName.text = "Name: " + book.bookInformation.title
        lblISBN.text =  book.bookInformation.isbn
    
        
        btnMoreInfo.isAccessibilityElement = true
        btnMoreInfo.accessibilityLabel = "More Information"
        btnMoreInfo.accessibilityTraits = UIAccessibilityTraits.button
        btnMoreInfo.accessibilityHint = "Click to view more information on \(book.bookInformation.title)"
        
        btnRemove.isAccessibilityElement = true
        btnRemove.accessibilityLabel = "Remove"
        btnRemove.accessibilityTraits = UIAccessibilityTraits.button
        btnRemove.accessibilityHint = "Click to remove \(book.bookInformation.title)"
        
        
        cell.selectionStyle = .none
        
        tblView.separatorStyle = .none
        
        return cell
    }
    
    @objc func clickOnMoreInfo(sender:UIButton)
    {
        var tempView = sender as UIView
        
        var cell : UITableViewCell!
        
        while true {
            
            if tempView.isKind(of: UITableViewCell.self){
                cell = tempView as? UITableViewCell
                break
            }
            else{
                tempView = tempView.superview!
            }
        }
        
        let indexPath = tblView.indexPath(for: cell)
        
        let bookDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "BookDetailViewController") as! BookDetailViewController
        self.navigationItem.title = "Scan History"
        bookDetailVC.isFromMyBook = false
        bookDetailVC.strTitle = "Book Details"
        bookDetailVC.isFromScanHistory = true
        bookDetailVC.detailViewState = DetailViewState.SaveBook
        bookDetailVC.book = fetchedResultsController?.object(at: indexPath!) as? Book
        self.navigationController?.pushViewController(bookDetailVC
            , animated: true)
    }
    
    @objc func clickOnRemove(sender:UIButton)
    {
        var tempView = sender as UIView
        
        var cell : UITableViewCell!
        
        while true {
            
            if tempView.isKind(of: UITableViewCell.self){
                cell = tempView as? UITableViewCell
                break
            }
            else{
                tempView = tempView.superview!
            }
        }
        
        let indexPath = tblView.indexPath(for: cell)
        
        let controller = UIAlertController.init(title: "Message", message: "Are you sure you want to remove?", preferredStyle: .alert)
        
        let actionOk = UIAlertAction.init(title: "Ok", style: .default) { (action) in
            
            self.stack.context.delete(self.fetchedResultsController?.object(at: indexPath!) as! NSManagedObject)
            self.stack.save()
        }
        
        controller.addAction(actionOk)
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .default) { (action) in
            
            controller.dismiss(animated: true, completion: nil)
        }
        
        controller.addAction(actionCancel)
        
        self.present(controller, animated: true, completion: nil)
        
    }
    
 


}
extension ScanHistoryVC: NSFetchedResultsControllerDelegate {
    // Fetched Results Controller Delegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tblView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        
        switch (type) {
        case .insert:
            tblView.insertSections(set, with: .fade)
        case .delete:
            tblView.deleteSections(set, with: .fade)
        default:
            assertionFailure("The NSFetchedResultsChangeType \(type) for a section info is not covered")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        case .insert:
            tblView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tblView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tblView.reloadRows(at: [indexPath!], with: .fade)
        default:
            assertionFailure("The NSFetchedResultsChangeType \(type) for an object is not covered")
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tblView.endUpdates()
        // Hide table view if book list doesn't contain a book anymore
    }
    
}

extension ScanHistoryVC: UISearchBarDelegate {
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        inSearchMode = true
        
        // Search in title, authors, publisher and ISBN
        let searchPredicate = NSPredicate(format: "((title contains[c] $text) OR (authors contains[c] $text) OR (publisher contains[c] $text) OR (isbn contains[c] $text)) AND isScan=1").withSubstitutionVariables(["text" : searchText])
        
        if searchText.isEmpty {
            // Request not filtered
            fetchRequest.predicate = NSPredicate(format: "isScan == %@", "1")
        } else {
            fetchRequest.predicate = searchPredicate
        }
        
        // Fetch filtered books
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: false)
        
        inSearchMode = false
        
        fetchRequest.predicate = NSPredicate(format: "isScan == %@", "1")
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        tblView.reloadData()
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
