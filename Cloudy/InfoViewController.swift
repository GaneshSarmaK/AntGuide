//
//  InfoViewController.swift
//  Cloudy
//
//  Created by Ganesh on 24/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import OHMySQL

class InfoViewController: UIViewController {

    //variable declaration
    var imageCache: AutoPurgingImageCache?
    
    //Storyboard elements
    @IBOutlet weak var collectionButton: UIButton!
    
    //Override method for the view to load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegates
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        imageCache = appDelegate.imageCache
        collectionButton.layer.cornerRadius = 20
        collectionButton.titleLabel?.textColor = .black
        
        //SQL database environment setup
        let user = OHMySQLUser(userName: "antGuideClient", password: "antGuide", serverName: "antdb.cgwmwabypjj0.ap-southeast-2.rds.amazonaws.com", dbName: "new", port: 3306, socket: nil)
        let coordinator = OHMySQLStoreCoordinator(user: user!)
        coordinator.encoding = .UTF8MB4
        coordinator.connect()
        
        let context = OHMySQLQueryContext()
        context.storeCoordinator = coordinator
        
        //SQL dabase quering and parsing results.
        let query = OHMySQLQueryRequestFactory.select("ant1", condition: nil )
        let response = try? context.executeQueryRequestAndFetchResult(query)
        guard let responseObject = response else { return }
        for data in responseObject{
            let item = DBResponse(with: data)
            setImageFromUrl(url: item.image!)
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension InfoViewController{
    
    
    func setImageFromUrl(url: String){
        
        let urlRequest = URLRequest(url: URL(string: url)!)
        if let _ = imageCache!.image(withIdentifier: String(describing: urlRequest))
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
}
