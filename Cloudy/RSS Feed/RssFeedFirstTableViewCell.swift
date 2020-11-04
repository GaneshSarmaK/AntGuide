//
//  RssFeedFirstTableViewCell.swift
//  Cloudy
//
//  Created by NVR4GET on 11/5/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit

class RssFeedFirstTableViewCell: UITableViewCell {
    
    @IBOutlet var backView: UIView!
    @IBOutlet var antImageview: UIImageView!
    //MARK:- First cell of the table view
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        antImageview.layer.cornerRadius = 30
//        antImageview.bounds = backView.bounds
//        antImageview.center.x = UIScreen.main.bounds.width/2
        backView.center.x = UIScreen.main.bounds.width/2
        backView.layer.cornerRadius = 30
        backView.layer.shadowOpacity = 1
        backView.layer.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        backView.layer.shadowColor = UIColor.lightGray.cgColor
        backView.layer.shadowOffset = .init(width: 5, height: 6)
        backView.layer.shadowRadius = 3
//      self.layer.backgroundColor = UIColor(hex: "FFF3B0").cgColor
        backView.layer.shadowPath = UIBezierPath(roundedRect: backView.bounds, cornerRadius: backView.layer.cornerRadius).cgPath
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
