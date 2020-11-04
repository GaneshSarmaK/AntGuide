//
//  RankingViewController.swift
//  Cloudy
//
//  Created by Ganesh on 16/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit
import OHMySQL
import Alamofire
import AlamofireImage
import ViewAnimator
import CollectionViewPagingLayout

//Variable declaration
var viewReloaded: Bool = false


class RankingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //Variable declaration
    let categories = ["Special Diet", "Helpful", "Gigantic", "Invasive", "Stingers", "Hazardous", "Colorful"]
    let categorySuggestions = ["1", "2", "3", "4", "5", "6", "7"]
    let colors = [ UIColor(hex: "43AA8B"), UIColor(hex: "90BE6D"), UIColor(hex: "F9C74F"), UIColor(hex: "F8961E"), UIColor(hex: "F3722C"), UIColor(hex: "F94144"), UIColor.clear]

    //var names2 = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"]
    var imageCache: AutoPurgingImageCache?
    var dataList: [DBResponse] = []
    var entireData: [DBResponse] = []
    var antNames: [DBResponseName] = []
    var selectedAntItem: DBResponse?
    var i = 0
    var selectedCateoryUrl: String = ""
    var selectedCategoryName: String = ""
    private let animations = [AnimationType.from(direction: .right, offset: UIScreen.main.bounds.width)]
    var lastSelectedIndexPath:IndexPath?
    var tableViewDataUrls: [String] = []
    var tableViewDataLabels: [String] = []
    var timerForShowScrollIndicator: Timer?
    
    //Storyboard elements
    @IBOutlet weak var antCollectionCategoryLabel: UILabel!
    @IBOutlet weak var antCollectionCategorySuggestionDataLabel: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionView2: UICollectionView!
    @IBOutlet var categorySuggestionsTableView: UITableView!
    
    
    //method for loading data
    func loadData(){
        let nib = UINib(nibName: CollectionViewCell.nibName, bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: CollectionViewCell.reuseIdentifier)
        if let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
        collectionView.animate(animations: animations)
    }
    
    //Ovverride methos for view initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        imageCache = appDelegate.imageCache
        
        //delegates
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
        collectionView2.dataSource = self
        collectionView2.delegate = self
        collectionView2.reloadData()
        collectionView.isPagingEnabled = false
        registerNib()
        
        
        collectionView2.flashScrollIndicators()
        collectionView2.showsHorizontalScrollIndicator = true

        //SQL environment setup
        let user = OHMySQLUser(userName: "antGuideClient", password: "antGuide", serverName: "antdb.cgwmwabypjj0.ap-southeast-2.rds.amazonaws.com", dbName: "new", port: 3306, socket: nil)
        let coordinator = OHMySQLStoreCoordinator(user: user!)
        coordinator.encoding = .UTF8MB4
        coordinator.connect()
        
        let context = OHMySQLQueryContext()
        context.storeCoordinator = coordinator
        
        
        //Querying the SQL database and parsing results
        let query = OHMySQLQueryRequestFactory.select("ant1", condition: nil )
        let response = try? context.executeQueryRequestAndFetchResult(query)
        guard let responseObject = response else { return }
        for data in responseObject{
            let item = DBResponse(with: data)
            dataList.append(item)
            entireData.append(item)
            setImageFromUrl(url: item.image!, imagename: item.bioName!)
        }
        
        //Querying the SQL database and parsing results

        let query2 = OHMySQLQueryRequestFactory.select("ant2", condition: nil )
        let response2 = try? context.executeQueryRequestAndFetchResult(query2)
        guard let responseObject2 = response2 else { return }
        for data in responseObject2{
            let item = DBResponseName(with: data)
            antNames.append(item)
            
        }
        
        
        //initial data for the collection of ants
        dataList = []
        for ant in antNames{
            if(ant.helpful!){
                dataList.append(getAntItem(antName: ant.bioName!))
            }
        }
        
        antCollectionCategoryLabel.text  = "Helpful Ants"
        antCollectionCategorySuggestionDataLabel.text = "Useful links about Helpful Ants"
        
        
        //scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 850)
        
        //collectionView.frame.size = CGSize( width: self.view.frame.width - 40, height: collectionView.frame.height)

        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

        loadData()
        
        
        //reload the collection views after a certain period of time
        collectionView2.performBatchUpdates(nil) { _ in
            let indexPath = IndexPath(item: 1, section: 0)
            self.collectionView2.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionView.ScrollPosition.init())
            let cell = self.collectionView2.cellForItem(at: indexPath)
            cell?.layer.borderColor = UIColor.white.cgColor
            cell?.layer.borderWidth = 3
            cell?.isSelected = true
            self.configureTableViewData(category: "Helpful")
            self.categorySuggestionsTableView.reloadData()
            UIView.animate(views: self.categorySuggestionsTableView.visibleCells, animations: self.animations, completion: nil)
        }
        
        UIView.animate(withDuration: 0.1) {
            self.collectionView.flashScrollIndicators()
            self.collectionView2.flashScrollIndicators()

        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        collectionView.reloadData()
        collectionView2.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.timerForShowScrollIndicator = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(self.showScrollIndicatorsInContacts), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.timerForShowScrollIndicator?.invalidate()
        self.timerForShowScrollIndicator = nil
    }
    
    //Always show the scroll bar for a categories
    @objc func showScrollIndicatorsInContacts() {
        UIView.animate(withDuration: 0.001) {
            self.collectionView2.flashScrollIndicators()
        }
    }
    
    //This method returns some ant data when called
    @IBAction func selecedSegmentChanged(_ sender: Any) {
       
        dataList = []
        //SQL environment setup
        let user = OHMySQLUser(userName: "antGuideClient", password: "antGuide", serverName: "antdb.cgwmwabypjj0.ap-southeast-2.rds.amazonaws.com", dbName: "new", port: 3306, socket: nil)
        let coordinator = OHMySQLStoreCoordinator(user: user!)
        coordinator.encoding = .UTF8MB4
        coordinator.connect()
        
        let context = OHMySQLQueryContext()
        context.storeCoordinator = coordinator
        
        
        //Querying the SQL database and parsing results
        let query = OHMySQLQueryRequestFactory.select("ant1", condition: nil )
        let response = try? context.executeQueryRequestAndFetchResult(query)
        guard let responseObject = response else { return }
        for data in responseObject{
            let item = DBResponse(with: data)
            dataList.append(item)
            setImageFromUrl(url: item.image!, imagename: item.bioName!)
        }
        
        
        switch segmentControl.selectedSegmentIndex
        {
            case 0:
                dataList = Array(dataList[0...11])
            
            case 1:
                dataList = Array(dataList[21...31])
            
            case 2:
                dataList = Array(dataList[41...51])
            
            case 3:
                dataList = Array(dataList[71...81])

            default:
                    
                break
        }
        loadData()
        
    }
    
    //fetch data from database
    func getDataList() {
       
        dataList = []
        //SQL environment setup
        let user = OHMySQLUser(userName: "antGuideClient", password: "antGuide", serverName: "antdb.cgwmwabypjj0.ap-southeast-2.rds.amazonaws.com", dbName: "new", port: 3306, socket: nil)
        let coordinator = OHMySQLStoreCoordinator(user: user!)
        coordinator.encoding = .UTF8MB4
        coordinator.connect()
        
        let context = OHMySQLQueryContext()
        context.storeCoordinator = coordinator
        
        
        //Querying the SQL database and parsing results
        let query = OHMySQLQueryRequestFactory.select("ant1", condition: nil )
        let response = try? context.executeQueryRequestAndFetchResult(query)
        guard let responseObject = response else { return }
        for data in responseObject{
            let item = DBResponse(with: data)
            dataList.append(item)
            setImageFromUrl(url: item.image!, imagename: item.bioName!)
        }
        
    }
    
    //MARK:- CollectionView delegates and methods
    //method for registering cells to collection views
    func registerNib() {
        let nib = UINib(nibName: CollectionViewCell.nibName, bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: CollectionViewCell.reuseIdentifier)
        if let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
        let nib2 = UINib(nibName: CollectionViewCell2.nibName, bundle: nil)
        collectionView2?.register(nib2, forCellWithReuseIdentifier: CollectionViewCell2.reuseIdentifier)
        if let flowLayout = self.collectionView2?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
    }
    
    ///CollectionView datasource and delegate methods
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    
    //A collectionView method that tells the number of items in a collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count = 0
        if(collectionView == self.collectionView){
            count = dataList.count
        }
        if(collectionView == self.collectionView2){
            count = categories.count
        }
        return count
    }

    //A collection view method that sets the data for each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //data for 2 collection views
        if(collectionView == self.collectionView){
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.reuseIdentifier, for: indexPath) as? CollectionViewCell {

                var scale: CGFloat =  CGFloat((self.collectionView.frame.height - 30))
                if(  self.collectionView.frame.height >  self.collectionView.frame.width){
                    scale =  CGFloat((self.collectionView.frame.width - 120))
                }
                            
                let size: CGSize = CGSize(width: scale, height: scale)
                
                cell.configureCell(name: dataList[indexPath.row].commonName!, image: String(describing: dataList[indexPath.row].image!), bioName: dataList[indexPath.row].bioName!, size: size )
                cell.imageView.backgroundColor = .white
                if (cell.isImageSet){
                    cell.activityIndicator.stopAnimating()
                }
                return cell
            }
        }
        
        if(collectionView == self.collectionView2){
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell2.reuseIdentifier, for: indexPath) as? CollectionViewCell2 {
                cell.configureCell(categoryName: categories[indexPath.row], color: colors[indexPath.row])
                cell.isSelected = (lastSelectedIndexPath == indexPath)
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    //On selction showing the details screen with the selected elemenet as the ibject
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(collectionView == self.collectionView){
            selectedAntItem = dataList[indexPath.row]
            self.performSegue(withIdentifier: "showDetailFromRankingSegue", sender: self)
        }
        if(collectionView == self.collectionView2){
            
            //getDataList()
            var tempList: [DBResponse] = []
            if (categories[indexPath.row] == selectedCategoryName){
                return
            }
            self.collectionView.scrollToItem(at: IndexPath.init(), at: UICollectionView.ScrollPosition.left, animated: true)
            if (categories[indexPath.row] == categories[0])
            {
                for ant in antNames{
                    if(ant.specialDiet!){
                        tempList.append(getAntItem(antName: ant.bioName!))
                    }
                }
            }
            if (categories[indexPath.row] == categories[1])
            {
                for ant in antNames{
                    if(ant.helpful!){
                        tempList.append(getAntItem(antName: ant.bioName!))
                    }
                }
            }
            if (categories[indexPath.row] == categories[2])
            {
                for ant in antNames{
                    if(ant.gigantic!){
                        tempList.append(getAntItem(antName: ant.bioName!))
                    }
                }
            }
            if (categories[indexPath.row] == categories[3])
            {
                for ant in antNames{
                    if(ant.invasive!){
                        tempList.append(getAntItem(antName: ant.bioName!))
                    }
                }
            }
            if (categories[indexPath.row] == categories[4])
            {
                for ant in antNames{
                    if(ant.stingers!){
                        tempList.append(getAntItem(antName: ant.bioName!))
                    }
                }
            }
            if (categories[indexPath.row] == categories[5])
            {
                for ant in antNames{
                    if(ant.hazardous!){
                        tempList.append(getAntItem(antName: ant.bioName!))
                    }
                }
            }
            if (categories[indexPath.row] == categories[6])
            {
                for ant in antNames{
                    if(ant.colorful!){
                        tempList.append(getAntItem(antName: ant.bioName!))
                    }
                }
            }
            dataList = tempList
            loadData()
            antCollectionCategoryLabel.text = categories[indexPath.row] + " Ants"
            antCollectionCategorySuggestionDataLabel.text = "Useful links about \(categories[indexPath.row]) Ants"
            selectedCategoryName = categories[indexPath.row]
            
            guard lastSelectedIndexPath != indexPath else {
                return
            }
            
            if lastSelectedIndexPath != nil {
                self.collectionView2.deselectItem(at: lastSelectedIndexPath!, animated: false)
            }
            
            let selectedCell = self.collectionView2.cellForItem(at: indexPath) as! CollectionViewCell2
            selectedCell.isSelected = true
            lastSelectedIndexPath = indexPath
            
            self.configureTableViewData(category: categories[indexPath.row])
            self.categorySuggestionsTableView.reloadData()
            UIView.animate(views: categorySuggestionsTableView.visibleCells, animations: animations, completion: nil)

        }
        // do stuff with image, or with other data that you need
    }
    
    func getAntItem(antName: String) -> DBResponse{
        for item in entireData{
            if(item.bioName! == antName){
                return item
            }
        }
        return entireData[0]
    }

    
//    //A collection view's layout method to tell the size of each cell
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let itemSize: CGSize = CGSize(width: 250, height: 250)
//
//        if(collectionView == self.collectionView){
//            guard let cell: CollectionViewCell = Bundle.main.loadNibNamed(CollectionViewCell.nibName, owner: self, options: nil)?.first as? CollectionViewCell else {
//                    return CGSize.zero
//            }
//            cell.configureCell(name: dataList[indexPath.row].bioName!, image: dataList[indexPath.row].image!)
//           // cell.setNeedsLayout()
//            //cell.layoutIfNeeded()
//            //itemSize = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
//
//        }
//
//        if(collectionView == self.collectionView2){
//            guard let cell: CollectionViewCell2 = Bundle.main.loadNibNamed(CollectionViewCell2.nibName, owner: self, options: nil)?.first as? CollectionViewCell2 else {
//                    return CGSize.zero
//            }
//            cell.configureCell(name: dataList[indexPath.row].bioName!, image: dataList[indexPath.row].image!)
//            cell.setNeedsLayout()
//            cell.layoutIfNeeded()
//            //itemSize = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
//
//        }
//
//        return itemSize
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var side =  self.collectionView.frame.height - 30
        if(  self.collectionView.frame.height >  self.collectionView.frame.width){
            side =  self.collectionView.frame.width - 120
        }
        var size = CGSize(width: side, height: side)
        if(collectionView == self.collectionView){
            size = CGSize(width: side, height: side)
        }
        if(collectionView == self.collectionView2){
            size = CGSize(width: 120, height: 40)
            if(categories[indexPath.row] == categories[categories.count-1]){
                size = CGSize(width: 140, height: 40)
            }
            //String(describing: categories[indexPath.row]).size(withAttributes: nil).width + 10
        }
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
//    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
//           URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
//       }
//
//   func downloadImage(from url: URL) -> UIImage {
//       print("Download Started")
//       getData(from: url) { data, response, error in
//           guard let data = data, error == nil else { return }
//           print(response?.suggestedFilename ?? url.lastPathComponent)
//           print("Download Finished")
//           let downloadedImage = UIImage(data: data)?.crop(to: CGSize(width: 250, height: 200))
//           DispatchQueue.main.async() {
//                return downloadedImage!
//               //self.setImageFrame(image: downloadedImage!)
//           }
//        }
//        return UIImage()
//   }
    //A methodto pass data when a different ciewController is called.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if clicked on an ant
        if segue.destination is AntDetailsViewController
        {
            let viewController = segue.destination as? AntDetailsViewController
            viewController?.antItem = selectedAntItem
            viewController?.triggerDataStore = true
        }
        //if clicked on a link
        if segue.destination is RSSFeedResultsViewController
        {
            let viewController = segue.destination as? RSSFeedResultsViewController
            viewController?.rssItemURL = selectedCateoryUrl
        }
    }

}

//A UI color extennsion to produce a random color
extension UIColor {
    class func randomColor() -> UIColor {
        
        let hue = CGFloat(arc4random() % 100) / 100
        let saturation = CGFloat(arc4random() % 100) / 100
        let brightness = CGFloat(arc4random() % 100) / 100
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}


//An extension the viewcontroller for downloading the images asynchronously and setting them to the image cache of tha mobile
extension RankingViewController{
    
    //This method checks if the image is already in cache, if not then  it downloads from the web then sets it to the view
    //@parameter url:                A link to the image
    func setImageFromUrl(url: String, imagename: String){
        
        let urlRequest = URLRequest(url: URL(string: url)!)
        if let image = imageCache!.image(withIdentifier: String(describing: urlRequest))
        {
            return
        } else {
            Alamofire.request(urlRequest).responseImage { response in
                if response.result.value != nil {
                    let image = UIImage(data: response.data!, scale: 1.0)!
                    image.saveToDocuments(filename: "\(imagename).jpg")
                    self.imageCache!.add(image, withIdentifier: String(describing: urlRequest))
                }
            }
        }
    }
}

//MARK:- Tableview delegates and datasource

extension RankingViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categorySuggestionsTableView.contentSize.height = CGFloat(tableViewDataUrls.count * 45 + 45)
        //categorySuggestionsTableView.frame.size = CGSize(width: categorySuggestionsTableView.frame.width, height: CGFloat(tableViewDataUrls.count * 45))
        print(tableViewDataUrls.count)
        return  tableViewDataUrls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionCell", for: indexPath)
        cell.textLabel?.text = tableViewDataLabels[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionCell", for: indexPath)
        selectedCateoryUrl = tableViewDataUrls[indexPath.row]
        performSegue(withIdentifier: "showWebViewSegue", sender: self)
        print(tableViewDataUrls[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 40
        }
    }
    
    func configureTableViewData(category: String){
        tableViewDataUrls = []
        tableViewDataLabels = []
        switch category {
            case "Special Diet":
                tableViewDataUrls = ["https://www.agric.wa.gov.au/pest-insects/australian-meat-ants", "https://australianmuseum.net.au/learn/animals/insects/meat-ant/", "https://canberra.naturemapr.org/Species/23519"]
                tableViewDataLabels = ["Australian meat ants", "Meat Ant", "Coconut Ant"]
            case "Helpful":
                tableViewDataUrls = ["https://www.towergarden.com/blog.read.html/en/2017/6/control-ants-in-the-garden.html", "https://australianmuseum.net.au/learn/animals/insects/seed-dispersal/", "https://www.finegardening.com/article/ants-arent-your-enemy", "https://www.vulcantermite.com/garden-pest-control/ants-beneficial-insects/", "https://www.organicgardener.com.au/blogs/ants-friend-or-foes"]
                tableViewDataLabels = ["Got Ants in Your Plants? Here’s What You Need to Know", "Seed dispersal","Ants aren't your enemy", "Are Ants Beneficial Insects?", "Ants-Friend or foes"]
            case "Gigantic":
                tableViewDataUrls = ["https://www.nationalgeographic.org/media/honey-ant-adaptations-wbt/", "https://fallout.fandom.com/wiki/Giant_ant", "https://www.smh.com.au/national/giant-colony-of-ants-found-in-melbourne-20040812-gdjj52.html", "https://www.australiangeographic.com.au/topics/wildlife/2018/02/australias-native-ants-are-really-just-wingless-wasps/"]
                tableViewDataLabels = ["Austraian Honeypot Ant", "Giant ant", "Giant colony of ants found in Melbourne", "Bull Ants are wingless wasps"]
            case "Invasive":
                tableViewDataUrls = ["https://www.agriculture.gov.au/pests-diseases-weeds/plant/tramp-ants#keep-invasive-ants-out-of-australia", "https://www.environment.gov.au/biodiversity/invasive-species/insects-and-other-invertebrates/tramp-ants", "https://www.abc.net.au/life/the-threat-of-invasive-ants/11341332", "https://www.agric.wa.gov.au/invasive-species/ant-identification-key-successful-control"]
                tableViewDataLabels = ["Exotic invasive ants", "Tramp or invasive ants", "What you need to know about the threat of invasive ants", "Ants: identification and control"]
            case "Stingers":
                tableViewDataUrls = ["https://www.syngentappm.com.au/news/ants/six-species-ants-you-need-know", "https://www.allergy.org.au/patients/insect-allergy-bites-and-stings/jack-jumper-ant-allergy", "https://www.betterhealth.vic.gov.au/health/ConditionsAndTreatments/allergies-to-bites-and-stings", "https://theconversation.com/ants-bees-and-wasps-the-venomous-australians-with-a-sting-in-their-tails-51024"]
                tableViewDataLabels = ["The Six Species of Ants you Need to Know", "Jack Jumper Ant Allergy", "Allergies to bites and stings", "Ants: the venomous Australians with a sting in their tails"]
            case "Hazardous":
                tableViewDataUrls = ["https://www.lvpest.com/6-natural-ways-get-rid-ants/", "https://greenharvest.com.au/PestControlOrganic/Information/AntControl.html", "https://www.rentokil.com.au/ants/species/", "https://australianmuseum.net.au/learn/animals/insects/bull-ants/", "https://www.farmersalmanac.com/repel-ants-naturally-27673"]
                tableViewDataLabels = ["6 Natural Ways To Get Rid Of Ants", "Organic Strategies for Ant Control", "Hazardous Ants of Australia", "Bull Ants", "21 Natural Ways To Get Rid of Ants Before This Happens!"]
            case "Colorful":
                tableViewDataUrls = ["https://ppmmagazine.com.au/blue-ant/", "https://aepma.com.au/PestDetail/8/Green-Headed%20Ant", "https://fantasticservicesgroup.com.au/blog/green-ant/", "https://www.agric.wa.gov.au/pest-insects/coastal-brown-ants-big-headed-ants?page=0%2C0"]
                tableViewDataLabels = ["Blue Ant", "Green-Headed Ant" ,"Green Ants", "Coastal brown ants, big-headed ants"]
            default:
                break
        }
    }
    
}

