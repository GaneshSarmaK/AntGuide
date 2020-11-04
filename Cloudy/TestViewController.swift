//
//  TestViewController.swift
//  Cloudy
//
//  Created by Ganesh on 21/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class TestViewController: UIViewController {

    var imageCache: AutoPurgingImageCache?


    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        imageCache = appDelegate.imageCache
        
        
        
        
        
//        setImageFromUrl(url: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/LARGE_elevation.jpg/800px-LARGE_elevation.jpg", receivedImageView: imageView)
//
//
//        setImageFromUrl(url: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/LARGE_elevation.jpg/800px-LARGE_elevation.jpg", receivedImageView: imageView2)
        
    }
    
    
    func setImageFromUrl(url: String, receivedImageView: UIImageView){
        let urlRequest = URLRequest(url: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/LARGE_elevation.jpg/800px-LARGE_elevation.jpg")!)
        if let image = imageCache!.image(withIdentifier: String(describing: urlRequest))
        {
            self.imageView.image = image
        } else {
            Alamofire.request(urlRequest).responseImage { response in
                            if response.result.value != nil {
                                let image = UIImage(data: response.data!, scale: 1.0)!
                                self.imageCache!.add(image, withIdentifier: String(describing: urlRequest))
                                receivedImageView.image = image
                                self.setImageFromCache(urlRequest: urlRequest, receivedImageView: receivedImageView )
                            }
            }
        }
    }
    
    @IBAction func something(_ sender: Any) {
        let path = imageView2.image?.saveToDocuments(filename: "NormalAnts.jpg")
        
        imageView.image = UIImage().getImage(imagePath: path!)
    }
    
    func setImageFromCache(urlRequest: URLRequest, receivedImageView: UIImageView){
        if let image = imageCache!.image(withIdentifier: String(describing: urlRequest))
        {
            self.image = image
            image.saveToDocuments(filename: urlRequest.url!.absoluteString)
            receivedImageView.image = image
            receivedImageView.frame = CGRect(x: 100, y: 100, width: 200, height: 200)
            receivedImageView.backgroundColor = .lightGray
            receivedImageView.layer.cornerRadius = 20
        }
    }
    
    

}


