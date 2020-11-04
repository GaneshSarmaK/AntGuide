//
//  AppDelegate.swift
//  Cloudy
//
//  Created by Ganesh on 11/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import OHMySQL

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CAAnimationDelegate {

    //variables for use throughout the application
    var databaseController: DatabaseProtocol?
    var imageCache: AutoPurgingImageCache?
    var imageUrls: [String] = []
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //initializing the variables for future use
        databaseController = CoreDataController()
        imageCache = AutoPurgingImageCache( memoryCapacity: 100_000_000, preferredMemoryUsageAfterPurge: 60_000_000)
        
        downloadData()
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .semibold), NSAttributedString.Key.foregroundColor: UIColor(hex: "46230D")]
        UINavigationBar.appearance().titleTextAttributes = attributes
        //setting the navihation bar color to a constant throught the application
        //UITabBar.appearance().barTintColor = UIColor(hex: "46230D").withAlphaComponent(0.8)
        return true
        
    }
    
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    
    //A method to download the initial resources required for smooth application execution.
    func downloadData(){
        var count = 1
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
            count = count + 1
            let urlRequest = URLRequest(url: URL(string: item.image!)!)
            Alamofire.request(urlRequest).responseImage { response in
                if response.result.value != nil {
                    let image = UIImage(data: response.data!, scale: 1.0)!
                    image.saveToDocuments(filename: "\(item.bioName!).jpg")
                }
            }
        }
    }
}



