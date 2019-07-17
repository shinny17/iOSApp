//
// MyBookViewController.swift
// BookProject

import UIKit
import CoreData
import AVFoundation

class MyBookViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var tblView : UITableView!
    let removeSound = URL(fileURLWithPath: Bundle.main.path(forResource: "removeSound", ofType: "m4a")!)
    var audioPlayer = AVAudioPlayer()
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
        
        tblView.tableFooterView = UIView()
        
        fetchRequest.sortDescriptors = [sortByTitleIndex, sortByTitle]
        fetchRequest.predicate = NSPredicate(format: "isSaveBook == %@", "1")
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: #keyPath(BookCoreData.titleIndex), cacheName: nil)
    }
    
    private func executeSearch() {
        if let fc = fetchedResultsController {
            try? fc.performFetch()
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.title = "My Books"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
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
        
        if inSearchMode{
            
            let cell = tblView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
            
            let mainView = cell.contentView.viewWithTag(1000) as UIView?
            let lblBookName = cell.contentView.viewWithTag(1001) as! UILabel
            let lblISBN = cell.contentView.viewWithTag(1002) as! UILabel
            let btnMoreInfo = cell.contentView.viewWithTag(1004) as! UIButton
            let btnRemove = cell.contentView.viewWithTag(1005) as! UIButton
            
            mainView?.layer.borderWidth = 0.5
            mainView?.layer.cornerRadius = 5
            
            btnMoreInfo.layer.cornerRadius = 5
            btnRemove.layer.cornerRadius = 5
            
            btnMoreInfo.addTarget(self, action: #selector(self.clickOnMoreInfo(sender:)), for: UIControl.Event.touchUpInside)
            
            btnRemove.addTarget(self, action: #selector(self.clickOnRemove(sender:)), for: UIControl.Event.touchUpInside)
            
            let book = fetchedResultsController?.object(at: indexPath) as! Book
            
            lblBookName.text = "Name: " + book.bookInformation.title
            lblISBN.text = "ISBN: " + book.bookInformation.isbn!
            
            
            cell.selectionStyle = .none
            
            tblView.separatorStyle = .none
            
            return cell
        }
        else{
            
            let cell = tblView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
            
            let mainView = cell.contentView.viewWithTag(1000) as UIView?
            let lblBookName = cell.contentView.viewWithTag(1001) as! UILabel
            let lblAuthorName = cell.contentView.viewWithTag(1002) as! UILabel
            let rating = cell.contentView.viewWithTag(1003) as! HCSStarRatingView
            let btnMoreInfo = cell.contentView.viewWithTag(1004) as! UIButton
            let btnRemove = cell.contentView.viewWithTag(1005) as! UIButton
            let ratinglbl = cell.contentView.viewWithTag(12) as! UILabel
            
            mainView?.layer.borderWidth = 0.5
            mainView?.layer.cornerRadius = 5
            
            btnMoreInfo.layer.cornerRadius = 5
            btnRemove.layer.cornerRadius = 5
            
            btnMoreInfo.addTarget(self, action: #selector(self.clickOnMoreInfo(sender:)), for: UIControl.Event.touchUpInside)
            
            btnRemove.addTarget(self, action: #selector(self.clickOnRemove(sender:)), for: UIControl.Event.touchUpInside)
            
            let book = fetchedResultsController?.object(at: indexPath) as! Book
            
            lblBookName.text = "Name: " + book.bookInformation.title
            lblAuthorName.text = "Author: " + book.bookInformation.authors
            
            if book.bookInformation.rating != nil{
                rating.value = CGFloat((book.bookInformation.rating! as NSString).doubleValue)
            }
            else{
                rating.value = 0.0
            }
            
            ratinglbl.accessibilityLabel = "Rating: \(rating.value) out of 5 stars"
            ratinglbl.accessibilityTraits = UIAccessibilityTraits.none
            
            
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
        self.navigationItem.title = "My Books"
        bookDetailVC.isFromMyBook = true
        bookDetailVC.strTitle = "Book Details"
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
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: removeSound)
            audioPlayer.prepareToPlay()
        } catch {
            print("Problem in getting File")
        }
        audioPlayer.play()
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

extension MyBookViewController: NSFetchedResultsControllerDelegate {
    // MARK: Fetched Results Controller Delegate
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

// MARK: - Extensions
extension MyBookViewController: UISearchBarDelegate {
    
    // MARK: UISearchBar Delegate
    
    /*  First I tried to filter the objects returned by the fetchedResultsController
     See http://stackoverflow.com/questions/35024980/searchbar-display-in-table-view-with-coredata-using-swift
     
     filteredBooks = fetchedResultsController?.fetchedObjects as? [Book]
     
     if searchText == "" {
     filteredBooks = fetchedResultsController?.fetchedObjects as? [Book]
     } else {
     filteredBooks = fetchedResultsController?.fetchedObjects?.filter() {
     return searchPredicate!.evaluate(with: $0)
     } as! [Book]?
     }
     tableView.reloadData()
     
     The filtered objects were saved in an Array "filteredBooks"
     TableView functions used the "filteredBooks" Array while in search mode
     This worked fine, except for Insertions and Deletions of Objects in CoreData
     
     The following solutions works fine but I believe performance wise this is not
     the best way to go for larger datasets. Have to read more about profiling and
     Core Data in general to find a better implementation.
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        inSearchMode = true
        
        // Search in title, authors, publisher and ISBN
        let searchPredicate = NSPredicate(format: "((title contains[c] $text) OR (authors contains[c] $text) OR (publisher contains[c] $text) OR (isbn contains[c] $text)) AND isSaveBook=1").withSubstitutionVariables(["text" : searchText])
        
        if searchText.isEmpty {
            // Request not filtered
            fetchRequest.predicate = NSPredicate(format: "isSaveBook == %@", "1")
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
        
        fetchRequest.predicate = NSPredicate(format: "isSaveBook == %@", "1")
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
