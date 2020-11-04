//
//  AntTagsCollectionViewCell.swift
//  Cloudy
//
//  Created by NVR4GET on 18/5/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit

class AntTagsCollectionViewCell: UICollectionViewCell {

    //Storyboard elements

    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var backView: UIImageView!
    
    //Initialization method for the cell

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.cornerRadius = self.backView.frame.size.height/2
        // Initialization code
    }
    
    //Cell's identifier and class

    class var reuseIdentifier: String {
        return "AntTagsCollectionViewCell"
    }
    class var nibName: String {
        return "AntTagsCollectionViewCell"
    }
    
    //A custom method to set data to the cell from the parent view.
    //@parameter：   tag    The category selected
    //@parameter    image   Icon for the selected category
    
    func configureCell(tag: String, color: String) {
        
        self.backView.image = nil
        self.backView.backgroundColor = .clear
        
        if(color == "clear"){
            self.backView.image = UIImage(named: "colors")
            self.backView.contentMode = .scaleToFill
        } else {
            self.backView.backgroundColor = UIColor(hex: color).withAlphaComponent(0.7)

        }
        self.tagLabel.text = tag
        self.tagLabel.frame = self.contentView.frame
        
    }

}
