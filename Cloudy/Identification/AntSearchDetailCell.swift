//
//  AntSearchDetailCell.swift
//  Cloudy
//
//  Created by Ganesh on 23/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit
import SwiftUI
import AlamofireImage
import Alamofire
import SwiftGifOrigin

class AntSearchDetailCell: UICollectionViewCell {

    //Storyboard elements
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var antLabel: UILabel!
    @IBOutlet weak var antBioNamelabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //variable declaration
    var isImageSet = false
    var imageCache: AutoPurgingImageCache?
    
    //Initialize the cell with data from the parent view
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        imageCache = appDelegate.imageCache
        imageView.clipsToBounds = true
        //imageView.image = UIImage(systemName: "ant")
        //imageView.tintColor = UIColor.lightGray
        imageView.layer.cornerRadius = 100
        imageView.setShadows()
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        // Initialization code
    }
    
    //Class methods that return the cell's id and class
    class var reuseIdentifier: String {
        return "antResultCell"
    }
    class var nibName: String {
        return "AntSearchDetailCell"
    }
    
    
    //A custom method to set data on to the cell grom the parent view
    //@parameter:   name:   name of the ant
    //@parameter:   image:  image of the ant
    func configureCell(name: String, image: String, bioName: String ){
        
        //self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y , width: 250, height: 250)
        imageView.clipsToBounds = true
        self.antBioNamelabel.text = bioName
        self.antLabel.text = name
        imageView.layer.cornerRadius = 20
        let filemanager = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = filemanager.appendingPathComponent("\(bioName).jpg")
        if (FileManager.default.fileExists(atPath: path.path)){
            imageView.contentMode = .scaleToFill
            imageView.image = UIImage().getImage(imagePath: path)//.crop(to: CGSize(width: 200, height: 152))
            activityIndicator.stopAnimating()
            isImageSet = true
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
        } else {
            setImageFromUrl(url: image, receivedImageView: imageView)

        }

    }

//    //A custom function to resize the image as scaleToFIll aspect
//    //@parameter: imageSize: required image size
//    //@parameterL image:     the image object
//    func resizeImage(_ imageSize: CGSize, image: UIImage) -> UIImage {
//        UIGraphicsBeginImageContext(imageSize)
//        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return newImage!
//    }
//
//
//    //Refrence: https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
//    //AN async way of getting data from the url and set it onto an image as a closure
//    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
//        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
//    }
//    func downloadImage(from url: URL) {
//        print("Download Started")
//        getData(from: url) { data, response, error in
//            guard let data = data, error == nil else { return }
//            print(response?.suggestedFilename ?? url.lastPathComponent)
//            print("Download Finished")
//            let downloadedImage = UIImage(data: data)?.crop(to: CGSize(width: 200, height: 150))
//            DispatchQueue.main.async() {
//                self.imageView.image = downloadedImage
//            }
//        }
//    }

}

//Reference:    https://stackoverflow.com/questions/32041420/cropping-image-with-swift-and-put-it-on-center-position
//An extension the viewcontroller for downloading the images asynchronously and setting them to the image cache of tha mobile
extension AntSearchDetailCell{
    
    //This method checks if the image is already in cache, if not then  it downloads from the web then sets it to the view
    //@parameter url:                A link to the image
    //@parameter receivedImageView:  The view in which the image should be placed.
    func setImageFromUrl(url: String, receivedImageView: UIImageView){
        DataRequest.addAcceptableImageContentTypes(["image/jpg"])
        let urlRequest = URLRequest(url: URL(string: url)!)
        if let image = imageCache!.image(withIdentifier: String(describing: urlRequest))
        {
            activityIndicator.stopAnimating()
            receivedImageView.contentMode = .scaleToFill
            receivedImageView.image = image//.crop(to: CGSize(width: 200, height: 150))
            receivedImageView.setShadows()
            isImageSet = true
            
        } else {
            Alamofire.request(urlRequest).responseImage { response in
                            if response.result.value != nil {
                                let image = UIImage(data: response.data!, scale: 1.0)!
                                self.imageCache!.add(image, withIdentifier: String(describing: urlRequest))
                                self.setImageFromCache(urlRequest: urlRequest, receivedImageView: receivedImageView )
                            }
            }
        }
    }
    func setImageFromCache(urlRequest: URLRequest, receivedImageView: UIImageView){
        if let image = imageCache!.image(withIdentifier: String(describing: urlRequest))
        {
            activityIndicator.stopAnimating()
            receivedImageView.contentMode = .scaleToFill
            receivedImageView.image = image//.crop(to: CGSize(width: 200, height: 150))
            receivedImageView.setShadows()
            isImageSet = true
        }
    }
    
    //A method to set the layouts and shadows when a cell is created
    override func layoutSubviews() {
        self.layer.cornerRadius = 30
        self.layer.borderWidth = 5.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
        
        // cell shadow section
        self.contentView.layer.cornerRadius = 30
        self.contentView.layer.borderWidth = 5.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowRadius = 3.0
        self.layer.shadowOpacity = 0.6
        self.layer.cornerRadius = 30
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
}

//extension UIImageView{
//    func setShadows(){
//        self.layer.cornerRadius = 15
//        self.layer.shadowOpacity = 1
//        self.layer.shadowColor = UIColor.lightGray.cgColor
//        self.layer.shadowOffset = .init(width: 5, height: 5)
//        self.layer.shadowRadius = 3
//        self.layer.borderWidth = 0.5
//        self.layer.borderColor = UIColor.lightGray.cgColor
//        self.layer.backgroundColor = UIColor.lightGray.cgColor
//        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
//    }
//}

extension UIImageView{
    
    func addLoadingGif(){
        self.clipsToBounds = true
        self.backgroundColor = .white
        self.loadGif(asset: "gif")
    }
}
