//
//  RSSFeedViewController.swift
//  Cloudy
//
//  Created by Ganesh on 19/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit
import AlamofireRSSParser
import Alamofire

class RSSFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var rssFeedList: [RSSItem] = []
    var rssItemToPass: RSSItem?
    
    let url = "http://newsrss.bbc.co.uk/rss/newsonline_uk_edition/world/rss.xml"
    
    @IBOutlet weak var rssFeedTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rssFeedTableView.dataSource = self
        rssFeedTableView.delegate = self
        rssFeedTableView.rowHeight = 100

        //let url = "http://feeds.foxnews.com/foxnews/latest?format=xml"
        //let url = "https://www.reddit.com/r/all/.rss"
        
        Alamofire.request(url).responseRSS() { (response) -> Void in
            if let feed: RSSFeed = response.value {
                /// Do something with your new RSSFeed object!
                for item in feed.items {
                    self.rssFeedList.append(item)
                    self.rssFeedTableView.reloadData()
                    print(item)
                }
            }
        }
        rssFeedTableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rssFeedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?

        var date = String()
        if rssFeedList[indexPath.row].pubDate != nil{
            date = String(describing: rssFeedList[indexPath.row].pubDate!)
        } else{
            date = "Not Available"
        }
        var image = UIImage()
        if rssFeedList[indexPath.row].mediaThumbnail != nil{
            let url = NSURL(string: rssFeedList[indexPath.row].mediaThumbnail!)
            let data = NSData(contentsOf:url! as URL)
            if data != nil {
                image = UIImage(data:data! as Data)!
            } else {
                image = UIImage(named: "image5")!
            }
        } else {
            image = UIImage(named: "image5")!
        }
        
        
        cell = tableView.dequeueReusableCell(withIdentifier: "rssFeedCell", for: indexPath)
        cell?.textLabel?.text = rssFeedList[indexPath.row].title
        cell?.detailTextLabel!.numberOfLines = 2;
        cell?.imageView!.layer.cornerRadius = 35
        cell?.imageView!.clipsToBounds = true
        cell?.imageView?.image = resizeImage(CGSize(width: 70, height: 70), image: image)
        cell?.detailTextLabel?.text = "Date: \(date) \nAuthor:  \(String(describing: rssFeedList[indexPath.row].author ?? "Not Available" ))"
        
        return cell!
            
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rssItemToPass = rssFeedList[indexPath.row]
        self.performSegue(withIdentifier: "rssFeedSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is RSSFeedResultsViewController
        {
            let viewController = segue.destination as? RSSFeedResultsViewController
            viewController?.rssItemURL = (rssItemToPass?.link)!
        }
    }

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
    
    

}
