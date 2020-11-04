//
//  SearchResultsViewController.swift
//  Cloudy
//
//  Created by Ganesh on 14/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

//TODO: Handling the Search after getting fro the database.


import UIKit
import OHMySQL
import AlamofireImage
import Alamofire
import AnimatedCollectionViewLayout
import ViewAnimator

var searchResultsLoaded = false

class SearchResultsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //Storyboard elements and variable declaration
    var animator: (LayoutAttributesAnimator, Bool, Int, Int) = (LinearCardAttributesAnimator(), false, 1, 1)
    var direction: UICollectionView.ScrollDirection = .vertical
    var imageCache: AutoPurgingImageCache?
    var antColor: String = ""
    var antHair: Int = 0
    var antSize: Float = 0.00
    var selectedColor: UIColor?
    var advBodyColor: UIColor?
    var advHeadColor: UIColor?
    var advTailColor: UIColor?
    var basicAntSize: String = ""
    var isAdvancedOptionsEnabled: Bool = false
    private let animations = [AnimationType.from(direction: .right, offset: 500)]

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noAntsFoundView: UIView!
    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    var dataList: [DBResponse] = []
    var dataNames: [DBResponseName] = []
    var selectedItemToPass: DBResponse?

    
    //An override method for the view initializtion
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegates and local variables
        dataList = []
        dataNames = []
        
        //backgroundView.isHidden = true
        collectionView.layer.borderColor = UIColor.lightGray.cgColor
        collectionView.backgroundColor = UIColor(hex: "EFEFEF")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        imageCache = appDelegate.imageCache
        
        //setting up database environment
        let user = OHMySQLUser(userName: "antGuideClient", password: "antGuide", serverName: "antdb.cgwmwabypjj0.ap-southeast-2.rds.amazonaws.com", dbName: "new", port: 3306, socket: nil)
        let coordinator = OHMySQLStoreCoordinator(user: user!)
        coordinator.encoding = .UTF8MB4
        coordinator.connect()
        
        let context = OHMySQLQueryContext()
        context.storeCoordinator = coordinator
        
        
        let bodyLength = Double(String(format: "%.2f", antSize*10))
        
        var bodylengthCondition = ""
        var colorCondition = ""
        
        ///Creating the condition to query the database
        
        if (isAdvancedOptionsEnabled){
        //IF advanced options enabled then get body length and color from the adv options use the basics options as a buffer
            //advanced size options
            if ( antSize != 0.0){
                basicAntSize = ""
                
                if (bodyLength == 10.0){
                    bodylengthCondition = " ( bodyLength > \(bodyLength! - 0.35) ) "
                }
                else{
                    bodylengthCondition = " ( bodyLength > \(bodyLength! - 0.25) AND bodyLength < \(bodyLength! + 0.25) ) "
                }
            } else { //basic size options
                bodylengthCondition = basicAntSize
            }
            
            //Advanced color options
            colorCondition.append(contentsOf: " ( 1 = 1 ")
            if (advHeadColor != nil){
                colorCondition.append(contentsOf: " AND ")
                colorCondition.append(contentsOf: " ( \(getColorQueryText(color: advHeadColor!, uniColor: false, isAdvOptions: true, bodyPart: "headColor")) )")
                
            }
            if (advBodyColor != nil){
                colorCondition.append(contentsOf: " AND ")
                colorCondition.append(contentsOf: " ( \(getColorQueryText(color: advBodyColor!, uniColor: false, isAdvOptions: true, bodyPart: "bodyColor")) )")
                

            }
            if (advTailColor != nil){
                 colorCondition.append(contentsOf: " AND ")
                 colorCondition.append(contentsOf: " ( \(getColorQueryText(color: advTailColor!, uniColor: false, isAdvOptions: true, bodyPart: "tailColor")) )")
            }
            colorCondition.append(contentsOf: " ) ")
//            let basicColorQuery = getColorTextForQuery(color: selectedColor!, uniColor: false)
//            colorCondition.append(contentsOf: " ) AND ( \(basicColorQuery )  ) ")
            
            
        } else { //basic color options
            bodylengthCondition = basicAntSize
            colorCondition = getColorTextForQuery(color: selectedColor!, uniColor: false)
        }
        
        //the final required query
        let queryCond = " \(bodylengthCondition) AND ( \(colorCondition) ) AND ( hair = \(antHair) )"
        //let condition: String = "bodyColor = '\(antColor)' AND bodyLength = \(bodyLength) AND sculpturing = \(scultping)"
        
        //querying the database
        let antDetails = OHMySQLQueryRequestFactory.select("ant2", condition:  nil)
        let response = try? context.executeQueryRequestAndFetchResult(antDetails)
        guard let responseObject1 = response else { return }
        for data in responseObject1{
            let item = DBResponseName(with: data)
            dataNames.append(item)
            
        }
        let antNames = OHMySQLQueryRequestFactory.select("ant1", condition: queryCond )
        let response2 = try? context.executeQueryRequestAndFetchResult(antNames)
        guard let responseObject2 = response2 else { return }
        for data in responseObject2{
            let item = DBResponse(with: data)
            dataList.append(item)
            setImageFromUrl(url: item.image!)
        }
        
        collectionView.isHidden = false
        noAntsFoundView.isHidden = true
        
        //check if there is any data. If not then display an error
        if (dataList.count == 0){
            
            collectionView.isHidden = true
            noAntsFoundView.isHidden = false
            suggestionLabel.numberOfLines = 0
            suggestionLabel.text = "There were no ants found with the provided search parameters. Please try with different parameters.\n\nYou can find most common ants in Victoria with following paremeters: \nColor: Brown   Size: Large   Hair:  Yes"
            suggestionLabel.textAlignment = .justified
//            let label = UILabel()
//            let view  = UIView()
//            view.center = self.view.center
//            view.layer.cornerRadius = 20
//            view.sizeThatFits(CGSize(width: 200, height: 70))
//            view.layer.borderColor = UIColor.lightGray.cgColor
//            label.text = "No Ants Found"
//            label.numberOfLines = 0
//            label.frame = CGRect(x: self.view.bounds.size.width/2,y: 50,width: self.view.bounds.size.width, height: self.view.bounds.size.height)
//            label.textAlignment = .center
//            label.sizeToFit()
//            label.frame = CGRect(x: self.view.bounds.size.width/2,y: 50,width: label.frame.width * 3 / 2, height: label.frame.height * 5 / 4)
//            label.backgroundColor = UIColor.systemRed
//            label.center = self.view.center
//            label.layer.cornerRadius = 30
//            view.backgroundColor = .lightGray
//            view.addSubview(label)
//            self.view.addSubview(view)
        }
        
        //setting up the collection view to receive the data from the database
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: AntSearchDetailCell.nibName, bundle: nil)

        collectionView.register(nib, forCellWithReuseIdentifier: "antResultCell")
        
        collectionView.performBatchUpdates({
            UIView.animate(views: self.collectionView!.orderedVisibleCells, animations: animations, reversed: false, initialAlpha: 1, finalAlpha: 1, delay: 0, animationInterval: 0.4, duration: 0.5, usingSpringWithDamping: 5, initialSpringVelocity: 5, options: AnimationOptions.init(), completion: nil)
            
        }, completion: nil)
        
//        collectionView?.performBatchUpdates({
//            UIView.animate(views: self.collectionView!.orderedVisibleCells,
//                animations: animations, completion: nil)
//        }, completion: nil)
//
        //collectionView?.isPagingEnabled = true
   
//        collectionView?.register(nib, forCellWithReuseIdentifier: AntSearchDetailCell.reuseIdentifier)
//        if let layout = self.collectionView?.collectionViewLayout as? AnimatedCollectionViewLayout {
//            layout.scrollDirection = direction
//            layout.animator = animator.0
//
//        }
        //collectionView.frame = CGRect(x: 20, y: 100, width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height-100)
        
        collectionView.reloadData()
        
    }
    
    //MARK:- Collection View
    ///CollectionView datasource and delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //loading data into the collection view cell
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "antResultCell", for: indexPath) as? AntSearchDetailCell {
            cell.configureCell(name: dataList[indexPath.row].commonName!, image: String(describing: dataList[indexPath.row].image!), bioName: String(describing: dataList[indexPath.row].bioName!) )
            cell.imageView.backgroundColor = .white
            if (cell.isImageSet){
                cell.activityIndicator.stopAnimating()
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItemToPass = dataList[indexPath.row]
        self.performSegue(withIdentifier: "showDetailFromFeatureSegue", sender: self)
        
        // do stuff with image, or with other data that you need
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 25
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    //preparing for a segue to the ants results
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AntDetailsViewController
        {
            let viewController = segue.destination as? AntDetailsViewController
            viewController?.antItem = selectedItemToPass
            viewController?.triggerDataStore = true
        }
    }

}


//bioName,commonName,headColor,bodyColor,tailColor,uniColorBody,bodyLength,advantages,disadvantages,isInvasive,queenNumber,diet,nestSite,numberOfSpines,sculpturing,colonyFounding,image, details are the column names of the database
//parsing the datasbase SON respone to a structre for future use.
struct DBResponseName: Codable{
    let bioName: String?
    let commonName: String?
    let specialDiet: Bool?
    let hazardous: Bool?
    let helpful: Bool?
    let invasive: Bool?
    let colorful: Bool?
    let gigantic: Bool?
    let stingers: Bool?
    
    
    init(with data: [String: Any]){
        self.bioName = data["bioName"] as? String
        self.commonName = data["commonName"] as? String
        self.specialDiet = data["specialDiet"] as? Bool
        self.hazardous = data["hazardous"] as? Bool
        self.helpful = data["helpful"] as? Bool
        self.invasive = data["invasive"] as? Bool
        self.colorful = data["colorful"] as? Bool
        self.gigantic = data["gigantic"] as? Bool
        self.stingers = data["stingers"] as? Bool
    }
    
}

var totalNo = 0
struct DBResponse: Codable{
    let bioName: String?
    let commonName: String?
    let headColor: Int?
    let bodyColor: Int?
    let tailColor: Int?
    var uniColorBody: Bool?
    let antHair: Bool?
    let bodyLength: Double?
    let advantages: String?
    let disadvantages: String?
    let isInvasive: Bool?
    let queenNumber: Int?
    let diet: String?
    let nestSite: String?
    let numberOfSpines: Int?
    let sculpturing: Int?
    let colonyFounding: String?
    var image: String?
    let details: String?
    
    //initializing the data of the structure from the JSON response data
    init(with data: [String: Any]){
        self.bioName = data["bioName"] as? String
        self.commonName = data["commonName"] as? String
        self.headColor = data["headColor"] as? Int
        self.bodyColor = data["bodyColor"] as? Int
        self.tailColor = data["tailColor"] as? Int
        self.uniColorBody = data["uniColorBody"] as? Bool
        self.bodyLength = Double(round(100 * ((data["bodyLength"] as? Double)!)) / 100)
        self.antHair = data["hair"] as? Bool
        self.advantages = data["advantages"] as? String
        self.disadvantages = data["disadvantages"] as? String
        self.isInvasive = data["isInvasive"] as? Bool
        self.queenNumber = data["queenNumber"] as? Int
        self.diet = data["diet"] as? String
        self.nestSite = data["nestSite"] as? String
        self.numberOfSpines = data["numberOfSpines"] as? Int
        self.sculpturing = data["sculpturing"] as? Int
        self.colonyFounding = data["colonyFounding"] as? String
        self.image = data["images"] as? String
        let urlString = (data["details"] as? String)!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        self.details = urlString
//        if (self.image == nil){
//            self.image = "https://cdn.arstechnica.net/wp-content/uploads/2019/10/fastant1-800x536.jpg"
//        }
        if (self.tailColor == self.bodyColor){
            if(self.tailColor == self.headColor){
                self.uniColorBody = true
            }
        } else {
            self.uniColorBody = false
        }

    }
}

//MARK:- Suppoting methods for sql queries
//Additional methods that help the required functionality
extension SearchResultsViewController{
    
    //download image from the internet and cache it
    func setImageFromUrl(url: String){
        
        //check if the image is in cache, if yes then return. If not then download the image
        let urlRequest = URLRequest(url: URL(string: url)!)
        if let image = imageCache!.image(withIdentifier: String(describing: urlRequest))
        {
            
        } else {
            Alamofire.request(urlRequest).responseImage { response in
                if response.result.value != nil {
                    let image = UIImage(data: response.data!, scale: 1.0)!
                    self.imageCache!.add(image, withIdentifier: String(describing: urlRequest))
                }
            }
        }
    }
    
    //A custom function that resturns a part of query for the color of the ant. Colors are mapped as close as possible to real world differenctiable colors
    func getColorQueryText(color: UIColor, uniColor: Bool, isAdvOptions: Bool, bodyPart: String) ->String{
        var colorQuery = ""
        if (uniColor) {
           if (color == UIColor.black){
               colorQuery = " bodyColor = 1 "
           }
           else if (color == UIColor.systemGreen){
               colorQuery = " bodyColor = 5 OR bodyColor = 4 "
           }
           else if (color == UIColor.systemRed){
               colorQuery = " bodyColor = 9 OR bodyColor = 10 "
           }
           else if (color == UIColor.systemOrange){
               colorQuery = " bodyColor = 17 OR bodyColor = 20 OR bodyColor = 21 "
           }
           else if (color == UIColor.brown){
               colorQuery = " bodyColor = 8 OR bodyColor = 22 OR bodyColor = 23 OR bodyColor = 24 "
           }
           else if (color == UIColor.systemYellow){
               colorQuery = " bodyColor = 15 OR bodyColor = 16 OR bodyColor = 18 OR bodyColor = 7 OR bodyColor = 19 "
           }
           else if (color == UIColor.gray){
               colorQuery = " bodyColor = 2 OR bodyColor = 3 "
           }
           else if (color == UIColor(red: 8/255, green: 3/255, blue: 110/255, alpha: 1)){
               colorQuery = " bodyColor = 11 OR bodyColor = 12 "
           }
       }
       
       if (!uniColor) {
        if (color == UIColor.black){
               colorQuery = " bodyColor = 1 OR tailColor = 1 OR headColor = 1 "
           }
           else if color == UIColor.systemGreen{
               colorQuery = " bodyColor = 5 OR bodyColor = 4 OR tailColor = 5 OR tailColor = 4 OR headColor = 5 OR headColor = 4 "
           }
           else if color == UIColor.systemRed{
               colorQuery = " bodyColor = 9 OR bodyColor = 10 OR tailColor = 9 OR tailColor = 10 OR headColor = 9 OR headColor = 10 "
           }
           else if color == UIColor.systemOrange{
               colorQuery = " bodyColor = 17 OR bodyColor = 20 OR bodyColor = 21 OR tailColor = 17 OR tailColor = 20 OR tailColor = 21 OR headColor = 17 OR headColor = 20 OR headColor = 21 "
           }
           else if color == UIColor.brown{
               colorQuery = " bodyColor = 8 OR bodyColor = 22 OR bodyColor = 23 OR bodyColor = 24 OR tailColor = 8 OR tailColor = 22 OR tailColor = 23 OR tailColor = 24 OR headColor = 8 OR headColor = 22 OR headColor = 23 OR headColor = 24 "
           }
           else if color == UIColor.systemYellow{
               colorQuery = " bodyColor = 15 OR bodyColor = 16 OR bodyColor = 18 OR bodyColor = 7 OR bodyColor = 19  OR headColor = 15 OR headColor = 16 OR headColor = 18 OR headColor = 7 OR headColor = 19 OR tailColor = 15 OR tailColor = 16 OR tailColor = 18 OR tailColor = 7 OR tailColor = 19 "
           }
           else if color == UIColor.gray{
               colorQuery = " bodyColor = 2 OR bodyColor = 3 OR tailColor = 2 OR tailColor = 3 OR headColor = 2 OR headColor = 3 "
           }
           else if color == UIColor(red: 8/255, green: 3/255, blue: 110/255, alpha: 1){
               colorQuery = " bodyColor = 11 OR bodyColor = 12 OR tailColor = 11 OR tailColor = 12 OR headColor = 11 OR headColor = 12 "
           }
       }
        
        if (isAdvOptions){
            if color == UIColor.black{
                colorQuery = " \(bodyPart) = 1 "
            }
            else if color == UIColor.systemGreen{
                colorQuery = " \(bodyPart) = 5 OR \(bodyPart) = 4 "
            }
            else if color == UIColor.systemRed{
                colorQuery = " \(bodyPart) = 9 OR \(bodyPart) = 10 "
            }
            else if color == UIColor.systemOrange{
                colorQuery = " \(bodyPart) = 17 OR \(bodyPart) = 20 OR \(bodyPart) = 21 "
            }
            else if color == UIColor.brown{
                colorQuery = " \(bodyPart) = 8 OR \(bodyPart) = 22 OR \(bodyPart) = 23 OR \(bodyPart) = 24 "
            }
            else if color == UIColor.systemYellow{
                colorQuery = " \(bodyPart) = 15 OR \(bodyPart) = 16 OR \(bodyPart) = 18 OR \(bodyPart) = 7 OR \(bodyPart) = 19 "
            }
            else if color == UIColor.gray{
                colorQuery = " \(bodyPart) = 2 OR \(bodyPart) = 3 "
            }
            else if color == UIColor(red: 8/255, green: 3/255, blue: 110/255, alpha: 1){
                colorQuery = " \(bodyPart) = 11 OR \(bodyPart) = 12 "
            }
        }
        
        
        return colorQuery
    }
    
    func getColorTextForQuery(color: UIColor, uniColor: Bool) -> String{
        var colorQuery = ""
        if (uniColor) {
            if color == UIColor.black{
                colorQuery = " bodyColor = 1 "
            }
            else if color == UIColor.systemGreen{
                colorQuery = " bodyColor = 5 OR bodyColor = 4 "
            }
            else if color == UIColor.systemRed{
                colorQuery = " bodyColor = 9 OR bodyColor = 10 "
            }
            else if color == UIColor.systemOrange{
                colorQuery = " bodyColor = 17 OR bodyColor = 20 OR bodyColor = 21 "
            }
            else if color == UIColor.brown{
                colorQuery = " bodyColor = 8 OR bodyColor = 22 OR bodyColor = 23 OR bodyColor = 24 "
            }
            else if color == UIColor.systemYellow{
                colorQuery = " bodyColor = 15 OR bodyColor = 16 OR bodyColor = 18 OR bodyColor = 7 OR bodyColor = 19 "
            }
            else if color == UIColor.gray{
                colorQuery = " bodyColor = 2 OR bodyColor = 3 "
            }
            else if color == UIColor(red: 8/255, green: 3/255, blue: 110/255, alpha: 1){
                colorQuery = " bodyColor = 11 OR bodyColor = 12 "
            }
        }
        
        if (!uniColor) {
            if color == UIColor.black{
                colorQuery = " bodyColor = 1 OR tailColor = 1 OR headColor = 1 "
            }
            else if color == UIColor.systemGreen{
                colorQuery = " bodyColor = 5 OR bodyColor = 4 OR tailColor = 5 OR tailColor = 4 OR headColor = 5 OR headColor = 4 "
            }
            else if color == UIColor.systemRed{
                colorQuery = " bodyColor = 9 OR bodyColor = 10 OR tailColor = 9 OR tailColor = 10 OR headColor = 9 OR headColor = 10 "
            }
            else if color == UIColor.systemOrange{
                colorQuery = " bodyColor = 17 OR bodyColor = 20 OR bodyColor = 21 OR tailColor = 17 OR tailColor = 20 OR tailColor = 21 OR headColor = 17 OR headColor = 20 OR headColor = 21 "
            }
            else if color == UIColor.brown{
                colorQuery = " bodyColor = 8 OR bodyColor = 22 OR bodyColor = 23 OR bodyColor = 24 OR tailColor = 8 OR tailColor = 22 OR tailColor = 23 OR tailColor = 24 OR headColor = 8 OR headColor = 22 OR headColor = 23 OR headColor = 24 "
            }
            else if color == UIColor.systemYellow{
                colorQuery = " bodyColor = 15 OR bodyColor = 16 OR bodyColor = 18 OR bodyColor = 7 OR bodyColor = 19  OR headColor = 15 OR headColor = 16 OR headColor = 18 OR headColor = 7 OR headColor = 19 OR tailColor = 15 OR tailColor = 16 OR tailColor = 18 OR tailColor = 7 OR tailColor = 19 "
            }
            else if color == UIColor.gray{
                colorQuery = " bodyColor = 2 OR bodyColor = 3 OR tailColor = 2 OR tailColor = 3 OR headColor = 2 OR headColor = 3 "
            }
            else if color == UIColor(red: 8/255, green: 3/255, blue: 110/255, alpha: 1){
                colorQuery = " bodyColor = 11 OR bodyColor = 12 OR tailColor = 11 OR tailColor = 12 OR headColor = 11 OR headColor = 12 "
            }
        }
        
        return colorQuery
    }
}


extension UIColor {
    var name: String? {
        switch self {
        case UIColor.black: return "black"
        case UIColor.gray: return "gray"
        case UIColor.red: return "red"
        case UIColor.green: return "green"
        case UIColor.orange: return "orange"
        case UIColor.yellow: return "yellow"
        case UIColor(red: 8/255, green: 3/255, blue: 110/255, alpha: 1): return "blue"
        case UIColor.brown: return "magenta"
        default: return nil
        }
    }
}




