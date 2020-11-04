//
//  AntDetailsViewController.swift
//  Cloudy
//
//  Created by Ganesh on 20/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit
import OHMySQL
import AlamofireImage
import Alamofire

class AntDetailsViewController: UIViewController, DatabaseListener {
    
    
    
    //Storyboard elements
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bioNameLabel: UILabel!
    @IBOutlet weak var commonNameLabel: UILabel!
    @IBOutlet weak var antSizeDescriptionLabel: UILabel!
    @IBOutlet weak var antSpinesDescriptionLabel: UILabel!
    @IBOutlet weak var antQueenDescriptionLabel: UILabel!
    @IBOutlet weak var antInvasiveDescriptionLabel: UILabel!
    @IBOutlet weak var sizeView: UIView!
    @IBOutlet weak var spinesView: UIView!
    @IBOutlet weak var queenView: UIView!
    @IBOutlet weak var moreInfoView: UIView!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet var tagCollectionview: UICollectionView!
    @IBOutlet var noTagsFoundLabel: UILabel!
    @IBOutlet weak var favFeedback: UILabel!
    
    
    //Varilable declaration
    var imageSubView: UIImageView = UIImageView()
    var imageCache: AutoPurgingImageCache?
    var triggerDataStore: Bool = false
    var isImageSearch: Bool = false
    var jsonLabels: [String] = []
    var antItem: DBResponse?
    var activity = UIActivityIndicatorView()
    var historyListData: [History] = []
    var historyItem : History?
    weak var databaseController: DatabaseProtocol?
    var listenerType = ListenerType.history
    var antName: String = "Unknown Ant"
    var antNamesList: [DBResponseName] = []
    var response: JSONResponseData?
    var isFromCollections: Bool = false
    var tags: [String] = []
    var fromHistoryView: Bool = false
    var firstLoad: Bool = true
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Getting image cache and database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        imageCache = appDelegate.imageCache
        
        //Activity indicator for the loading screen
        startActivityIndicator()
        
        //Hide all labels unless data is available
        bioNameLabel.isHidden = true
        commonNameLabel.isHidden = true
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
    
        sizeView.setBorders()
        queenView.setBorders()
        spinesView.setBorders()
        moreInfoView.setBorders()
    
        favFeedback.isHidden = true
        favFeedback.layer.cornerRadius = favFeedback.frame.height/3
        favFeedback.layer.masksToBounds = true
        
        sizeView.layer.backgroundColor = UIColor(hex: "C3C355").cgColor
        queenView.layer.backgroundColor = UIColor(hex: "FFF3B0").cgColor
        spinesView.layer.backgroundColor = UIColor(hex: "FFF3B0").cgColor
        moreInfoView.layer.backgroundColor = UIColor(hex: "C3C355").cgColor
        noTagsFoundLabel.isHidden = true
        noTagsFoundLabel.center = tagCollectionview.center
        
        isFavourited()
        
        favouriteButton.isHidden = false
        if(isFromCollections){
            favouriteButton.isHidden = true
        } 
        
        //Load ant names for searching from database
        initDatabase()
        
        //If image searchclean data and then store
        if(isImageSearch){
            self.hideViews(trigger: true, favTrigger: true)
            NotificationCenter.default.addObserver(self, selector: #selector(cleanResponsefromImageSearch), name: NSNotification.Name(rawValue: "loadParsedJSONData"), object: nil)
            
        } else if (triggerDataStore){ //if not image search but feature search, use antItem data
            storetoCoreData(trigger: true)
            self.hideViews(trigger: false, favTrigger: false)

        } else if (fromHistoryView){
            self.hideViews(trigger: false, favTrigger: false)
        } else {
            self.hideViews(trigger: false, favTrigger: true)
        }
        
        let nib = UINib(nibName: AntTagsCollectionViewCell.nibName, bundle: nil)
        tagCollectionview?.register(nib, forCellWithReuseIdentifier: AntTagsCollectionViewCell.reuseIdentifier)
        tagCollectionview.delegate = self
        tagCollectionview.dataSource = self
        
        //Displaying the received data
//        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(hex: "E09F3E"), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold) ]
//        let boldText = "View More"
//        let attributedString = NSMutableAttributedString(string: boldText,attributes: titleTextAttributes)
//        infoButton.setAttributedTitle(attributedString, for: .normal)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        if let flowLayout = tagCollectionview?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
        tagCollectionview.reloadData()
        displayData()

    }
    
    //Database listener....invoked when the database record changes
    func onHistoryListChange(change: DatabaseChange, historyList: [History]) {
        historyListData = historyList
    }
    
    //Adding and removing listeners when view will appear or disappear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    
    //A custom method that takes the input as a notification object from SearchViewController class and cleans the response
    //@returnType:  nil
    //@paramaters:  notification    A Notification object
    @objc func cleanResponsefromImageSearch(notification: Notification)
    {
        var didFindAnt: Bool = false
        guard let data = notification.object as? JSONResponseData else { return }
        
        //Clean data i.e. get all labels from the response (image search response)
        let response = data.responses[0]
        jsonLabels.append(response.webDetection.bestGuessLabels[0].label ?? "None")
        for item in response.labelAnnotations{
            if(item.score! > 0.67){
                jsonLabels.append(item.description!)
            }
        }
        for item in response.webDetection.webEntities{
            jsonLabels.append(item.description ?? "None")
        }
        
        //Cross check if the results in cloud vision response are in antNames list
        var searchResultName: String = ""
        for name in antNamesList{
            for item in jsonLabels{
                if(item == "Ant"){
                    didFindAnt = true
                } else if (item == "ant") {
                    didFindAnt = true
                } else if (item == "ANT"){
                    didFindAnt = true
                }
                if ((item.caseInsensitiveCompare(name.bioName!)) == .orderedSame){
                    searchResultName = item
                }
                else if ((item.caseInsensitiveCompare(name.commonName!)) == .orderedSame){
                    searchResultName = item
                }
            }
        }
        
        //If ant data matches, then get the ant details from database for that match
        
        if searchResultName != ""{
            let user = OHMySQLUser(userName: "antGuideClient", password: "antGuide", serverName: "antdb.cgwmwabypjj0.ap-southeast-2.rds.amazonaws.com", dbName: "new", port: 3306, socket: nil)
            let coordinator = OHMySQLStoreCoordinator(user: user!)
            coordinator.encoding = .UTF8MB4
            coordinator.connect()
            let context = OHMySQLQueryContext()
            context.storeCoordinator = coordinator
            let antDetails = OHMySQLQueryRequestFactory.select("ant1", condition:  "bioName = '\(searchResultName)' OR commonName = '\(searchResultName)'")
            let response = try? context.executeQueryRequestAndFetchResult(antDetails)
            guard let responseObject = response else { return }
            for data in responseObject{
                antItem = DBResponse(with: data)
            }
            self.hideViews(trigger: false, favTrigger: false)
            
        }else{
            //Showing a toast that says that there was no match and to retry
            activity.stopAnimating()
            //commonNameLabel.isHidden = false
            //commonNameLabel.text = "No Ants Recognised"
            let questionView = UIImageView()
            let antView = UIImageView()
            questionView.frame.size = CGSize(width: 100, height: 100)
            antView.frame.size = CGSize(width: 100, height: 100)
            questionView.center = self.view.center
            questionView.frame.origin.y = questionView.frame.origin.y - 50
            antView.center = self.view.center
            antView.frame.origin.y = antView.frame.origin.y - 50
            let label = UILabel()
            label.frame.size = CGSize(width: 200, height: 50)
            label.center = self.view.center
            label.frame.origin.y = label.frame.origin.y + 50
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            self.view.addSubview(antView)
            self.view.addSubview(questionView)
            self.view.addSubview(label)
            let questionImage = UIImage(systemName: "questionmark.circle")!
            questionView.tintColor = UIColor(hex: "E09F3E").withAlphaComponent(0.7)
            questionView.image = questionImage
            let antImage = UIImage(systemName: "ant.circle")!
            antView.tintColor = UIColor.lightGray.withAlphaComponent(0.7)
            antView.image = antImage
            //If there was an ant found but not recognised
            if (didFindAnt){
                label.text = "Ant Not Identified"
                showToast(controller: self, message: "We found an ant but we can't find this ant in Victoria.", seconds: 0, title: "Ant Not Identified")
            } else { //If No ants found
                label.text = "No Ants Recognised"
                showToast(controller: self, message: "Please try again with another image. You can also try \"Search by Features\"", seconds: 0, title: "No Ants Recognised")
            }
            
        }
            
        //If everything occurs as it has to above then the database is triggered to store a history record.
        //It also displays the data on the screen.
        storetoCoreData(trigger: triggerDataStore)
        displayData()

    }
    
    //A method to hide or show the views based on the data
    //@paramaters:  shouldHide      A boolean value to see if we need to hide the views or not
    func hideViews(trigger: Bool, favTrigger: Bool){
        self.spinesView.isHidden = trigger
        self.sizeView.isHidden = trigger
        self.favouriteButton.isHidden = favTrigger
        self.queenView.isHidden = trigger
        self.moreInfoView.isHidden = trigger
        self.infoButton.isHidden = trigger
    }
    
    //A custom method that shows an alert on the screen for user feedback
    //@returnType:  nil
    //@paramaters:  controller      Present View controller
    //@parameters:  message, title  data for the alert
    //@parameters:  seconds:        delay time for the start of alert activity
    func showToast(controller: UIViewController, message : String, seconds: Double, title: String){
        DispatchQueue.main.asyncAfter(deadline: .now()){
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            //alert.view.backgroundColor = .black
            alert.view.alpha = 0.5
            alert.view.layer.cornerRadius = 15
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: self.antNotFoundHandler))
            controller.present(alert, animated: true)
            //self.dismiss(animated: true, completion: nil)
        }
    }
    
    func antNotFoundHandler(alert: UIAlertAction!){
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NoAntFound"), object: nil)

    }
    
    
    //A custom method that sets the environment for the database queries
    //@returnType:  nil
    //@paramaters:  notification    A Notification object
    func initDatabase(){
        
        let user = OHMySQLUser(userName: "antGuideClient", password: "antGuide", serverName: "antdb.cgwmwabypjj0.ap-southeast-2.rds.amazonaws.com", dbName: "new", port: 3306, socket: nil)
        let coordinator = OHMySQLStoreCoordinator(user: user!)
        coordinator.encoding = .UTF8MB4
        coordinator.connect()
        
        let context = OHMySQLQueryContext()
        context.storeCoordinator = coordinator
        
        let antDetails = OHMySQLQueryRequestFactory.select("ant2", condition:  nil)
        let response = try? context.executeQueryRequestAndFetchResult(antDetails)
        guard let responseObject1 = response else { return }
        for data in responseObject1{
            let item = DBResponseName(with: data)
            antNamesList.append(item)
        }
    }
    
    //The method that starts the "Loading data" view
    func startActivityIndicator(){
        activity = UIActivityIndicatorView()
        activity.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 30, y: UIScreen.main.bounds.height / 2 - 30, width: 50, height: 50)
        activity.style = .large
        activity.color = UIColor.lightGray
        self.view.addSubview(activity)
        activity.hidesWhenStopped = true
        activity.startAnimating()
    }
    
    //Trigger the store to the database
    //@parameter:   trigger     A boolean value for extra checks
    func storetoCoreData(trigger: Bool){
        if(trigger){
            if(antItem != nil){
                historyItem = databaseController?.addHistory(antName: (antItem?.commonName)!, date: Date(), favourite: false)
            }
            else{
                print("Need a toast here for user to say no ant found!")
            }
        }
    }
    
    //This method toogles if a ant sighting is favourite or not
    @IBAction func toogleHistoryFavouriteAction(_ sender: Any) {
        if historyItem != nil{
            databaseController?.addOrRemoveFavourites(history: historyItem!, favourite: !(historyItem!.favourite))
        }
        isFavourited()
    }
    
    func showToast(message: String){
    
        self.favFeedback.alpha = 0.0

        UIView.animate(withDuration: 0, delay: 0.0, options: .curveEaseOut, animations: {
            self.favFeedback.isHidden = false
            self.favFeedback.alpha = 0.0
            self.favFeedback.text = message

            }, completion: {
                finished in

                if finished {
                    
                    UIView.animate(withDuration: 0.5, delay: 0.3, options: .curveEaseIn, animations: {
                      self.favFeedback.alpha = 1.0
                        }, completion: {
                            finished in

                            if finished {

                                // Fade in
                                UIView.animate(withDuration: 0.4, delay: 1.6, options: .curveEaseOut, animations: {
                                    self.favFeedback.alpha = 0.0
                                    }, completion: {
                                        finished in

                                        if finished {
                                            self.favFeedback.isHidden = true
                                        }
                                })
                            }
                    })
                }
        })
    
    }
    
    //Method to display the data on to the screen using the storyboard variables
    func displayData(){
        //antName = String((antItem?.commonName)!)
        //_ = databaseController?.addHistory(antName: " ", date: Date(), favourite: false)
        self.view.isHidden = false
        if(antItem != nil){
            
            //Data for number of ant's names and its image
            commonNameLabel.isHidden = false
            bioNameLabel.isHidden = false
            commonNameLabel.text = antItem?.commonName!
            bioNameLabel.text = antItem?.bioName!
            setImageFromUrl(url: (antItem?.image)!, receivedImageView: imageSubView)
            
            //Data for number of ant's size
            antSizeDescriptionLabel.text = "~\(String(describing: antItem!.bodyLength!))"
            
            //Data for number of ant's spines
            if( antItem!.numberOfSpines! == 0 ){
                antSpinesDescriptionLabel.text = "None"
            } else {
                antSpinesDescriptionLabel.text = "\(String(describing: antItem!.numberOfSpines!))"
            }
            
            //Data for number of ant's queens
            if ((antItem?.queenNumber!) == 0){
                antQueenDescriptionLabel.text = "1"
            } else {
                antQueenDescriptionLabel.text = "Many"
            }
            
            if ((antItem?.isInvasive!)!){
                antInvasiveDescriptionLabel.text = "Yes"
            } else {
                antInvasiveDescriptionLabel.text = "No"
            }
            
            for item in antNamesList{
                if(item.bioName == antItem?.bioName){
                    if(item.colorful!){
                        tags.append("Colorful")
                    }
                    if(item.invasive!){
                        tags.append("Invasive")
                    }
                    if(item.helpful!){
                        tags.append("Helpful")
                    }
                    if(item.hazardous!){
                        tags.append("Hazardous")
                    }
                    if(item.gigantic!){
                        tags.append("Gigantic")
                    }
                    if(item.specialDiet!){
                        tags.append("Special Diet")
                    }
                    if(item.stingers!){
                        tags.append("Stingers")
                    }
                    
                    if(tags.count == 0){
                        noTagsFoundLabel.isHidden = false
                    }
                    
                    break
                }
            }
            
            tagCollectionview.reloadData()
            
            activity.stopAnimating()
        }
        
    }
    
    //A method that is called when the additional button is clicked.
    @IBAction func infoButtonClicked(_ sender: Any) {
        
        if(antItem?.details != "" && antItem != nil ){
            
            self.performSegue(withIdentifier: "showAdvDetailsSegue", sender: self)
            //self.performSegue(withIdentifier: "detailsToWebViewSegue", sender: self)
        }
        else{
            showToast(controller: self, message: "There is presently no additional Information available for this ant species.", seconds: 0, title: "No Information Available")
        }
    }
    
    //Override method for performing a segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is AdvAntDetailsViewController
        {
            let viewController = segue.destination as? AdvAntDetailsViewController
            viewController?.antItem = antItem
        }
    }
    
//    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
//        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
//    }
//
//    func downloadImage(from url: URL) {
//        print("Download Started")
//        getData(from: url) { data, response, error in
//            guard let data = data, error == nil else { return }
//            print(response?.suggestedFilename ?? url.lastPathComponent)
//            print("Download Finished")
//            let downloadedImage = UIImage(data: data)?.crop(to: CGSize(width: 250, height: 250))
//            DispatchQueue.main.async() {
//                self.imageView.image = downloadedImage
//                self.imageView.layer.cornerRadius = 125
//            }
//        }
//    }

}

//An Extension to download data from internet and store it in phone's cache
extension AntDetailsViewController{
    
    
    //A custom method that sets the image to a given imageView
    //@paramaters:  url                  A link to the ant's image
    //@paramaters:  receivedImageView    A view to place the dowloaded image in

    func setImageFromUrl(url: String, receivedImageView: UIImageView){
        
        //If image in cache just set the image else download it and then set it in the image
        let urlRequest = URLRequest(url: URL(string: url)!)
        let filemanager = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = filemanager.appendingPathComponent("\(String(describing: antItem!.bioName!)).jpg")
        if (FileManager.default.fileExists(atPath: path.path)){
            imageView.contentMode = .scaleToFill
            imageView.image = UIImage().getImage(imagePath: path)//.crop(to: CGSize(width: 350, height: 264))
            imageView.layer.cornerRadius = 40
        }
//        if let image = imageCache!.image(withIdentifier: String(describing: urlRequest))
//        {
//            imageView.image = image.crop(to: CGSize(width: 350, height: 264))
//            imageView.layer.cornerRadius = 40
//            if (image.size.width > image.size.height){
//                let height = UIScreen.main.bounds.width * 4 / 5 * image.size.height / image.size.width
//                receivedImageView.image = image.crop(to: CGSize(width: UIScreen.main.bounds.width * 4 / 5, height: height))
//            }
//
//            if (receivedImageView.image != nil){
//                let point = CGPoint( x: receivedImageView.frame.origin.x, y: receivedImageView.frame.origin.y)
//                let height = UIScreen.main.bounds.width * 4 / 5 * (imageView.image?.size.height)! / (receivedImageView.image?.size.width)!
//                let size = CGSize(width: (receivedImageView.image?.size.width)!, height: height)
//                receivedImageView.frame =  CGRect(origin: point, size: size)
//            }
//
//
//        }
        else {
            Alamofire.request(urlRequest).responseImage { response in
                            if response.result.value != nil {
                                let image = UIImage(data: response.data!, scale: 1.0)!
                                image.saveToDocuments(filename: "\(String(describing: self.antItem?.bioName!)).jpg")

                            }
            }
        }
    }
    
    //A custom method that sets the image to a given imageView after download
    //@paramaters:  url                  A link to the ant's image
    //@paramaters:  receivedImageView    A view to place the dowloaded image in
    func setImageFromCache(urlRequest: URLRequest, receivedImageView: UIImageView){
        if let image = imageCache!.image(withIdentifier: String(describing: urlRequest))
        {
            let filemanager = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let path = filemanager.appendingPathComponent("\(String(describing: antItem!.bioName!)).jpg")
            if (FileManager.default.fileExists(atPath: path.path)){
                imageView.contentMode = .scaleToFill
                imageView.image = UIImage().getImage(imagePath: path)//.crop(to: CGSize(width: 350, height: 264))
                imageView.layer.cornerRadius = 40
            }
            
            //imagePlaceholderView.layer.cornerRadius = 35
        }
    }
    
    //A method that changes the iew of the favourite button when called
    func isFavourited(){
        if (historyItem != nil) {
            if (historyItem!.favourite){
                if(!firstLoad){
                    self.showToast(message: "Search Favourited")
                }
                self.favouriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                if(!firstLoad){
                    self.showToast(message: "Search Unfavourited")
                }
                self.favouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
        }
        firstLoad = false
    }
}

//Setting shadows to any view
extension UIView{
    func setShadows(){
        self.layer.cornerRadius = 15
        self.layer.shadowOpacity = 1
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = .init(width: 5, height: 5)
        self.layer.shadowRadius = 3
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
        //self.layer.backgroundColor = UIColor(hex: "FFF3B0").cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
    }
    
    func setBorders(){
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 0.01
    }
}

//MARK:- COllection View Delegates

extension AntDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = tagCollectionview.dequeueReusableCell(withReuseIdentifier: AntTagsCollectionViewCell.reuseIdentifier, for: indexPath) as? AntTagsCollectionViewCell {
            cell.configureCell(tag: tags[indexPath.row], color: getColorHex(tag: tags[indexPath.row]))
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let totalCellWidth = 110 * collectionView.numberOfItems(inSection: 0)
        let totalSpacingWidth = 10 * (collectionView.numberOfItems(inSection: 0) - 1)

        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)

    }
    
    //A method that returns a hex color for a category
    func getColorHex(tag: String) -> String{
        switch tag {
            case "Colorful":
                return "clear"
            case "Invasive":
                return "F8961E"
            case "Helpful":
                return "90BE6D"
            case "Hazardous":
                return "F94144"
            case "Gigantic":
                return "F9C74F"
            case "Special Diet":
                return "43AA8B"
            case "Stingers":
                return "F3722C"
            default:
                break
        }
        return "clear"
    }
    
    
}
