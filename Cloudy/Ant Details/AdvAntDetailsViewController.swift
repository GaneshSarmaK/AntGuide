//
//  AdvAntDetailsViewController.swift
//  Cloudy
//
//  Created by NVR4GET on 17/5/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit

class AdvAntDetailsViewController: UIViewController {

    
    //Storyboard elements
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commonNameLabel: UILabel!
    @IBOutlet weak var bioNameLabel: UILabel!
    @IBOutlet weak var dietView: UIView!
    @IBOutlet weak var dietViewHiddenView: UIView!
    @IBOutlet weak var dietDetailsLabel: UILabel!
    @IBOutlet weak var habitatView: UIView!
    @IBOutlet weak var habitatViewHiddenView: UIView!
    @IBOutlet weak var habitatDetailsLabel: UILabel!
    @IBOutlet weak var advantagesView: UIView!
    @IBOutlet weak var advantagesViewHiddenView: UIView!
    @IBOutlet weak var advantageDetailsLabel: UILabel!
    @IBOutlet weak var disadvantageDetailsLabel: UILabel!
    @IBOutlet weak var disadvantagesViewHiddenView: UIView!
    @IBOutlet weak var disadvantageView: UIView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    //Animations for the title of each card
    var selectedView: Int = 0 {
        didSet {
            UIView.animate(withDuration: 0.4, animations: {
                if (self.selectedView == 1) {
                    self.dietViewHiddenView.isHidden = true
                    self.habitatViewHiddenView.isHidden = false
                    self.advantagesViewHiddenView.isHidden = false
                    self.disadvantagesViewHiddenView.isHidden = false
                }
                
                if (self.selectedView == 2) {
                    self.dietViewHiddenView.isHidden = false
                    self.habitatViewHiddenView.isHidden = true
                    self.advantagesViewHiddenView.isHidden = false
                    self.disadvantagesViewHiddenView.isHidden = false
                }
                
                if (self.selectedView == 3) {
                    self.dietViewHiddenView.isHidden = false
                    self.habitatViewHiddenView.isHidden = false
                    self.advantagesViewHiddenView.isHidden = true
                    self.disadvantagesViewHiddenView.isHidden = false
                }
                
                if (self.selectedView == 4) {
                    self.dietViewHiddenView.isHidden = false
                    self.habitatViewHiddenView.isHidden = false
                    self.advantagesViewHiddenView.isHidden = false
                    self.disadvantagesViewHiddenView.isHidden = true
                }
            })
        }
    }
    
    //Variable declaration
    var topLimit : CGFloat = 0.0
    var bottomLimit : CGFloat = 0.0
    var antItem: DBResponse?
    var antWikiLink: String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //configuring the initial setup and placement of cards
        dietViewHiddenView.isHidden = false
        habitatViewHiddenView.isHidden = false
        advantagesViewHiddenView.isHidden = false
        disadvantagesViewHiddenView.isHidden = false

        antWikiLink = antItem!.details!
        topLimit = self.view.center.y + 20
        bottomLimit = self.view.frame.height - 100
        
        dietView.layer.cornerRadius = 25
        habitatView.layer.cornerRadius = 25
        advantagesView.layer.cornerRadius = 25
        disadvantageView.layer.cornerRadius = 25
        
        dietView.layer.borderColor = UIColor.lightGray.cgColor
        habitatView.layer.borderColor = UIColor.lightGray.cgColor
        advantagesView.layer.borderColor = UIColor.lightGray.cgColor
        disadvantageView.layer.borderColor = UIColor.lightGray.cgColor
        
        dietView.layer.borderWidth = 0.5
        habitatView.layer.borderWidth = 0.5
        advantagesView.layer.borderWidth = 0.5
        disadvantageView.layer.borderWidth = 0.5

        dietDetailsLabel.text = antItem?.diet
        habitatDetailsLabel.text = antItem?.nestSite
        advantageDetailsLabel.text = antItem?.advantages
        disadvantageDetailsLabel.text = antItem?.disadvantages
        
        imageView.layer.cornerRadius = 30
        
        let filemanager = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = filemanager.appendingPathComponent("\(String(describing: antItem!.bioName!)).jpg")
        if (FileManager.default.fileExists(atPath: path.path)){
            imageView.contentMode = .scaleToFill
            imageView.image = UIImage().getImage(imagePath: path)//.crop(to: CGSize(width: 500, height: 375))
        }
        commonNameLabel.text = antItem?.commonName
        bioNameLabel.text = antItem?.bioName

        addTapGestures()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        selectedView = 1
        dietView.frame.origin.y = topLimit
        habitatView.frame.origin.y = bottomLimit - CGFloat( 3 * 40)
        advantagesView.frame.origin.y = bottomLimit - CGFloat( 2 * 40)
        disadvantageView.frame.origin.y = bottomLimit - CGFloat( 1 * 40)
    }
    
    //MARK:- Gestures and Animations
    func addTapGestures(){
        var tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapForDietView(_:)))
        dietView.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapForHabitatView(_:)))
        habitatView.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapForAdvantageView(_:)))
        advantagesView.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapForDisadvantageView(_:)))
        disadvantageView.addGestureRecognizer(tap)
    }
    
    @objc func handleTapForDietView(_ sender: UITapGestureRecognizer? = nil) {
        if(selectedView != 1){
            UIView.animate(withDuration: 0.4, animations: {
                self.dietView.frame.origin.y = self.topLimit
                self.habitatView.frame.origin.y = self.bottomLimit - CGFloat( 3 * 40)
                self.advantagesView.frame.origin.y = self.bottomLimit - CGFloat( 2 * 40)
                self.disadvantageView.frame.origin.y = self.bottomLimit - CGFloat( 1 * 40)
                self.selectedView = 1
            })
        }
    }
    
    @objc func handleTapForHabitatView(_ sender: UITapGestureRecognizer? = nil) {
        if(selectedView != 2){
            UIView.animate(withDuration: 0.4, animations: {
                self.dietView.frame.origin.y = self.topLimit
                self.habitatView.frame.origin.y = self.topLimit + CGFloat( 1 * 40)
                self.advantagesView.frame.origin.y = self.bottomLimit - CGFloat( 2 * 40)
                self.disadvantageView.frame.origin.y = self.bottomLimit - CGFloat( 1 * 40)
                self.selectedView = 2
            })
        }
    }
    
    @objc func handleTapForAdvantageView(_ sender: UITapGestureRecognizer? = nil) {
        if(selectedView != 3){
            UIView.animate(withDuration: 0.4, animations: {
                self.dietView.frame.origin.y = self.topLimit
                self.habitatView.frame.origin.y = self.topLimit + CGFloat( 1 * 40)
                self.advantagesView.frame.origin.y = self.topLimit + CGFloat( 2 * 40)
                self.disadvantageView.frame.origin.y = self.bottomLimit - CGFloat( 1 * 40)
                self.selectedView = 3
            })
        }
    }
    
    @objc func handleTapForDisadvantageView(_ sender: UITapGestureRecognizer? = nil) {
        if(selectedView != 4){
            UIView.animate(withDuration: 0.4, animations: {
                self.dietView.frame.origin.y = self.topLimit
                self.habitatView.frame.origin.y = self.topLimit + CGFloat( 1 * 40)
                self.advantagesView.frame.origin.y = self.topLimit + CGFloat( 2 * 40)
                self.disadvantageView.frame.origin.y = self.topLimit + CGFloat( 3 * 40)
                self.selectedView = 4
            })
        }
    }

    @IBAction func antWikiLinkButtonClicked(_ sender: Any) {
        print(true)
        performSegue(withIdentifier: "showAntWikiWebView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is RSSFeedResultsViewController
        {
            let viewController = segue.destination as? RSSFeedResultsViewController
            viewController?.rssItemURL = antWikiLink
        }
    }
    
    // MARK: - Swipe Gestures

    @IBAction func handleUpSwipe(_ gesture: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.4, animations: {
            if (self.selectedView == 1){
                self.habitatView.frame.origin.y = self.dietView.frame.origin.y + 40
                self.selectedView = 2
                return
            }
            if (self.selectedView == 2){
                self.advantagesView.frame.origin.y = self.habitatView.frame.origin.y + 40
                self.selectedView = 3
                return
            }
            if (self.selectedView == 3){
                self.disadvantageView.frame.origin.y = self.advantagesView.frame.origin.y + 40
                self.selectedView = 4
                return
            }
        })
    }
    
    @IBAction func handleDownSwipe(_ gesture: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.4, animations: {
            if (self.selectedView == 4){
                self.disadvantageView.frame.origin.y = self.bottomLimit - 30
                self.selectedView = 3
                return
            }
            if (self.selectedView == 3){
                self.advantagesView.frame.origin.y = self.disadvantageView.frame.origin.y - 40
                self.selectedView = 2
                return
            }
            if (self.selectedView == 2){
                self.habitatView.frame.origin.y = self.advantagesView.frame.origin.y - 40
                self.selectedView = 1
                return
            }
        })
    }

}
