//
//  CollectionViewCell2.swift
//  Cloudy
//
//  Created by Ganesh on 17/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit

class CollectionViewCell2: UICollectionViewCell {

    //Storyboard elements
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    //Initialization method for the cell
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(cellSelectionChanged), name: NSNotification.Name(rawValue: "cellSelectionChanged"), object: nil)

        // Initialization code
    }
    
    //A method that is invoked when a cell is selected naturally
    override var isSelected: Bool{
    didSet(newValue){
        //if cell is selected
        if(newValue){
            self.formatSubiews()
            self.layer.borderWidth = 3
            self.layer.borderColor = UIColor.white.cgColor
            self.categoryLabel.textColor = .black
            self.categoryLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            
        //if not selected
        } else {
            self.formatSubiews()
            self.categoryLabel.textColor = .black
            self.categoryLabel.font = UIFont.systemFont(ofSize: 17)

        }
    }
}
    
    //Cell's identifier and class
    class var reuseIdentifier: String {
        return "collectionViewCell2"
    }
    class var nibName: String {
        return "CollectionViewCell2"
    }
    
    
    //Setting cell layouts and subviews
     func formatSubiews() {
        self.layer.cornerRadius = self.frame.height/2
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.cgColor

        // cell shadow section
        self.contentView.layer.cornerRadius = self.frame.height/2
        self.contentView.layer.borderWidth = 0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowRadius = 3.0
        self.layer.shadowOpacity = 0.6
        self.layer.cornerRadius = self.frame.height/2
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath

    }
    
    //A custom method to set data to the cell from the parent view.
    //@parameter：   name    Name of the anr
    //@parameter    image    Ant's image url
    func configureCell(categoryName: String, color: UIColor) {
        
        self.backgroundImage.isHidden = true
        self.backgroundColor = .clear
        self.categoryLabel.center = self.contentView.center
        //let size = CGSize(width: categoryLabel.size(withAttributes: nil).width + 10, height: 3)
        categoryLabel.text = categoryName
        if (color == UIColor.clear){
            self.backgroundImage.isHidden = false
            self.backgroundImage.alpha = 0.7
        } else {
            self.backgroundColor = color.withAlphaComponent(0.7)
        }
    }
    
    //An object funtion that is called when a cell selection is changed manually
    @objc func cellSelectionChanged(notification: Notification)
    {
        //if cell is selected
        if(self.isSelected){
            self.formatSubiews()
            self.layer.borderWidth = 3
            self.layer.borderColor = UIColor.white.cgColor
            self.categoryLabel.textColor = .black
            self.categoryLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            
        //if not selected
        } else {
            self.formatSubiews()
            self.categoryLabel.textColor = .black
            self.categoryLabel.font = UIFont.systemFont(ofSize: 17)

        }
    }
    
}
