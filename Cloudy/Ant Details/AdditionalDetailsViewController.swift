//
//  AdditionalDetailsViewController.swift
//  Cloudy
//
//  Created by NVR4GET on 9/5/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

//MARK:- This Class is not used

import UIKit

class AdditionalDetailsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commonNameLabel: UILabel!
    @IBOutlet weak var bionameLabel: UILabel!
    @IBOutlet weak var dietDetailsLabel: UILabel!
    @IBOutlet weak var habitatDetailsLabel: UILabel!
    @IBOutlet weak var advantageDetailsLabel: UILabel!
    @IBOutlet weak var disadvatageDetailsLabel: UILabel!
    @IBOutlet weak var advantahePlaceholderImageView: UIImageView!
    @IBOutlet weak var advantagesLabel: UILabel!
    @IBOutlet weak var advantahesSeaparatorView: UIView!
    @IBOutlet weak var dietLabel: UILabel!
    @IBOutlet weak var dietSeaparatorView: UIView!
    @IBOutlet weak var disadvantagesLabel: UILabel!
    @IBOutlet weak var disadvantagesSeaparatorView: UIView!
    @IBOutlet weak var disadvantagePlaceholderImageView: UIImageView!
    @IBOutlet weak var habitatPlaceholderImageView: UIImageView!
    @IBOutlet weak var habitatLabel: UILabel!
    @IBOutlet weak var habitatSeparatorView: UIView!
    @IBOutlet weak var dietPlaceholderImageView: UIImageView!
    
    
    var antItem: DBResponse?
    
    
    //Loading the screen with data received
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: 1010)
        
        var stringArray: [String] = []
        stringArray = antItem?.diet!.components(separatedBy: "and") as! [String]
        var formattedString: String = ""
        for string in stringArray{
            var tempString = string.trimmingCharacters(in: NSCharacterSet.whitespaces)
            tempString = tempString.capitalizeFirstLetter()
            formattedString.append(tempString + "\n")
        }
        dietDetailsLabel.text = formattedString
        
        stringArray = antItem?.nestSite!.components(separatedBy: ",") as! [String]
        formattedString = ""
        for string in stringArray{
            var tempString = string.trimmingCharacters(in: NSCharacterSet.whitespaces)
            tempString =  tempString.capitalizeFirstLetter()
            formattedString.append(tempString + "\n")
        }
        habitatDetailsLabel.text = formattedString
        
        bionameLabel.text = antItem?.bioName
        commonNameLabel.text = antItem?.commonName
        if(antItem?.advantages != nil ){
            stringArray = antItem?.advantages!.components(separatedBy: ".") as! [String]
            formattedString = ""
            for string in stringArray{
                var tempString = string.trimmingCharacters(in: NSCharacterSet.whitespaces)
                tempString =  tempString.capitalizeFirstLetter()
                formattedString.append(tempString + "\n")
            }
            advantageDetailsLabel.text = formattedString
        } else {
            advantageDetailsLabel.text = "No Advantages observed for this Ant"

        }
        if(antItem?.disadvantages != nil ){
            disadvatageDetailsLabel.text = antItem?.disadvantages
        } else {
            disadvatageDetailsLabel.text = "No Disadvantages observed for this Ant"

        }
        imageView.layer.cornerRadius = 30
        
        let filemanager = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = filemanager.appendingPathComponent("\(String(describing: antItem!.bioName!)).jpg")
        if (FileManager.default.fileExists(atPath: path.path)){
            imageView.contentMode = .scaleToFill
            imageView.image = UIImage().getImage(imagePath: path)//.crop(to: CGSize(width: 500, height: 375))
        }
        
        dietLabel.sizeToFit()
        habitatDetailsLabel.sizeToFit()
        advantageDetailsLabel.sizeToFit()
        disadvatageDetailsLabel.sizeToFit()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is RSSFeedResultsViewController
        {
            let viewController = segue.destination as? RSSFeedResultsViewController
            viewController?.rssItemURL = String(describing: antItem?.details)
        }
    }
    

    /*

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension String{
     func capitalizeFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    mutating func capitalizeFirstLetter() {
        self = self.capitalizeFirstLetter()
    }
}
