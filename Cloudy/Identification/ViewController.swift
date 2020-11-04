import UIKit
import SwiftyJSON
import BottomPopup


protocol PhotoSelectedDelegate: class {
    func startAnimating(sender: PhotoSearchViewController)
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //variable declaration
    let imagePicker = UIImagePickerController()
    let session = URLSession.shared
    var image: UIImage = UIImage()
    var response: JSONResponseData?
    
    //Storyboard elements
    @IBOutlet weak var antImageView: UIImageView!
    @IBOutlet weak var imageViewforFeatureView: UIImageView!
    @IBOutlet weak var imageViewforCameraView: UIImageView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var featureSearchView: UIView!
    @IBOutlet weak var imageSearchView: UIView!
    @IBOutlet var backgroundImageView: UIImageView!
    
    //Gogle CLoud Vision API and Key
    var googleAPIKey = "AIzaSyDFXremkEBiEN_y8QwLea_TIiBI9yF42BY"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    //Override method for a view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tempFrame = imageSearchView.frame
        antImageView.loadGif(asset: "antGif")

        //adding constraints of the featureSearch subview
        //featureSearchView.frame = CGRect(x: UIScreen.main.bounds.width/2 - tempFrame.width/2 - 50, y: imageSearchView.frame.origin.y + (imageSearchView.frame.height * 3 / 2)  , width: tempFrame.width + 100, height: tempFrame.height)
        imagePicker.delegate = self
        featureSearchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tap(_:))))
        featureSearchView.isUserInteractionEnabled = true
        
        
        //adding constraints of the imagSearch subview
        //imageSearchView.frame = CGRect(x: UIScreen.main.bounds.width/2 - tempFrame.width/2 - 50, y: UIScreen.main.bounds.height/2 - tempFrame.height/2, width: tempFrame.width + 100, height: tempFrame.height)
        tempFrame = featureSearchView.frame
        imageSearchView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tap(_:))))
        imageSearchView.isUserInteractionEnabled = true
        


//        navigationController?.navigationBar.prefersLargeTitles = true
//        let appearance = UINavigationBarAppearance()
//        appearance.titleTextAttributes = [.backgroundColor: UIColor.white] // With a red background, make the title more readable.
//        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.orange]
//
        //self.navigationController!.view.backgroundColor = UIColor.yellow

        //A notification observer that is triggered on electing an image using camera or galery
        NotificationCenter.default.addObserver(self, selector: #selector(loadImageSearchJSONData), name: NSNotification.Name(rawValue: "loadForImageSearch"), object: nil)
        
    }
     
    
    
    
    //Setting shadows and other visual modifications
    override func viewDidLayoutSubviews() {
        imageSearchView.layer.borderWidth = 1
        imageSearchView.layer.borderColor = UIColor.clear.cgColor
        imageSearchView.layer.cornerRadius = 15
        imageSearchView.layer.shadowOpacity = 1
        imageSearchView.layer.shadowColor = UIColor.lightGray.cgColor
        imageSearchView.layer.shadowOffset = .init(width: 5, height: 5)
        imageSearchView.layer.shadowRadius = 2
        imageSearchView.layer.backgroundColor = UIColor(hex: "FFF3B0").cgColor
        imageSearchView.layer.shadowPath = UIBezierPath(roundedRect: imageSearchView.bounds, cornerRadius: imageSearchView.layer.cornerRadius).cgPath
        
        featureSearchView.layer.borderWidth = 1
        featureSearchView.layer.borderColor = UIColor.clear.cgColor
        featureSearchView.layer.cornerRadius = 15
        featureSearchView.layer.shadowColor = UIColor.lightGray.cgColor
        featureSearchView.layer.shadowOpacity = 1
        featureSearchView.layer.shadowOffset = .init(width: 5, height: 5)
        featureSearchView.layer.shadowRadius = 3
        featureSearchView.layer.backgroundColor = UIColor(hex: "C3C355").cgColor
        featureSearchView.layer.shadowPath = UIBezierPath(roundedRect: featureSearchView.bounds, cornerRadius: featureSearchView.layer.cornerRadius).cgPath
    }
    
    override func viewWillAppear(_ animated: Bool) {
       //self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

    }
///Receiving the image from photo or library
//    @IBAction func cameraButtonClicked(_ sender: Any) {
//        let controller = UIImagePickerController()
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            controller.sourceType = .camera
//        } else {
//            controller.sourceType = .photoLibrary
//            let alertController = UIAlertController(title: "Alert!", message: "Camera Not Available. Please Select from Photo Library", preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
//            self.present(alertController, animated: true, completion: nil)
//        }
//
//        controller.allowsEditing = false
//        controller.delegate = self
//        self.present(controller, animated: true, completion: nil)
//
//    }
//
//    @IBAction func photoLibraryButtonClicked(_ sender: Any) {
//        let controller = UIImagePickerController()
//        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//            controller.sourceType = .photoLibrary
//        } else {
//
//            let alertController = UIAlertController(title: "Alert!", message: "Photo Library Not Available.", preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
//            self.present(alertController, animated: true, completion: nil)
//        }
//        controller.allowsEditing = false
//        controller.delegate = self
//        self.present(controller, animated: true, completion: nil)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let pickedImage = info[.originalImage] as? UIImage {
//            image = pickedImage
//        }
//        dismiss(animated: true, completion: nil)
//        let binaryImageData = base64EncodeImage(image)
//        animationDelegate?.startAnimating()
//
//        //createRequest(with: binaryImageData)
//
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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
                self.response = parsedResponse
                
                //call the notification here and catch it else where
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadParsedJSONData"), object: parsedResponse)
            }
        })
    }

    //A custom method that resizes an images without cropping as a scale to fill aspect
    //@paramaters:  imageSize              The required size of the image
    //@paramaters:  image                  An image object
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = newImage!.pngData()
        UIGraphicsEndImageContext()
        return resizedImage!
    }

    
//MARK:- Networking and setting parameters for API request
    //A method that converts the image into a string for the API
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
    
    //create a request with options to ask the API
    func createRequest(with imageBase64: String) {
        
        // Create our request URL
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request (Web detection and Label Detection)
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 5
                    ],
                    [
                        "type": "WEB_DETECTION",
                        "maxResults": 5
                    ]
                ]
            ]
        ]
        let jsonObject = JSON(jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        
        // Run the request on a background thread
        DispatchQueue.global().async { self.runRequestOnBackgroundThread(request) }
    }
    
    //Running the request in the background.
    func runRequestOnBackgroundThread(_ request: URLRequest) {
       
        // run the request
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            var json: JSON = JSON()
            var errorObj: JSON = JSON()
            do{
                json = try JSON(data: data)
                errorObj = json["error"]
                print(error)
            }
            catch { print(" ") }
            
            self.analyzeResults(data)
        }
        
        task.resume()
    }
    
    //A tap gesture recognizer that either pops up a  new view controller or replaces another view controler
    @objc func tap(_ gestureRecognizer: UITapGestureRecognizer){
        let tag = gestureRecognizer.view?.tag
        //go to feature search Page on click
        if tag == 1 {
            self.performSegue(withIdentifier: "featureSearchSegue", sender: self)
        }
        //go to the gallery and camera popup on click
        if tag == 2 {
            guard let popupVC = storyboard?.instantiateViewController(withIdentifier: "secondVC") as? PhotoSearchViewController else { return }
            self.present(popupVC, animated: true, completion: nil)
        }
    }
    
    //A custom method that parses the response from the api and send it to the results view controller
    @objc func loadImageSearchJSONData(notification: Notification)
    {
        let binaryImageData = notification.object as! String
        let vc = PhotoSearchViewController()
        //vc.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
        createRequest(with: binaryImageData)
        //change this to your class name
        self.performSegue(withIdentifier: "imageToSearchResultsSegue", sender: self)

    }
    
    @objc func noAntFound(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //preparing and setting up options and other detials for the ant results.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AntDetailsViewController
        {
            let viewController = segue.destination as? AntDetailsViewController
            DispatchQueue.main.async {
                viewController?.response = self.response
                viewController?.triggerDataStore = true
                viewController?.isImageSearch = true
            }
        }
    }

}



///JSON parsing Codable structures
struct JSONResponseData: Codable{
    let responses: [Response]
}

struct Response: Codable{
    let webDetection: webDetection
    let labelAnnotations: [labelAnnotation]
}

struct webDetection: Codable {
    let bestGuessLabels: [bestGuessLabel]
    let webEntities: [webEntity]
}

struct bestGuessLabel: Codable{
    let label: String?
    let languageCode: String?
}

struct webEntity: Codable{
    let description: String?
}

struct labelAnnotation: Codable{
    let description: String?
    let score: Double?
}

extension UIImage {

    
    func saveToDocuments(filename:String) -> URL {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        if let data = self.jpegData(compressionQuality: 1.0) {
            do {
                if (!FileManager.default.fileExists(atPath: fileURL.path)){
                    appDelegate.imageUrls.append(fileURL.path)
                    try data.write(to: fileURL)
                }
            } catch {
                print("error saving file to documents:", error)
            }
        }
        return fileURL
    }
    
    func getImage(imagePath: URL) -> UIImage{
        if let image = UIImage(contentsOfFile: imagePath.path) {
            return image
        } else {
               fatalError("Can't create image from file \(imagePath)")
        }
    }

//Reference: https://stackoverflow.com/questions/32041420/cropping-image-with-swift-and-put-it-on-center-position
//An extension to UIImage to crop the image keeping the aspect ratio.
    func crop(to:CGSize) -> UIImage {

        guard let cgimage = self.cgImage else { return self }

        let contextImage: UIImage = UIImage(cgImage: cgimage)

        guard let newCgImage = contextImage.cgImage else { return self }

        let contextSize: CGSize = contextImage.size

        //Set to square
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cropAspect: CGFloat = to.width / to.height

        var cropWidth: CGFloat = to.width
        var cropHeight: CGFloat = to.height

        if to.width > to.height { //Landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2
        } else if to.width < to.height { //Portrait
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            posX = (contextSize.width - cropWidth) / 2
        } else { //Square
            if contextSize.width >= contextSize.height { //Square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                posX = (contextSize.width - cropWidth) / 2
            }else{ //Square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                posY = (contextSize.height - cropHeight) / 2
            }
        }

        let rect: CGRect = CGRect(x: posX, y: posY, width: cropWidth, height: cropHeight)

        // Create bitmap image from context using the rect
        guard let imageRef: CGImage = newCgImage.cropping(to: rect) else { return self}

        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)

        UIGraphicsBeginImageContextWithOptions(to, false, self.scale)
        cropped.draw(in: CGRect(x: 0, y: 0, width: to.width, height: to.height))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resized ?? self
      }
}



