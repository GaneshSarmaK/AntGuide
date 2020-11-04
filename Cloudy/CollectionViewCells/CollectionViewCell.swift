//
//  CollectionViewCell.swift
//  Cloudy
//
//  Created by Ganesh on 17/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit
import SwiftUI
import Alamofire
import AlamofireImage
import CollectionViewPagingLayout

class CollectionViewCell: UICollectionViewCell {

    var imageCache: AutoPurgingImageCache?
    let imageSize: CGSize = CGSize(width: 150, height: 150)
    var isImageSet = false

    //Storyboard elements

    @IBOutlet weak var BackView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Initialization method for the cell
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        imageCache = appDelegate.imageCache
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        imageView.center.x = self.contentView.center.x
        textLabel.center.x = self.contentView.center.x
        // Initialization code
    }
    
    //Setting cell laytouts and shadows
    override func layoutSubviews() {
        // cell rounded section
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
        imageView.center.x = self.contentView.center.x
        textLabel.center.x = self.contentView.center.x
    }
    
    //Cell's identifier and class
    class var reuseIdentifier: String {
        return "collectionViewCell"
    }
    class var nibName: String {
        return "CollectionViewCell"
    }
    
    //A custom method to set data to the cell from the parent view.
    //@parameter：   name    Name of the anr
    //@parameter    image    Ant's image url
    func configureCell(name: String, image: String, bioName: String, size: CGSize) {
        
        activityIndicator.startAnimating()
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        self.textLabel.text = name
        let filemanager = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = filemanager.appendingPathComponent("\(bioName).jpg")
        if (FileManager.default.fileExists(atPath: path.path)){
            imageView.contentMode = .scaleToFill
            imageView.image = UIImage().getImage(imagePath: path)//.crop(to: CGSize(width: 200, height: 152))
            imageView.center.x = self.contentView.center.x
            textLabel.center.x = self.contentView.center.x
            activityIndicator.stopAnimating()
            isImageSet = true
        } else {
            setImageFromUrl(url: image, receivedImageView: imageView)
        }
        imageView.center.x = self.contentView.center.x
        textLabel.center.x = self.contentView.center.x
        self.frame.size = size
        
        
    }

}

//An extension the viewcontroller for downloading the images asynchronously and setting them to the image cache of tha mobile

extension CollectionViewCell{
    
    
    //This method checks if the image is already in cache, if not then  it downloads from the web then sets it to the view
    //@parameter url:                A link to the image
    //@parameter receivedImageView:  The view in which the image should be placed.
    func setImageFromUrl(url: String, receivedImageView: UIImageView){
        DataRequest.addAcceptableImageContentTypes(["image/jpg"])
        let urlRequest = URLRequest(url: URL(string: url)!)
        if let image = imageCache!.image(withIdentifier: String(describing: urlRequest))
        {
            activityIndicator.stopAnimating()
            DispatchQueue.main.async {
                receivedImageView.contentMode = .scaleToFill
                receivedImageView.image = image//.crop(to: CGSize(width: 200, height: 150))
            }
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
            DispatchQueue.main.async {
                receivedImageView.contentMode = .scaleToFill
                receivedImageView.image = image//.crop(to: CGSize(width: 200, height: 150))
            }
            receivedImageView.setShadows()
            isImageSet = true
        }
    }
}
