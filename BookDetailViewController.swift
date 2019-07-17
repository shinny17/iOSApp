//
// BookDetailViewController.swift
// BookProject
/// referenced from Bhatt, 2019

import UIKit
import CoreData

enum DetailViewState {
    case SaveBook
    case ShareBook
}

class BookDetailViewController: UIViewController,UITextViewDelegate {
    
    @IBOutlet var txtView : UITextView!
    @IBOutlet var btnSave : UIButton!
    @IBOutlet var imgViewBook : UIImageView!
    @IBOutlet var lblBookName : UILabel!
    @IBOutlet var lblBookAuthor : UILabel!
    @IBOutlet var lblBookISBN : UILabel!
    @IBOutlet var ratingLbl: UILabel!
    @IBOutlet var ratingView : HCSStarRatingView!
    @IBOutlet weak var previewBookButton: UIButton!
    @IBOutlet var reviewAE: UIView!
    
    var book: Book!
    var detailViewState: DetailViewState!
    var isFromMyBook : Bool = false
    var isFromScan : Bool = false
    var isFromScanHistory : Bool = false
    
    var isbn:String = ""
    var strTitle : String = ""
    
    private var previewURLString: String?
    
    
    var stack: CoreDataStack {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    private let sortByISBN = NSSortDescriptor(key: "isbn", ascending: true)
    fileprivate var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Book")
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, execute the search and reload the data
            executeSearch()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.tabBarController?.tabBar.isHidden = false
        
        txtView.layer.borderWidth = 0.5
        
        txtView.isAccessibilityElement = true
        txtView.accessibilityLabel = "Reviews"
        
        btnSave.layer.borderWidth = 0.5
        btnSave.layer.cornerRadius = 5
        
        
        
        if self.isFromMyBook{
            
            btnSave.backgroundColor = UIColor.orange
            btnSave.setTitle("Saved", for: UIControl.State.normal)
            btnSave.isUserInteractionEnabled = false
            btnSave.setTitleColor(UIColor.white, for: UIControl.State.normal)
            btnSave.layer.borderWidth = 0
            
        }
        else{
            
            if self.isFromScanHistory {
                
                do{
                    fetchRequest.predicate = NSPredicate.init(format: "isSaveBook = %@","1")
                    let result = try stack.context.fetch(fetchRequest)
                    let resultData = result as! [Book]
                    
                    if resultData.count > 0{
                        
                        self.isFromScanHistory = false
                        btnSave.backgroundColor = UIColor.orange
                        btnSave.setTitle("Saved", for: UIControl.State.normal)
                        btnSave.isUserInteractionEnabled = false
                        btnSave.accessibilityHint = "Book Saved in My Books"
                        btnSave.setTitleColor(UIColor.white, for: UIControl.State.normal)
                        btnSave.layer.borderWidth = 0
                    }
                }
                catch{
                    
                    
                
                }
                
            }else{
                
                btnSave.backgroundColor = UIColor.white
                btnSave.setTitle("Save", for: UIControl.State.normal)
                btnSave.isUserInteractionEnabled = true
            }
        }
        
        if self.isFromScan{
            self.setupBookDetailFromScan()
        }
        else{
            self.setupBookDetails()
        }
        
    }
    
    
    private func executeSearch() {
        if let fc = fetchedResultsController {
            try? fc.performFetch()
        }
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isTranslucent = false
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Book Details"

        
        edgesForExtendedLayout = .all
        extendedLayoutIncludesOpaqueBars = true
    }
    
    func setupBookDetailFromScan()
    {
        self.loadBooks()
    }
    
    func loadBooks() {
        
        let bookRequest = "https://www.googleapis.com/books/v1/volumes?q=" + isbn
        if let url = URL(string: bookRequest) {
            
            let session = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let response = response{
                    print(response)
                }
                if let error = error{
                    print("Ashin: \(error)")
                }
                
                DispatchQueue.main.async {
                    
                    if let data = data {
                        do{
                            
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
                            if json["items"] != nil{
                                
                                let item = json["items"] as! [[String: AnyObject]]
                               
                                let kindArray = item[0]
                                let  volumeInfo = kindArray["volumeInfo"] as! [String: AnyObject]
                                
                                self.lblBookName.text = volumeInfo["title"] as? String
                                
                                if volumeInfo["authors"] != nil{
                                    
                                    let author = volumeInfo["authors"] as! [String]
                                    let authors = author.joined(separator: ", ")
                                    self.lblBookAuthor.text = authors
                                }
                                
                                if volumeInfo["averageRating"] != nil{
                                    
                                    let rating = volumeInfo["averageRating"] as! Double
                                    self.ratingView.value = CGFloat(rating)
                                }
                                
                                if volumeInfo["imageLinks"] != nil
                                {
                                    let imageUrl = volumeInfo["imageLinks"] as! [String: AnyObject]
                                    let BookImageUrl = imageUrl["thumbnail"] as! String
                                    
                                    DispatchQueue.main.async {
                                        let urlImage = URL(string: BookImageUrl)
                                        let data = try? Data(contentsOf: urlImage!)
                                        if data != nil {
                                            let image = UIImage(data: data!)
                                            self.imgViewBook.image = image
                                        }
                                        self.isbn = ""
                                    }
                                }
                                
                                self.lblBookISBN.text = self.isbn
                                
                                if volumeInfo["description"] != nil{
                                    self.txtView.text = volumeInfo["description"] as? String
                                }
                                
                                if volumeInfo["previewLink"] != nil
                                {
                                    self.previewURLString = volumeInfo["previewLink"] as? String
                                    self.previewBookButton.isEnabled = (self.previewURLString != nil)
                                }
                                
                                var listOfBooks = [Book]()
                                
                                for item in item {
                                    // Is there any volume info?
                                    let bookInfo = item[GoogleBooksAPI.GoogleBooksResponseKeys.VolumeInfo] as? [String:AnyObject]
                                    
                                    
                                    // Add the book to the list, if the book information could be created
                                    if let bookInformation = BookInformation.from(json: bookInfo!) {
                                        listOfBooks.append(BookImageCaching(bookInformation: bookInformation))
                                    }
                                }
                                
                                self.book = listOfBooks[0]
                                
                                _ = BookCoreData(book: self.book , context: self.stack.context, isScan:"1", isSaveBook:"0")
                                self.stack.save()
                            }
                        }
                        catch {
                            
                        }
                    }
                }
            }
            session.resume()
        }
    }
    
    
    func setupBookDetails()
    {
        book.fetchCoverImage { (coverImage) in
            
            if let coverImage = coverImage {
                DispatchQueue.main.async {
                    self.imgViewBook.image = coverImage
                }
            }
        }
        
        self.lblBookName.text = book.bookInformation.title
        self.lblBookAuthor.text = book.bookInformation.authors
        self.lblBookISBN.text =  book.bookInformation.isbn
        
        if book.bookInformation.rating != nil{
            self.ratingView.value = CGFloat((book.bookInformation.rating! as NSString).doubleValue)
        }
        
        ratingView.isAccessibilityElement = true
        ratingView.accessibilityLabel = "\(self.ratingView.value) out of 5 stars"
        ratingView.accessibilityTraits = UIAccessibilityTraits.none
        
        reviewAE.isAccessibilityElement = true
        reviewAE.accessibilityLabel = "Reviews"
        reviewAE.accessibilityHint = "swipe with two fingers to read review below"
        reviewAE.accessibilityTraits = UIAccessibilityTraits.staticText
        
        
        txtView.text = book.bookInformation.descriptionBook
        imgViewBook.isAccessibilityElement = true
        imgViewBook.accessibilityLabel = "\(book.bookInformation.title))"
        
        btnSave.isAccessibilityElement = true
        btnSave.accessibilityLabel = btnSave.currentTitle
        btnSave.accessibilityTraits = UIAccessibilityTraits.button
        if (btnSave.currentTitle == "Save") {
        btnSave.accessibilityHint = "Click to save \(book.bookInformation.title)"
        }
        else if (btnSave.currentTitle == "Saved"){
            btnSave.accessibilityHint = "Saved in My Books"
        }
        
        previewURLString = book.bookInformation.googleBookURL
        previewBookButton.isEnabled = (previewURLString != nil)
        
    }
    
    @IBAction func clickOnSave(sender:UIButton)
    {
        if self.isFromScanHistory || self.isFromScan{
            
            
            _ = BookCoreData(book: self.book , context: stack.context, isScan:"1", isSaveBook:"1")
            stack.save()
            
        }else{
            
            _ = BookCoreData(book: book, context: stack.context, isScan:"0", isSaveBook:"1")
            stack.save()
        }
        
        UIView.animate(withDuration: 1.0) {
            
            self.btnSave.backgroundColor = UIColor.orange
            self.btnSave.setTitle("Saved", for: UIControl.State.normal)
            self.isFromMyBook = true 
            self.btnSave.setTitleColor(UIColor.white, for: UIControl.State.normal)
            self.btnSave.layer.borderWidth = 0
        }
    }
    
    @IBAction func previewBookTapped(_ sender: UIButton) {
        guard let previewURLString = previewURLString, let previewURL = URL(string:previewURLString) else {
            return
        }
        // Open Google Books preview in Safari
        UIApplication.shared.open(previewURL, options: [:], completionHandler: nil)
    }
   }

