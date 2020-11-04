//
//  GenericAntInfoCollectionViewCell.swift
//  Cloudy
//
//  Created by NVR4GET on 16/5/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit
import SnapLikeCollectionView

class GenericAntInfoCollectionViewCell: UICollectionViewCell, SnapLikeCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
   
    override var isSelected: Bool{
        didSet{
            if(self.isSelected){
                self.contentView.layer.borderColor = UIColor(hex: "E09F3E").cgColor
                self.imageView.alpha = 1
            } else {
                self.contentView.layer.borderColor = UIColor.lightGray.cgColor
                self.imageView.alpha = 0.6
            }
        }
    }
    //A delegate method of the SnapLikeCollectionView
    var item: String? {
        didSet {
            self.contentView.layer.cornerRadius = 40
            imageView.image = UIImage(named: item!)
            imageView.contentMode = .scaleAspectFill
            imageView.frame.size = CGSize(width: 50, height: 50)
            imageView.center = self.contentView.center
            imageView.tintColor = .gray
        }
    }
    
    //Initialization method for the cell
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.borderWidth = 3
        self.contentView.layer.borderColor = UIColor.orange.cgColor
        imageView.contentMode = .scaleAspectFill
        imageView.frame.size = CGSize(width: 50, height: 50)
        imageView.center = self.contentView.center
         NotificationCenter.default.addObserver(self, selector: #selector(cellSelectionChanged), name: NSNotification.Name(rawValue: "cellSelectionChanged"), object: nil)
        // Initialization code
    }
    
    //A method that is invoked when a cell is selected manually via a notification object
    @objc func cellSelectionChanged(notification: Notification)
    {
        if(self.isSelected){
            self.contentView.layer.borderColor = UIColor(hex: "E09F3E").cgColor
            self.imageView.alpha = 1
        } else {
            self.contentView.layer.borderColor = UIColor.lightGray.cgColor
            self.imageView.alpha = 0.6

        }
    }
    
    //Cell's identifier and class
    class var reuseIdentifier: String {
        return "GenericAntInfoCollectionViewCell"
    }
    class var nibName: String {
        return "GenericAntInfoCollectionViewCell"
    }
}
