//
//  RSSFeedViewController.swift
//  Cloudy
//
//  Created by Ganesh on 19/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

//  slave by Adrien Coquet from the Noun Project https://thenounproject.com/term/slavery/2085902/

import UIKit
import AlamofireRSSParser
import Alamofire
import CollectionViewPagingLayout
import SnapLikeCollectionView


public protocol SnapLikeSelectDelegate: class  {
    func selectCell(_ index: Int)
}


class RSSFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //Variable declaration
    var rssFeedList: [RSSItem] = []
    var rssItemToPass: String?
    let url = "https://blog.myrmecologicalnews.org/feed/"
    //let url = "https://www.sciencedaily.com/rss/top/science.xml"
    let buttonBar = UIView()
    var previousSelctedCell = -1
    private var dataSource: SnapLikeDataSource<GenericAntInfoCollectionViewCell>?
    var isInfoViewPresented: Bool = true
    var separatorView: UIView?
    var timerForShowScrollIndicator: Timer?
    var isNewsViewVisible: Bool = true
    weak var delegate: SnapLikeSelectDelegate?
    //Storyboard elements
    @IBOutlet var rightArrowIndicator: UIButton!
    @IBOutlet var leftArrowIndicator: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var rssFeedTableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet var informationViewLabel: UILabel!
    @IBOutlet weak var informationPlaceholderView: UIView!
    @IBOutlet var previousInformationViewLabel: UILabel!
    @IBOutlet weak var previousInformationPlaceholderview: UIView!
    @IBOutlet var informationViewTitleLabel: UILabel!
    @IBOutlet var previousInformationViewTitleLabel: UILabel!
    @IBOutlet var segmentSeparatorView: UIView!
    
    //Ovverride methos for initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        

        rssFeedTableView.dataSource = self
        rssFeedTableView.delegate = self
        rssFeedTableView.rowHeight = 100
        segmentControl.selectedSegmentIndex = 0
        informationPlaceholderView.isHidden = true
        informationPlaceholderView.layer.cornerRadius = 50
        previousInformationPlaceholderview.isHidden = true
        previousInformationPlaceholderview.layer.cornerRadius = 50
        separatorView = UIView()
        separatorView?.frame = CGRect(x: 0, y: rssFeedTableView.frame.origin.y - 1, width: UIScreen.main.bounds.width, height: 1)
        self.view.backgroundColor = .white
        self.view.addSubview(separatorView!)
        segmentSeparatorView.frame.size = CGSize(width: segmentControl.frame.size.width/CGFloat(segmentControl.numberOfSegments), height: 5)
        self.segmentSeparatorView.backgroundColor = UIColor(hex: "E09F3E")
        rightArrowIndicator.isHidden = true
        leftArrowIndicator.isHidden = true
//        segmentControl.backgroundColor = .clear
//        segmentControl.tintColor = .clear
//        segmentControl.setTitleTextAttributes([
//            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17),
//            NSAttributedString.Key.foregroundColor: UIColor.lightGray ], for: .normal)
//        segmentControl.setTitleTextAttributes([
//            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17),
//            NSAttributedString.Key.foregroundColor: UIColor(hex: "E09F3E") ], for: .selected)
        
        //customise the segment control at the top
        if #available(iOS 13.0, *) {
            segmentControl.backgroundColor = .clear
            segmentControl.layer.backgroundColor = UIColor.clear.cgColor
            segmentControl.layer.borderColor = UIColor.clear.cgColor
            segmentControl.selectedSegmentTintColor = UIColor.clear
            segmentControl.layer.borderWidth = 1
            let bg = UIImage(ciImage: .clear)
            segmentControl.setBackgroundImage(bg, for: .normal, barMetrics: .default)
            segmentControl.setBackgroundImage(bg, for: .selected, barMetrics: .default)
            //segmentControl.setDividerImage(bg, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
//            segmentControl.setDividerImage(bg, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
            segmentControl.setDividerImage(UIImage.init(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
            let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17) ]
            segmentControl.setTitleTextAttributes(titleTextAttributes, for:.normal)

            let titleTextAttributes1 = [NSAttributedString.Key.foregroundColor: UIColor(hex: "E09F3E"), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold)]
            segmentControl.setTitleTextAttributes(titleTextAttributes1, for:.selected)
            buttonBar.translatesAutoresizingMaskIntoConstraints = false
            buttonBar.backgroundColor = UIColor(hex: "E09F3E")
            
           
            view.addSubview(buttonBar)
            buttonBar.isHidden = true
            buttonBar.topAnchor.constraint(equalTo: segmentControl.bottomAnchor).isActive = true
            buttonBar.heightAnchor.constraint(equalToConstant: 5).isActive = true
            buttonBar.leftAnchor.constraint(equalTo: segmentControl.leftAnchor).isActive = true
            buttonBar.widthAnchor.constraint(equalTo: segmentControl.widthAnchor, multiplier: 1 / CGFloat(segmentControl.numberOfSegments)).isActive = true
            segmentSeparatorView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor).isActive = true
            segmentSeparatorView.heightAnchor.constraint(equalToConstant: 5).isActive = true
            segmentSeparatorView.leftAnchor.constraint(equalTo: segmentControl.leftAnchor).isActive = true
            segmentSeparatorView.widthAnchor.constraint(equalTo: segmentControl.widthAnchor, multiplier: 1 / CGFloat(segmentControl.numberOfSegments)).isActive = true

            self.buttonBar.frame.origin.x = (self.segmentControl.frame.width / CGFloat(self.segmentControl.numberOfSegments)) * CGFloat(self.segmentControl.selectedSegmentIndex)
            self.segmentSeparatorView.frame.origin.x = (self.segmentControl.frame.width / CGFloat(self.segmentControl.numberOfSegments)) * CGFloat(self.segmentControl.selectedSegmentIndex)
            let view = UIView()
            view.frame = CGRect(x: 0, y: rssFeedTableView.frame.origin.y - 1 , width: UIScreen.main.bounds.width, height: 1)
            view.backgroundColor = UIColor(hex: "46230D")
            
          } else {
                      // Fallback on earlier versions
        }
           
        
        let cellSize = SnapLikeCellSize(normalWidth: 80, centerWidth: 130)
        dataSource = SnapLikeDataSource<GenericAntInfoCollectionViewCell>(collectionView: collectionView, cellSize: cellSize)
        dataSource?.delegate = self
        
        
        //colletionview setup
        let layout = SnapLikeCollectionViewFlowLayout(cellSize: cellSize)
        collectionView.collectionViewLayout = layout
        let collectionViewNib = UINib(nibName: GenericAntInfoCollectionViewCell.nibName, bundle: nil)
        collectionView.register(collectionViewNib, forCellWithReuseIdentifier: GenericAntInfoCollectionViewCell.reuseIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.backgroundColor = .white
        
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        dataSource?.items = ["farm", "slave", "swim", "habitat", "strength", "old", "dinosaur", "various", "asexual", "blindDeaf"]
        collectionView.isHidden = true
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y)
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        segmentControl.isUserInteractionEnabled = false
        rssFeedTableView.isHidden = true
        let nib = UINib(nibName: "RssFeedFirstTableViewCell", bundle: nil)
        rssFeedTableView.register(nib, forCellReuseIdentifier: "rssFeedFirstCell")
        //let url = "http://feeds.foxnews.com/foxnews/latest?format=xml"
        //let url = "https://www.reddit.com/r/all/.rss"
        
        //RSS feed Parsers
        informationViewLabel.attributedText = getInformationText(name: "1")
        informationViewTitleLabel.text = getInformationTitleText(name: "1")
        Alamofire.request(url).responseRSS() { (response) -> Void in
            if let feed: RSSFeed = response.value {
                /// Do something with your new RSSFeed object!
                for item in feed.items {
                    self.rssFeedList.append(item)
                    self.rssFeedTableView.reloadData()
                    self.separatorView!.backgroundColor = UIColor.clear
                    activityIndicator.stopAnimating()
                    self.rssFeedTableView.isHidden = false
                    self.segmentControl.isUserInteractionEnabled = true

                }
            }
        }
        rssFeedTableView.reloadData()
        //collectionView.reloadData()
        selectCollectionItem(item: 0)
        previousSelctedCell = 0
        // Do any additional setup after loading the view.
    }
    
    //A method that sets the colletion to have the starting item selected
    func selectCollectionItem(item: Int){
        dataSource?.collectionView(collectionView, didSelectItemAt: IndexPath(item: item, section: 0))
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cellSelectionChanged"), object: nil)
    }

    
    override func viewDidAppear(_ animated: Bool) {
        self.timerForShowScrollIndicator = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.animateTheSeparator), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.timerForShowScrollIndicator?.invalidate()
        self.timerForShowScrollIndicator = nil
    }
    
    @objc func animateTheSeparator() {
            self.buttonBar.frame.origin.x = (self.segmentControl.frame.width / CGFloat(self.segmentControl.numberOfSegments)) * CGFloat(self.segmentControl.selectedSegmentIndex)
    }
    
    // This method is to reinitialize  the view
    override func viewWillAppear(_ animated: Bool) {
        
        //RSS feed Parser
        Alamofire.request(url).responseRSS() { (response) -> Void in
            if let feed: RSSFeed = response.value {
                /// Do something with your new RSSFeed object!
                for item in feed.items {
                    self.rssFeedList.append(item)
                    self.rssFeedTableView.reloadData()
                }
            }
        }
        rssFeedTableView.reloadData()
        selectCollectionItem(item: 0)
        previousSelctedCell = 0
    }
    
    @IBAction func leftButtonClicked(_ sender: Any) {
        if(previousSelctedCell != 0 ){
            previousSelctedCell = previousSelctedCell - 1
            dataSource?.collectionView(collectionView, didSelectItemAt: IndexPath(item: previousSelctedCell, section: 0))
            self.updateViewWithNewInformationData(name: "\(previousSelctedCell + 1)", isSelectedIndexBigger: false)
        }
    }
    
    @IBAction func rightButtonClicked(_ sender: Any) {
        if(previousSelctedCell != 9 ){
            previousSelctedCell = previousSelctedCell + 1
            dataSource?.collectionView(collectionView, didSelectItemAt: IndexPath(item: previousSelctedCell, section: 0))
            self.updateViewWithNewInformationData(name: "\(previousSelctedCell + 1)", isSelectedIndexBigger: true)
        }
    }
    
    //MARK:- Table View Delegates

    //methods definitions for a cell in table view of count number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rssFeedList.count
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
    
    //A table view data source method to load data into the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?

        //set ants as image for the records when there is no image provided.
        var image = UIImage()
        if rssFeedList[indexPath.row].mediaThumbnail != nil{
            let url = NSURL(string: rssFeedList[indexPath.row].mediaThumbnail!)
            let data = NSData(contentsOf:url! as URL)
            if data != nil {
                image = UIImage(data:data! as Data)!
            } else {
                image = UIImage(systemName: "ant.circle")!.crop(to: CGSize(width: 30, height: 30))
                
            }
        } else {
            image = UIImage(systemName: "ant.circle")!.crop(to: CGSize(width: 30, height: 30))
        }
        
        //confugiring the cell with data
        if (indexPath.row == 0){
            cell = tableView.dequeueReusableCell(withIdentifier: "rssFeedFirstCell", for: indexPath) as! RssFeedFirstTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "rssFeedCell", for: indexPath)
            cell?.textLabel?.text = rssFeedList[indexPath.row - 1].title
            cell?.imageView!.clipsToBounds = true
            //let tempdate = String(describing: date).components(separatedBy: "+")
            cell?.imageView?.image = image
            cell?.imageView?.tintColor = .lightGray
            cell?.imageView?.frame.size = CGSize(width: 50, height: 50)
        }
        
        return cell!
            
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 300
        } else {
            return 100
        }
    }
    
   // A method for allowing user interaction for the cells of the table view to view the RSS Feed data
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            rssItemToPass = "https://www.sciencemag.org/news/2019/12/how-ants-walking-backward-find-their-way-home"
        } else {
            rssItemToPass = rssFeedList[indexPath.row - 1].link
        }
        self.performSegue(withIdentifier: "rssFeedSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is RSSFeedResultsViewController
        {
            let viewController = segue.destination as? RSSFeedResultsViewController
            viewController?.rssItemURL = rssItemToPass!
        }
    }
    
    //A method to resize an image based on scaleToFill content mode
   //@paramaters:  image              the image
   //@paramaters:  imagSize                The size of images
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> UIImage {
        
        let scale = CGFloat(max(imageSize.width/image.size.width,
                                imageSize.height/image.size.height))
        let width:  CGFloat = image.size.width * scale
        let height: CGFloat = image.size.height * scale;

        let rectangle :CGRect = CGRect(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0);
        image.draw(in: rectangle)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();

//        UIGraphicsBeginImageContext(imageSize)
//        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
//        newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    //MARK:- User Input methods
    @IBAction func selectedSegmentChanged(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex
        {
            case 0:
                
                separatorView!.backgroundColor = UIColor.clear//UIColor(hex: "46230D")
                self.rssFeedTableView.isHidden = false
                self.rssFeedTableView.reloadData()
                self.navigationItem.title = "Ant News"
                self.informationPlaceholderView.isHidden = true
                self.previousInformationPlaceholderview.isHidden = true
                self.rightArrowIndicator.isHidden = true
                self.leftArrowIndicator.isHidden = true
                self.collectionView.isHidden = true
                UIView.animate(withDuration: 0.3) {
                    self.segmentSeparatorView.frame.origin.x = (self.segmentControl.frame.width / CGFloat(self.segmentControl.numberOfSegments)) * CGFloat(self.segmentControl.selectedSegmentIndex)
                    
                }
                
            case 1:
                separatorView!.backgroundColor = UIColor(hex: "EFEFEF")
                separatorView!.frame.size.height = 4
                self.rssFeedTableView.isHidden = true
                self.navigationItem.title = "Ant Facts"
                self.collectionView.isHidden = false
                if(previousSelctedCell == -1 || previousSelctedCell == 0){
                    leftArrowIndicator.isHidden = true
                    rightArrowIndicator.isHidden = false
                } else if(previousSelctedCell == 9){
                    leftArrowIndicator.isHidden = false
                    rightArrowIndicator.isHidden = true
                } else if(previousSelctedCell > 0 && previousSelctedCell < 9){
                    leftArrowIndicator.isHidden = false
                    rightArrowIndicator.isHidden = false
                }
                self.informationPlaceholderView.isHidden = false
                self.previousInformationPlaceholderview.isHidden = false
                self.view.backgroundColor = .white
                UIView.animate(withDuration: 0.3) {
                    self.segmentSeparatorView.frame.origin.x = (self.segmentControl.frame.width / CGFloat(self.segmentControl.numberOfSegments)) * CGFloat(self.segmentControl.selectedSegmentIndex)
                    
            }
            default:
                break
        }
        
    }
    
    
    @IBAction func handleLeftSwipe(_ gesture: UISwipeGestureRecognizer) {
        self.segmentControl.selectedSegmentIndex = 1
        selectedSegmentChanged(segmentControl as Any)
            }
    
    @IBAction func handleRightSwipe(_ gesture: UISwipeGestureRecognizer) {
        self.segmentControl.selectedSegmentIndex = 0
        selectedSegmentChanged(segmentControl as Any)
            }
}

//MARK:- Colletionview delegates and card setup
extension RSSFeedViewController: SnapLikeDataDelegate {
    func cellSelected(_ index: Int) {
        if(segmentControl.selectedSegmentIndex == 1){
            if(index == 0){
                leftArrowIndicator.isHidden = true
                rightArrowIndicator.isHidden = false
            } else if(index == 9){
                leftArrowIndicator.isHidden = false
                rightArrowIndicator.isHidden = true
            } else if(index > 0 && index < 9){
                leftArrowIndicator.isHidden = false
                rightArrowIndicator.isHidden = false
            }
        }
        DispatchQueue.main.async { [weak self] in
            let selectedItem: String = self?.dataSource?.items[index] ?? ""
            let segmentWidth = (self?.segmentControl.frame.width)! / CGFloat(self!.segmentControl.numberOfSegments)
            self?.buttonBar.frame.origin.x = segmentWidth * CGFloat(self!.segmentControl.selectedSegmentIndex)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cellSelectionChanged"), object: nil)
            if(self!.previousSelctedCell != index){
                self!.updateViewWithNewInformationData(name: "\(index + 1)", isSelectedIndexBigger: (self!.previousSelctedCell < index))
                self!.previousSelctedCell = index
            }
            
            
//            if(self!.previousSelctedCell != index){
//
//                let originViewX = self!.informationPlaceholderView.frame.origin.x
//                UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.init(), animations: {
//                    self!.previousInformationPlaceholderview.frame.origin.x = originViewX
//                }, completion: nil)
//
//                UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.init(), animations: {
//                    self!.informationPlaceholderView.frame.origin.x = -UIScreen.main.bounds.width
//                }, completion: nil)
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
//                    self!.previousSelctedCell = index
//                    self!.informationPlaceholderView.frame.origin.x = UIScreen.main.bounds.width
//                    let temp = self!.informationPlaceholderView
//                    self!.informationPlaceholderView = self!.previousInformationPlaceholderview
//                    self!.previousInformationPlaceholderview = temp
//                })
//            }
            
        }
    }
    
    //A method that can update the information for the card to be presented
    //@paramaters:  name                        category name
    //@paramaters:  isSelectedIndexBigger       if the selected cell is on left or right side
    func updateViewWithNewInformationData(name: String, isSelectedIndexBigger: Bool){

        previousInformationPlaceholderview.backgroundColor = UIColor(hex: "FFF3B0")
        informationPlaceholderView.backgroundColor = UIColor(hex: "C3C355")
        
        //If view1 is on screen and view2 is hidden
        if (isInfoViewPresented){
            //previousInformationViewLabel.text = getInformationText(name: name)
            previousInformationViewLabel.attributedText = getInformationText(name: name)
            previousInformationViewTitleLabel.text = getInformationTitleText(name: name)
            
            if(isSelectedIndexBigger){
                infoPresentedAndRightMovement()
            } else {
                infoPresentedAndLeftMovement()
            }
//            self.previousInformationPlaceholderview.frame.origin.x = UIScreen.main.bounds.width
//            let originViewX = self.informationPlaceholderView.frame.origin.x
//            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.init(), animations: {
//                self.previousInformationPlaceholderview.frame.origin.x = originViewX
//            }, completion: nil)
//
//            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.init(), animations: {
//                self.informationPlaceholderView.frame.origin.x = -UIScreen.main.bounds.width
//            }, completion: nil)
          
        //If view2 is on screen and view1 is hidden
        } else {
            //informationViewLabel.text = getInformationText(name: name)
            informationViewLabel.attributedText = getInformationText(name: name)
            informationViewTitleLabel.text = getInformationTitleText(name: name)
            if(isSelectedIndexBigger){
                infoNotPresentedAndRightMovement()
            } else {
                infoNotPresentedAndLeftMovement()
            }
//            self.informationPlaceholderView.frame.origin.x = UIScreen.main.bounds.width
//            let originViewX = self.previousInformationPlaceholderview.frame.origin.x
//            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.init(), animations: {
//                self.informationPlaceholderView.frame.origin.x = originViewX
//            }, completion: nil)
//
//            UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.init(), animations: {
//                self.previousInformationPlaceholderview.frame.origin.x = -UIScreen.main.bounds.width
//            }, completion: nil)
        }
        isInfoViewPresented.toggle()
    }
    
    //MARK: Animations for selection
    
    
    func infoNotPresentedAndRightMovement(){
        self.informationPlaceholderView.frame.origin.x = UIScreen.main.bounds.width
        let originViewX = self.previousInformationPlaceholderview.frame.origin.x
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.init(), animations: {
            self.informationPlaceholderView.frame.origin.x = originViewX
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.init(), animations: {
            self.previousInformationPlaceholderview.frame.origin.x = -UIScreen.main.bounds.width
        }, completion: nil)
    }
    
    func infoNotPresentedAndLeftMovement(){
        self.informationPlaceholderView.frame.origin.x = -UIScreen.main.bounds.width
        let originViewX = self.previousInformationPlaceholderview.frame.origin.x
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.init(), animations: {
            self.informationPlaceholderView.frame.origin.x = originViewX
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.init(), animations: {
            self.previousInformationPlaceholderview.frame.origin.x = UIScreen.main.bounds.width
        }, completion: nil)
    }
        
    func infoPresentedAndRightMovement(){
        self.previousInformationPlaceholderview.frame.origin.x = UIScreen.main.bounds.width
        let originViewX = self.informationPlaceholderView.frame.origin.x
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.init(), animations: {
            self.previousInformationPlaceholderview.frame.origin.x = originViewX
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.init(), animations: {
            self.informationPlaceholderView.frame.origin.x = -UIScreen.main.bounds.width
        }, completion: nil)
    }
    
    func infoPresentedAndLeftMovement(){
        self.previousInformationPlaceholderview.frame.origin.x = -UIScreen.main.bounds.width
        let originViewX = self.informationPlaceholderView.frame.origin.x
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.init(), animations: {
            self.previousInformationPlaceholderview.frame.origin.x = originViewX
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.init(), animations: {
            self.informationPlaceholderView.frame.origin.x = UIScreen.main.bounds.width
        }, completion: nil)
    }
    
    //MARK:- Datasource for cards
    
    func getInformationText(name: String) -> NSMutableAttributedString {
        
        var attributedText = NSMutableAttributedString(string: "", attributes: .none)
        switch name {
            
        case "1":
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "Besides humans, ", isBold: false)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "ants are the only creatures that will farm other creatures.", isBold: true)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: " Ants would raise other insects like human raise cows, sheep, etc. The most common occurrence of this is with aphids. \n\nAnts will protect aphids from natural predators, and shelter them in their nests from heavy rain showers in order to gain a constant supply of honeydew.", isBold: false)
            
        case "2":
            
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "Some species of ant, such as slave-making ants, ", isBold: false)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "invade neighboring ant colonies, capturing its inhabitants and forcing them to work for them.", isBold: true)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: " This process is known as ‘slave raiding’. Slave-making ants are specialized to parasite a single species or a group of related species which are often close relatives to them. \n\nThe captured ants will work as if they were in their own colony, while the slave-making workers will only concentrate on replenishing their labor force.", isBold: false)
            
        case "3":
            
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "Not all ants can swim, it depends on the species. They haven’t mastered the butterfly or breaststroke, yet, but ", isBold: false)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "they do have the ability to survive in water", isBold: true)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: " by using their own version of the doggy paddle, and can also float for long periods of time. \n\nTo put it simply, ants are amazing survivors. Not only can they hold their breath underwater for long periods of time, but they will also build life boats to survive floods. It can be especially dangerous whenfire ants do this.", isBold: false)
            
        case "4":
            
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "Found in Argentina in 2000, the ginormous colony housed 33 ant populations which had merged into one giant supercolony, ", isBold: false)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "with millions of nests and billions of workers!", isBold: true)

        case "5":
            
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "Ants are ridiculously strong. They have the ", isBold: false)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "ability to carry between 10 and 50 times their own body weight!", isBold: true)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: " The amount an ant can carry depends on the species. The Asian weaver ant, for example, can lift 100 times its own mass. ", isBold: false)

        case "6":
            
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "Unlike some bugs who might only live for days or even hours, the queen ant of one particular species. The Pogonomyrmex Owyheei ", isBold: false)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "can live up to 30 years,", isBold: true)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: " so be careful not to stand on her!", isBold: false)

        case "7":
            
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "A study from Harvard and Florida State Universities discovered that ants first rose during the Cretaceous period ", isBold: false)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "around 130 million years ago!", isBold: true)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "\n\nThey have survived the Cretaceous-Tertiary (K/T extinction) that killed the dinosaurs as well as the ice age.", isBold: false)

        case "8":
            
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "Ranging from the ant you might find scuttling across your picnic to the ants building underground fortresses in the rainforest, to flying ants! \n\nTo put things in perspective, it is estimated that there are ", isBold: false)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "around 1 million ants for every 1 human", isBold: true)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: " in the world! Ants have pretty much conquered the entire globe.", isBold: false)

        case "9":
            
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "Rather than going down the traditional route of reproduction, some Amazonian ants have taken to reproduce via cloning. \n\nIt is reported that the ", isBold: false)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "queen ants copy themselves to genetically produce daughters,", isBold: true)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: " resulting in a colony with no male ants.", isBold: false)

        case "10":
            
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "Ants “listen” by feeling vibrations", isBold: true)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: " from the ground through their feet, and eye-less ants such as the driver ant species  ", isBold: false)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "can communicate by using their antennae!", isBold: true)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "\n\nPlus, they ", isBold: false)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: "can send chemical signals (called pheremones)", isBold: true)
            attributedText = appendAttributedTexts(attributedText: attributedText, textToAttribute: " released through their body to send messages to other ants! They send out warnings when danger’s near, leave trails of pheremones leading to food sources and even use them to attract a mate – a sort of ant love potion!", isBold: false)

        
        default:
            break
        }
        return attributedText
    }
    
    func getInformationTitleText(name: String) -> String {
        
        switch name {
    
        case "1":
            return "Ants are farmers"
        case "2":
            return "Ants are slave-makers"
        case "3":
            return "Ants can swim"
        case "4":
            return "Ants can make huge nests"
        case "5":
            return "Ants have superhuman strength"
        case "6":
            return "Ants are the longest living insects"
        case "7":
            return "Ants are as old as dinosaurs"
        case "8":
            return "Ants are a diverse species"
        case "9":
            return "Some ants are asexual"
        case "10":
            return "Ants can be deaf and blind"
        default:
            break
        }
        return ""
    }
    
    func appendAttributedTexts(attributedText: NSMutableAttributedString, textToAttribute: String, isBold: Bool) -> NSMutableAttributedString{
        
        var titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "GlacialIndifference-Regular", size: 17)! ]
        if(isBold){
            titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "GlacialIndifference-Bold", size: 17)! ]
        }
        attributedText.append(NSAttributedString(string: textToAttribute,attributes: titleTextAttributes))
        return attributedText
    }
    
}



