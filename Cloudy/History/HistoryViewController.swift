//
//  HistoryViewController.swift
//  Cloudy
//
//  Created by Ganesh on 19/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit
import OHMySQL
import ViewAnimator


class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DatabaseListener {
    

    //Valiable declaration
    var historyListData: [History] = []
    var filteredHistoryListData: [History] = []
    var historyItem: History?
    weak var databaseController: DatabaseProtocol?
    var listenerType = ListenerType.history
    var isFavouriteSelected: Bool = false
    var selectedItem: DBResponse?
    var starImage: UIImage = UIImage()
    var starFillImage: UIImage = UIImage()
    var antNamesList: [DBResponse] = []
    var didViewLoad: Bool = false
    let buttonBar = UIView()
    private let animations = [AnimationType.from(direction: .left, offset: UIScreen.main.bounds.width)]

    
    //Storyboard elements
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var favouriteButton: UIBarButtonItem!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var favFeedback: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //delegate methods to get data from the database controller
        historyTableView.delegate = self
        historyTableView.dataSource = self
        historyTableView.rowHeight = 80
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        historyTableView.register(nib, forCellReuseIdentifier: "favouriteCell")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        starImage = UIImage(data: resizeImage(CGSize(width: 25, height: 25), image: UIImage(named: "star")!))!
        starFillImage = UIImage(data: resizeImage(CGSize(width: 25, height: 25), image: UIImage(named: "starFill")!))!
        initDatabase()
        favFeedback.isHidden = true
        favFeedback.layer.cornerRadius = favFeedback.frame.height/3
        favFeedback.layer.masksToBounds = true

        
        //Animating the segments
        if #available(iOS 13.0, *) {
            segmentedControl.backgroundColor = .clear
            segmentedControl.layer.backgroundColor = UIColor.clear.cgColor
            segmentedControl.layer.borderColor = UIColor.clear.cgColor
            segmentedControl.selectedSegmentTintColor = UIColor.white
            segmentedControl.layer.borderWidth = 1
            let bg = UIImage(ciImage: .clear)
            let sBg = UIImage(ciImage: .white)
            segmentedControl.setBackgroundImage(bg, for: .normal, barMetrics: .default)
            segmentedControl.setBackgroundImage(sBg, for: .selected, barMetrics: .default)
            segmentedControl.setDividerImage(UIImage.init(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
            let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17) ]
            segmentedControl.setTitleTextAttributes(titleTextAttributes, for:.normal)

            let titleTextAttributes1 = [NSAttributedString.Key.foregroundColor: UIColor(hex: "E09F3E"), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold)]
            segmentedControl.setTitleTextAttributes(titleTextAttributes1, for:.selected)
            
            buttonBar.translatesAutoresizingMaskIntoConstraints = false
            buttonBar.backgroundColor = UIColor(hex: "E09F3E")
           
            view.addSubview(buttonBar)
            buttonBar.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor).isActive = true
            buttonBar.heightAnchor.constraint(equalToConstant: 5).isActive = true
            buttonBar.leftAnchor.constraint(equalTo: segmentedControl.leftAnchor).isActive = true
            buttonBar.widthAnchor.constraint(equalTo: segmentedControl.widthAnchor, multiplier: 1 / CGFloat(segmentedControl.numberOfSegments)).isActive = true

          } else {
                      // Fallback on earlier versions
        }
        self.view.backgroundColor = .white
        segmentedControl.selectedSegmentTintColor = UIColor.white
        //showToast(controller: self, message: "Swipe from right to left on a row to Favourite/Unfavourite", seconds: 4)
        //loadData()
    }
    
    //A custom method that sets the image to a given imageView after download
    //@paramaters:  controller      A link to the ant's image
    //@paramaters:  message         A view to place the dowloaded image in
    //@parameters:  seconds         Delay for the meesage to be showed
    func showToast(controller: UIViewController, message : String, seconds: Double){
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
            let alert = UIAlertController(title: "Adding to Favourites", message: message, preferredStyle: .alert)
            //alert.view.backgroundColor = .black
            alert.view.alpha = 0.5
            alert.view.layer.cornerRadius = 15
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            controller.present(alert, animated: true)
        }
    }
    
    //A custom method to set the environment for using the database
    func initDatabase(){
        let user = OHMySQLUser(userName: "antGuideClient", password: "antGuide", serverName: "antdb.cgwmwabypjj0.ap-southeast-2.rds.amazonaws.com", dbName: "new", port: 3306, socket: nil)
        let coordinator = OHMySQLStoreCoordinator(user: user!)
        coordinator.encoding = .UTF8MB4
        coordinator.connect()
        
        let context = OHMySQLQueryContext()
        context.storeCoordinator = coordinator
        
        let antDetails = OHMySQLQueryRequestFactory.select("ant1", condition:  nil)
        let response = try? context.executeQueryRequestAndFetchResult(antDetails)
        guard let responseObject1 = response else { return }
        for data in responseObject1{
            let item = DBResponse(with: data)
            antNamesList.append(item)
        }
        
        
    }
    //A method to show favourites or all data from the history
    @IBAction func segmentedControlChanged(_ sender: Any) {
        filteredHistoryListData = []
        switch segmentedControl.selectedSegmentIndex
        {
            case 0:
                filteredHistoryListData = historyListData
                self.navigationItem.title = "Search History"
            case 1:
                for item in historyListData{
                    if (item.favourite){
                        filteredHistoryListData.append(item)
                    }
                }
                self.navigationItem.title = "Favourite Searches"

            default:
                    
                break
        }
        segmentedControl.selectedSegmentTintColor = UIColor.white
        filteredHistoryListData = filteredHistoryListData.sorted(by: { $0.date!.compare($1.date!) == .orderedDescending })
        historyTableView.reloadData()
        UIView.animate(views: historyTableView.visibleCells, animations: animations, completion: nil)
        UIView.animate(withDuration: 0.3) {
        self.buttonBar.frame.origin.x = (self.segmentedControl.frame.width / CGFloat(self.segmentedControl.numberOfSegments)) * CGFloat(self.segmentedControl.selectedSegmentIndex)
        }
          
    }
    
//    //A custom method that sets the image to a given imageView after download
//    func loadData (){
//        _ = databaseController?.addHistory(antName: "Name 1", date: Date(), favourite: false)
//        _ = databaseController?.addHistory(antName: "Name 2", date: Date.init(), favourite: false)
//        _ = databaseController?.addHistory(antName: "Name 3", date: Date.init(), favourite: false)
//    }

    
//
//    func filterTableData(){
//        filteredHistoryListData = []
//        if (isFavouriteSelected) {
//            for item in historyListData{
//                if (item.favourite){
//                    filteredHistoryListData.append(item)
//                }
//            }
//        }
//        else{
//            filteredHistoryListData = historyListData
//        }
//
//        filteredHistoryListData = filteredHistoryListData.sorted(by: { $0.date!.compare($1.date!) == .orderedDescending })
//
//    }

    //A delegate method for the database change for history records
    func onHistoryListChange(change: DatabaseChange, historyList: [History]) {
        historyListData = historyList
        filteredHistoryListData = historyListData
        segmentedControlChanged(self)
        if(!didViewLoad){
            UIView.animate(views: historyTableView.visibleCells, animations: animations, completion: nil)
            didViewLoad = true
        }
    }
    
     //Methods for adding and removing the database listeerners when the view will load and will disappear.
     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         databaseController?.addListener(listener: self)
     }

     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         didViewLoad = false
         databaseController?.removeListener(listener: self)
     }

    //MARK:- Tableview delegates
     //Tableview delegate methods and datasource methods.
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return filteredHistoryListData.count
     }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let verticalPadding: CGFloat = 8

        let maskLayer = CALayer()
        cell.backgroundColor = UIColor.white
        maskLayer.cornerRadius = 10    //if you want round edges
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.mask = maskLayer
    }
    
//    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
//        tableView.subviews.forEach { subview in
//            if (String(describing: type(of: subview)) == "UISwipeActionPullView") {
//                if (String(describing: type(of: subview.subviews[0])) == "UISwipeActionStandardButton") {
//                    subview.subviews[0].bounds = subview.subviews[0].frame.insetBy(dx: 0, dy: 10)
//                    subview.subviews[0].layer.cornerRadius = 10
//                    subview.subviews[0].clipsToBounds = true
//                }
//            }
//        }
//    }
//
//    //Trailing swipe method definitions for a cell in table view to add or remove favourites.
//    @available(iOS 11.0, *)
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        var title = ""
//        var color = UIColor.yellow
//        if(self.filteredHistoryListData[indexPath.row].favourite){
//            title = "Unfavourite"
//            color = UIColor(hex: "9E2A2B")
//        } else {
//            title = "Favourite"
//            color = UIColor(hex: "E09F3E")
//            //UIColor(red: 210/255, green: 162/255, blue: 49/255, alpha: 1)
//        }
//        let favourite = UIContextualAction(style: .normal, title: title) { _, _, complete in
//            let tempList = self.filteredHistoryListData
//            self.databaseController?.addOrRemoveFavourites(history: tempList[indexPath.row], favourite: !tempList[indexPath.row].favourite)
//            complete(true)
//            if(self.segmentedControl.selectedSegmentIndex != 0){
//                self.segmentedControl.selectedSegmentIndex = 0
//                self.segmentedControlChanged(self.segmentedControl as Any)
//            }
//
//        }
//        favourite.backgroundColor = color
//        let configuration = UISwipeActionsConfiguration(actions: [favourite])
//        configuration.performsFirstActionWithFullSwipe = true
//        return configuration
//    }
//    //A table view method for allowing editing of table view contents
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    //A custom method that allows editing of the cell of table view
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let favourite = UITableViewRowAction(style: .normal, title: "Favourite") { _, _ in
////            let tempList = self.filteredHistoryListData
////            self.databaseController?.addOrRemoveFavourites(history: tempList[indexPath.row], favourite: !tempList[indexPath.row].favourite)
//        }
//        favourite.backgroundColor = .yellow
//        return [favourite]
//    }
    
     //A table view data source method to load data into the table
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favouriteCell", for: indexPath) as! TableViewCell
        let date = String(describing: filteredHistoryListData[indexPath.row].date!).components(separatedBy: "+")
        cell.favButtonToggle = {
            //self.favFeedback.layer.removeAllAnimations()
            if(!self.filteredHistoryListData[indexPath.row].favourite){
                self.showToast(message: "Search Favourited")
            } else {
                self.showToast(message: "Search Unfavourited")
            }
            self.databaseController?.addOrRemoveFavourites(history: self.filteredHistoryListData[indexPath.row], favourite: !self.filteredHistoryListData[indexPath.row].favourite)
            
            if(self.segmentedControl.selectedSegmentIndex == 1){
                //self.segmentedControl.selectedSegmentIndex = 0
                self.segmentedControlChanged(self)
            }
        }
        cell.commInit(antName: filteredHistoryListData[indexPath.row].antName!, date: date[0], isFavourite: self.filteredHistoryListData[indexPath.row].favourite)
        
        return cell
     }
    
    //A method for allowing taps on the cells of the table view to view the ant's data related to the cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for data in antNamesList{
            
            //Cross check the data from database and forward to ant's details
            if data.commonName == filteredHistoryListData[indexPath.row].antName!{
                let user = OHMySQLUser(userName: "antGuideClient", password: "antGuide", serverName: "antdb.cgwmwabypjj0.ap-southeast-2.rds.amazonaws.com", dbName: "new", port: 3306, socket: nil)
                let coordinator = OHMySQLStoreCoordinator(user: user!)
                coordinator.encoding = .UTF8MB4
                coordinator.connect()
                let context = OHMySQLQueryContext()
                context.storeCoordinator = coordinator
                let antDetails = OHMySQLQueryRequestFactory.select("ant1", condition:  "commonName = '\(data.commonName!)'")
                let response = try? context.executeQueryRequestAndFetchResult(antDetails)
                guard let responseObject = response else { return }
                for data in responseObject{
                    selectedItem = DBResponse(with: data)
                }
                historyItem = filteredHistoryListData[indexPath.row]
                performSegue(withIdentifier: "showHistoryDetailsSegue", sender: self)
            }
        }
    }
    
    func showToast(message: String){
    
        UIView.animate(withDuration: 0, delay: 0.0, options: .curveEaseOut, animations: {
            self.favFeedback.isHidden = false
            self.favFeedback.text = message

            self.favFeedback.alpha = 0.0
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

    //A overridden method for segues
    //@paramaters:  for segue              A storyboard segue
    //@paramaters:  sender                 object that is sending the values to it
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AntDetailsViewController
        {
            let viewController = segue.destination as? AntDetailsViewController
                viewController?.antItem = self.selectedItem
                viewController?.triggerDataStore = false
                viewController?.isImageSearch = false
                viewController?.historyItem = historyItem
                viewController?.fromHistoryView = true
        }
    }
    
    //A custom method that resizes an images without cropping as a scale to fill aspect
    //@paramaters:  imageSize              The required size of the image
    //@paramaters:  image                  An image object
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = newImage!.pngData()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    
    //MARK:- Swipe gestures
    @IBAction func handleLeftSwipe(_ gesture: UISwipeGestureRecognizer) {
        self.segmentedControl.selectedSegmentIndex = 1
        segmentedControlChanged(segmentedControl as Any)
    }
    
    @IBAction func handleRightSwipe(_ gesture: UISwipeGestureRecognizer) {
        self.segmentedControl.selectedSegmentIndex = 0
        segmentedControlChanged(segmentedControl as Any)
    }

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
