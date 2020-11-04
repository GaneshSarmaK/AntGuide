//
//  PhotoSearchViewController.swift
//  Cloudy
//
//  Created by Ganesh on 20/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

// icons in this screen are from https://www.flaticon.com/authors/freepik

import UIKit
import BottomPopup
import SwiftyJSON

class PhotoSearchViewController: BottomPopupViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //Storyboard elements
    @IBOutlet weak var galleryLabel: UILabel!
    @IBOutlet weak var cameraLabel: UILabel!
    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    
    //variable declaration
    var cameraTapGesture = UITapGestureRecognizer()
    var galleryTapGesture = UITapGestureRecognizer()
    let session = URLSession.shared
    let imagePicker = UIImagePickerController()
    var googleAPIKey = "AIzaSyDFXremkEBiEN_y8QwLea_TIiBI9yF42BY"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    var image: UIImage = UIImage()

    //dismiss the view when tapped anywhere outside of the view
    @IBAction func dismissButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //override method to initialize the view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(self.view.subviews.count)
        //delegates
        imagePicker.delegate = self
        
        let yBound = UIScreen.main.bounds.width/2
        
        //CameraView options and customization
        let cameraSubView = UIImageView(image: UIImage(systemName: "camera")?.crop(to: CGSize(width: 30, height: 25)))
        cameraSubView.tintColor = UIColor.black
        cameraSubView.center = CGPoint(x: 38,y: 35)
        cameraView.addSubview(cameraSubView)
        cameraView.layer.cornerRadius = 38
        cameraView.frame = CGRect(x: yBound - 110, y: 50,  width: cameraView.frame.size.width + 10, height:  cameraView.frame.size.height + 10 )
        cameraTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.cameraViewTapped(_:)))
        cameraTapGesture.numberOfTapsRequired = 1
        cameraTapGesture.numberOfTouchesRequired = 1
        cameraView.addGestureRecognizer(cameraTapGesture)
        cameraView.isUserInteractionEnabled = true
        cameraView.layer.borderColor = UIColor.lightGray.cgColor
        cameraView.layer.borderWidth = 1
        cameraView.layer.shadowOpacity = 1
        cameraView.layer.shadowColor = UIColor.lightGray.cgColor
        cameraView.layer.shadowOffset = .init(width: 5, height: 5)
        cameraView.layer.shadowRadius = 3
        cameraView.layer.shadowPath = UIBezierPath(roundedRect: cameraView.bounds, cornerRadius: cameraView.layer.cornerRadius).cgPath
        cameraLabel.text = "Camera"
        cameraLabel.frame = CGRect(x: yBound - 115, y: 100,  width: cameraView.frame.size.width + 10, height:  cameraView.frame.size.height + 10 )
        
        
        //GalleryView options and customization
        let gallerySubView = UIImageView(image: UIImage(systemName: "photo.on.rectangle")!.crop(to: CGSize(width: 30, height: 25)))
        gallerySubView.tintColor = UIColor.black
        gallerySubView.center = CGPoint(x: 38,y: 38)
        galleryView.addSubview(gallerySubView)
        galleryView.layer.cornerRadius = 38
        galleryView.frame = CGRect(x: yBound + 37, y: 50, width: galleryView.frame.size.width + 10 , height:  galleryView.frame.size.height  + 10)
        galleryTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.galleryViewTapped(_:)))
        galleryTapGesture.numberOfTapsRequired = 1
        galleryTapGesture.numberOfTouchesRequired = 1
        galleryView.addGestureRecognizer(galleryTapGesture)
        galleryView.isUserInteractionEnabled = true
        galleryView.layer.borderColor = UIColor.lightGray.cgColor
        galleryView.layer.borderWidth = 1
        galleryView.layer.shadowOpacity = 1
        galleryView.layer.shadowColor = UIColor.lightGray.cgColor
        galleryView.layer.shadowOffset = .init(width: 5, height: 5)
        galleryView.layer.shadowRadius = 3
        galleryView.layer.shadowPath = UIBezierPath(roundedRect: galleryView.bounds, cornerRadius: galleryView.layer.cornerRadius).cgPath
        galleryLabel.text = "Gallery"
        galleryLabel.frame = CGRect(x: yBound + 30, y: 100, width: galleryView.frame.size.width + 10 , height:  galleryView.frame.size.height  + 10)
            
        dismissButton.frame = CGRect(x: UIScreen.main.bounds.width - 30, y: 10, width: dismissButton.frame.width, height: dismissButton.frame.height)
        dismissButton.tintColor = UIColor.red

        // Do any additional setup after loading the view.
    }
    
    //Gesture recognizer for camera function
    @objc func cameraViewTapped(_ sender: UITapGestureRecognizer) {

        let controller = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.sourceType = .camera
        } else {
            //if not availabale diplay an alert
            controller.sourceType = .photoLibrary
            let alertController = UIAlertController(title: "Alert!", message: "Camera Not Available. Please Select from Photo Library", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }

        controller.allowsEditing = false
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter( deadline: DispatchTime.now() + 5.0 ){
            //self.dismiss(animated: false, completion: nil)
        }
    }
    
    //Gesture recognizer for gallery function
    @objc func galleryViewTapped(_ sender: UITapGestureRecognizer) {

        let controller = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            controller.sourceType = .photoLibrary
            
        } else {
            //if not availabale diplay an alert
            let alertController = UIAlertController(title: "Alert!", message: "Photo Library Not Available.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        controller.allowsEditing = false
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter( deadline: DispatchTime.now() + 5.0 ){
            //self.dismiss(animated: false, completion: nil)
        }

    }
    
    //A delegate methof for an image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            image = pickedImage
        }
        let binaryImageData = base64EncodeImage(image)
        
        //send the data as a notification to the observer
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadForImageSearch"), object: binaryImageData)

        //createRequest(with: binaryImageData)
        

        
    }
    
    
    //Set of constraints for the popup view
    override var popupHeight: CGFloat { return CGFloat(200) }
    
    override var popupTopCornerRadius: CGFloat { return CGFloat(25) }
    
    override var popupPresentDuration: Double { return  0.3 }
    
    override var popupDismissDuration: Double { return  0.3 }
    
    override var popupShouldDismissInteractivelty: Bool { return false }
    
    override var popupDimmingViewAlpha: CGFloat { return 0.5 }
    

    
 
/// Analysing Photo results from Google Cloud Vison API response
    func analyzeResults(_ dataToParse: Data) {

        // Update UI on the main thread
        DispatchQueue.main.async(execute: {

            // Use SwiftyJSON to parse results
            var json: JSON = JSON()
            var errorObj: JSON = JSON()
            do{
                json = try JSON(data: dataToParse)
                errorObj = json["error"]
            }
            catch { print(" ") }

            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
                print("Error code \(errorObj["code"]): \(errorObj["message"])")
            } else {
                // Parse the respone
                // Get label annotations and web entities
                let parsedResponse = try? JSONDecoder().decode(JSONResponseData.self, from: dataToParse)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadImageSearchJSONData"), object: parsedResponse)
                //self.performSegue(withIdentifier: "searchToDetailSegue", sender: self)

            }
        })

    }

    //A custom function to resize the image as scaleToFIll aspect
    //@parameter: imageSize: required image size
    //@parameterL image:     the image object
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = newImage!.pngData()
        UIGraphicsEndImageContext()
        return resizedImage!
    }

    
/// Networking and setting paramets for API request
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = image.pngData()
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata!.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
}
