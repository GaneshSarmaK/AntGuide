//
//  TableViewCell.swift
//  Cloudy
//
//  Created by Ganesh on 23/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    //A closure property that is used to communicate between parent and child views
    var favButtonToggle : (() -> ())?

    //Storyboard elements
    @IBOutlet var favButtonBackView: UIView!
    @IBOutlet weak var antNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var isFavouriteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        favButtonBackView.backgroundColor = .clear
        favButtonBackView.layer.backgroundColor = UIColor.clear.cgColor
        antNameLabel.text = ""
        dateLabel.text = ""
        self.frame.size.width = 100
        favButtonBackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.favButtonTap(_:))))

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func favButtonClicked(_ sender: Any) {
        favButtonToggle?()
    }
    
    @objc func favButtonTap(_ gestureRecognizer: UITapGestureRecognizer){
        favButtonToggle?()
    }
    
    //A custom method that sets the cell's data from the data of parent view
    //@parameter:   antName     Name of the ant
    //@parameter:   date        Data of the record
    //@parameter:   isFavourite A boolean value that sets a history as fav or not
    func commInit(antName: String, date: String, isFavourite: Bool){
        antNameLabel.text = antName
        dateLabel.text = date
        if(isFavourite){
            favButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            favButton.tintColor = UIColor(hex: "E09F3E")
        }
        else {
            favButton.setImage(UIImage(systemName: "star"), for: .normal)
            favButton.tintColor = .lightGray
            
        }
    }
    
}

