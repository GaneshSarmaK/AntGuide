//
//  Test2ViewController.swift
//  Cloudy
//
//  Created by Ganesh on 25/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit
import AlamofireImage
import OHMySQL
import Alamofire

class Test2ViewController: UIViewController, CAAnimationDelegate {

    var mask:CALayer?
    var window: UIWindow?
    var imageCache: AutoPurgingImageCache?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet var progresslabel: UILabel!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var downloadingIndicatorLabel: UILabel!
    @IBOutlet var downloaderTextLabel: UILabel!
    var count  = 0
    
    //Check is download is coplete and set it such that it doesn't download for 2nd time
    var downloadedItems: Int = 0{
        didSet{
            self.progresslabel.text = "\(downloadedItems)/112"
            progressView.progress = Float(downloadedItems) / 112
            
            if(downloadedItems == 112){
                UserDefaults.standard.set(true, forKey: "ResourcesDownloaded")
                downloaderTextLabel.text = "Download complete!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5){
                    self.presentTheRootController()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.loadGif(asset: "antGif")
        downloadData()
  }
   
    
    //MARK:- Download resources
    func downloadData(){
        
        if(UserDefaults.standard.bool(forKey: "ResourcesDownloaded")){
            self.downloadedItems = 112
            print("Already downloaded")
        } else {
            let user = OHMySQLUser(userName: "antGuideClient", password: "antGuide", serverName: "antdb.cgwmwabypjj0.ap-southeast-2.rds.amazonaws.com", dbName: "new", port: 3306, socket: nil)
            let coordinator = OHMySQLStoreCoordinator(user: user!)
            coordinator.encoding = .UTF8MB4
            coordinator.connect()
            
            let context = OHMySQLQueryContext()
            context.storeCoordinator = coordinator
            let filemanager = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            //Querying the SQL database and parsing results
            let query = OHMySQLQueryRequestFactory.select("ant1", condition: nil )
            let response = try? context.executeQueryRequestAndFetchResult(query)
            guard let responseObject = response else { return }
            for data in responseObject{
                let item = DBResponse(with: data)
                let path = filemanager.appendingPathComponent("\(String(describing: item.bioName)).jpg")
                if (!FileManager.default.fileExists(atPath: path.path)){
                    let urlRequest = URLRequest(url: URL(string: String(describing: item.image!))!)
                    Alamofire.request(urlRequest).responseImage { response in
                        if response.result.value != nil {
                            let image = UIImage(data: response.data!, scale: 1.0)!
                            image.saveToDocuments(filename: "\(item.bioName!).jpg")
                            self.downloadedItems = self.downloadedItems + 1
                            print(path.path)
                        }
                    }
                }
                else{
                    print(path.path)
                    self.downloadedItems = self.downloadedItems + 1
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 60, execute: {
                //if(!UserDefaults.standard.bool(forKey: "ResourcesDownloaded")){
                    for data in responseObject{
                        let item = DBResponse(with: data)
                        let path = filemanager.appendingPathComponent("\(String(describing: item.bioName!)).jpg")
                        if (!FileManager.default.fileExists(atPath: path.path)){
                            let urlRequest = URLRequest(url: URL(string: String(describing: item.image!))!)
                            Alamofire.request(urlRequest).responseImage { response in
                                if response.result.value != nil {
                                    let image = UIImage(data: response.data!, scale: 1.0)!
                                    image.saveToDocuments(filename: "\(item.bioName!).jpg")
                                    self.downloadedItems = self.downloadedItems + 1
                                    print(path.path)
                                }
                            }
                        }
                        else{
                            print(path.path)
                            self.downloadedItems = self.downloadedItems + 1
                        }
                    }
               // }
            })
            
        }
        
    }
    
// Reference from https://stackoverflow.com/a/41144822
    
    func presentTheRootController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "tabViewController")

        // Set the new rootViewController of the window.
        // Calling "UIView.transition" below will animate the swap.
        UIApplication.shared.windows.first?.rootViewController = vc
        
        // A mask of options indicating how you want to perform the animations.
        let options: UIView.AnimationOptions = .transitionCrossDissolve

        // The duration of the transition animation, measured in seconds.
        let duration: TimeInterval = 1
        
        // Creates a transition animation.
        // Though `animations` is optional, the documentation tells us that it must not be nil. ¯\_(ツ)_/¯
        UIView.transition(with: UIApplication.shared.windows.first!, duration: duration, options: options, animations: {}, completion:
        { completed in })
    }
    
    
}
