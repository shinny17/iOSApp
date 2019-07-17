//
//  ResultViewController.swift
//  BookProject
// referenced from Bhatt, 2019


import UIKit

class ResultViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    

    @IBOutlet var tblView : UITableView!
    @IBOutlet weak var outerActivityIndicatorView: UIView!
    @IBOutlet weak var searchActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var nothingFoundView: UIView!
    @IBOutlet weak var nothingFoundMessage: UILabel!
    
    var searchWord : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        // Do any additional setup after loading the view.
        
        tblView.tableFooterView = UIView()
        
        outerActivityIndicatorView.isHidden = false
        searchActivityIndicatorView.startAnimating()
        
        self.searchBook()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.title = "Results"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    func searchBook()
    {
        guard let searchTerm = searchWord else {
            fatalError("searchTerm should not be empty")
        }
        
        // Adapt search term for parametrization of the google book search url
        let concatenatedSearchTerm = searchTerm.replacingOccurrences(of: " ", with: "+")
        
        // Ask Google Books API for search term
        GoogleBooksAPI.shared.searchGoogleBooks(concatenatedSearchTerm) { (result) in
            // Hide Activity View Indicator
            DispatchQueue.main.async {
                self.searchActivityIndicatorView?.stopAnimating()
                self.outerActivityIndicatorView?.isHidden = true
            }
            switch result {
            case .success:
                DispatchQueue.main.async {
                    // Show results
                    self.tblView.isHidden = false
                    self.tblView.reloadData()
                    // After a search scroll to first row of table view
                    self.tblView.scrollToRow(at: [0,0], at: UITableView.ScrollPosition.top, animated: false)
                }
            case .nothingFound:
                // Show message if nothing was found
                DispatchQueue.main.async {
                    self.nothingFoundMessage.text = "Nothing found for \n\n\"\(searchTerm)\""
                    self.nothingFoundView.isHidden = false
                }
            case .failure:
                // Show alert if a network error occured
                DispatchQueue.main.async {
                    self.showAlert(title: "Network Error", message: "Please try again later.")
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return BookLibrary.shared.books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
        
        let mainView = cell.contentView.viewWithTag(1000) as UIView?
        let lblBookName = cell.contentView.viewWithTag(1001) as! UILabel
        let lblAuthorName = cell.contentView.viewWithTag(1002) as! UILabel
        let rating = cell.contentView.viewWithTag(1003) as! HCSStarRatingView
        let btnSelect = cell.contentView.viewWithTag(1004) as! UIButton
        let lblRatingLabel = cell.contentView.viewWithTag(110) as! UILabel
        let book = BookLibrary.shared.books[indexPath.row]
        
        lblBookName.text = "Name: " + book.bookInformation.title
        lblAuthorName.text = "Author: " + book.bookInformation.authors
        
        if book.bookInformation.rating != nil{
            rating.value = CGFloat((book.bookInformation.rating! as NSString).doubleValue)
        }
        else{
            rating.value = 0.0
        }
       
        //accessibilityElements = [rating, lblRatingLabel, lblBookName, lblAuthorName, btnSelect]
        lblRatingLabel.accessibilityLabel = "Rating: \(rating.value) out of 5 stars"
        lblRatingLabel.accessibilityTraits = UIAccessibilityTraits.none
        
        var elements = [UIAccessibilityElement]()
        let groupedElement = UIAccessibilityElement(accessibilityContainer: self)
        groupedElement.accessibilityFrameInContainerSpace = lblRatingLabel.frame.union(btnSelect.frame)
        elements.append(groupedElement)
        
        mainView?.layer.borderWidth = 0.55
        mainView?.layer.cornerRadius = 5
        
        //btnSelect.layer.borderWidth = 1
        btnSelect.layer.cornerRadius = 5
        
        btnSelect.addTarget(self, action: #selector(self.clickOnSelect(sender:)), for: UIControl.Event.touchUpInside)
        
        cell.selectionStyle = .none
        
        tblView.separatorStyle = .none
        
        return cell
    }
    
    @objc func clickOnSelect(sender:UIButton)
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
        self.navigationItem.title = "Results"
        bookDetailVC.strTitle = "Book Details"
        bookDetailVC.detailViewState = DetailViewState.SaveBook
        bookDetailVC.book = BookLibrary.shared.books[indexPath!.row]
        self.navigationController?.pushViewController(bookDetailVC
            , animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        if searchBar.text != ""{
            
            let resultVC = self.storyboard?.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
            resultVC.searchWord = searchBar.text!
            self.navigationItem.title = "Results"
            self.navigationController?.pushViewController(resultVC, animated: true)
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
    }
    
    
    
}
