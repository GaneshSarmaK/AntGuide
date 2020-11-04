//
//  SearchViewController.swift
//  Cloudy
//
//  Created by Ganesh on 12/4/20.
//  Copyright © 2020 Ganesh. All rights reserved.
//

import UIKit
import SwiftUI
import MKColorPicker

extension UIButton{
    func addShadows( borderColor: UIColor, backgroundColor: UIColor){
        self.layer.shadowOpacity = 1
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = .init(width: 5, height: 5)
        self.layer.shadowRadius = 3
        self.layer.borderWidth = 0.5
        self.layer.borderColor = borderColor.cgColor
        self.layer.backgroundColor = backgroundColor.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
    }
}

//Golbal variable for ease of access
var fruitList = ["Red", "Black", "Brown", "Grey", "Green", "Blue", "Yellow", "Orange"]
var colorsList = [UIColor.black:"Black", UIColor.systemYellow:"Yellow", UIColor.systemOrange:"Orange", UIColor.systemRed:"Red", UIColor.brown:"Brown", UIColor.gray:"Gray", UIColor.systemGreen:"Green", UIColor(red: 8/255, green: 3/255, blue: 110/255, alpha: 1):"Blue"]
//var options = ["Yes", "No", "Not Sure"]
var isAdvOptionsHidden : Bool = true

var isProgressAntColor: Bool = false
var isProgressAntSize: Bool = false
var isProgressAntHair: Bool = false

var previousProgressValue: Int = 0
var frame: CGRect?
var frame2: CGRect?
var buttons: [CGRect] = []
class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    //StoryBoard elements and variable declaration
    @IBOutlet weak var advOption1DetailButton: UIButton!
    @IBOutlet weak var advOption1DetailLabel: UILabel!
    @IBOutlet weak var advOption2DetailButton: UIButton!
    @IBOutlet weak var advOption2DetailLabel: UILabel!
    @IBOutlet weak var advOption3DetailButton: UIButton!
    @IBOutlet weak var advOption3DetialLabel: UILabel!
    @IBOutlet weak var basicAntSizeLabel: UILabel!
    @IBOutlet weak var advOptionSmallAntImage: UIImageView!
    @IBOutlet weak var advOptionsBigAntImage: UIImageView!
    @IBOutlet weak var advOptionsScale: UIImageView!
    //@IBOutlet weak var scrollView: UIScrollView!
    var basicColorPicker = ColorPickerViewController()
    var headColorPicker = ColorPickerViewController()
    var tailColorPicker = ColorPickerViewController()
    var bodyColorPicker = ColorPickerViewController()

    @IBOutlet weak var colorDetailLabel: UILabel!
    @IBOutlet weak var colorDetailButton: UIButton!
    @IBOutlet weak var placeholderProgressBarView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var colorsTableView: UITableView!
    @IBOutlet weak var chooseColorButton: UIButton!
    @IBOutlet weak var antSizeSlider: UISlider!
//    @IBOutlet weak var advOption1TableView: UITableView!
//    @IBOutlet weak var advOption2TableView: UITableView!
//    @IBOutlet weak var advOption3TableView: UITableView!
    @IBOutlet weak var advOption1Button: UIButton!
    @IBOutlet weak var advOption2Button: UIButton!
    @IBOutlet weak var advOption3Button: UIButton!
    @IBOutlet weak var advOption2Label: UILabel!
    @IBOutlet weak var advOption1Label: UILabel!
    @IBOutlet weak var advOption3Label: UILabel!
    @IBOutlet weak var progressBar: ProgressBar!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var showHideAdvancedOptionsButton: UIButton!
    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var selectedSizelabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    var emptyProgressBar: ProgressBar!
    @IBOutlet weak var advOptionAntSizeLabel: UILabel!
    @IBOutlet weak var antSizeSegmentControl: UISegmentedControl!
    @IBOutlet weak var resetButton: UIButton!
    var tapGesture = UITapGestureRecognizer()
    var height: CGFloat = 0.0
    var antSizeBasic: String = ""
    var advBodyColor: UIColor?
    var advHeadColor: UIColor?
    var advTailColor: UIColor?
    var selectedColor: UIColor?
    var isAnyUserPutGiven: Bool = false
    var areAdvOptionsenabled: [Bool] = []
    
    //Override method for a view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //settting up options
        isProgressAntColor = false
        isProgressAntSize = false
        isProgressAntHair = false
        previousProgressValue = 0
        
        areAdvOptionsenabled = [false,false,false]
        //the tableview for color picker
        chooseColorButton.setTitle("", for: .normal)
        chooseColorButton.layer.cornerRadius = chooseColorButton.layer.bounds.height/2
        colorsTableView.isHidden = true
        colorsTableView.delegate = self
        colorsTableView.dataSource = self
        height = UIApplication.shared.statusBarFrame.height +
            self.navigationController!.navigationBar.frame.height + (self.tabBarController?.tabBar.frame.height)!
    
        //setting up advance option table views and other elements
//        advOption1TableView.delegate = self
//        advOption1TableView.dataSource = self
//        advOption1TableView.register(UITableViewCell.self, forCellReuseIdentifier: "advOption1")
//
//        advOption2TableView.delegate = self
//        advOption2TableView.dataSource = self
//        advOption2TableView.register(UITableViewCell.self, forCellReuseIdentifier: "advOption2")
//
//        advOption3TableView.delegate = self
//        advOption3TableView.dataSource = self
//        advOption3TableView.register(UITableViewCell.self, forCellReuseIdentifier: "advOption3")
        
        advOption1Button.isHidden = true
        advOption2Button.isHidden = true
        advOption3Button.isHidden = true
        self.advOptionsBigAntImage.isHidden = true
        self.advOptionSmallAntImage.isHidden = true
        self.advOptionsScale.isHidden = true
        self.selectedSizelabel.isHidden = true
        self.advOptionAntSizeLabel.isHidden = true
        self.antSizeSlider.isHidden = true
        colorDetailLabel.isHidden = true
        colorDetailButton.isHidden = true
        colorDetailButton.isUserInteractionEnabled = false
        advOption3DetailButton.isHidden = true
        advOption3DetialLabel.isHidden = true
        advOption3DetailButton.isUserInteractionEnabled = false
        advOption2DetailButton.isHidden = true
        advOption2DetailLabel.isHidden = true
        advOption2DetailButton.isUserInteractionEnabled = false
        advOption1DetailButton.isHidden = true
        advOption1DetailLabel.isHidden = true
        advOption1DetailButton.isUserInteractionEnabled = false
        chooseColorButton.layer.cornerRadius = chooseColorButton.layer.bounds.height/2
        advOption1Button.layer.cornerRadius = advOption1Button.layer.bounds.height/2
        advOption2Button.layer.cornerRadius = advOption2Button.layer.bounds.height/2
        advOption3Button.layer.cornerRadius = advOption3Button.layer.bounds.height/2
        showHideAdvancedOptionsButton.layer.cornerRadius = showHideAdvancedOptionsButton.layer.bounds.height/2
        advOption1Label.isHidden = true
        advOption2Label.isHidden = true
        advOption3Label.isHidden = true
//        advOption1TableView.isHidden = true
//        advOption2TableView.isHidden = true
//        advOption3TableView.isHidden = true
        searchLabel.isHidden = true
        resetButton.backgroundColor = .lightGray
        resetButton.isUserInteractionEnabled = false
        resetButton.setImage(UIImage(named: "reset")?.crop(to: CGSize(width: 25, height: 25)), for: .normal)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.myviewTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        progressBar.addGestureRecognizer(tapGesture)
        progressBar.isUserInteractionEnabled = false
        
        
        
        progressBar.isHidden = true
        searchButton.backgroundColor = .lightGray
        searchButton.tintColor = .red
        
        //progressBar.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height - 220)
        //placeholderView.frame = CGRect(x: UIScreen.main.bounds.width/2 - 75/2, y: UIScreen.main.bounds.height - 170, width: UIScreen.main.bounds.width, height: 200)
        segmentControl.selectedSegmentIndex = -1
        antSizeSegmentControl.selectedSegmentIndex = -1
    
        scrollView.contentSize = CGSize(width: 0, height: height)
        scrollView.bounces = false
        self.scrollView.contentOffset = CGPoint(x:0, y:0)
        antSizeSlider.setValue(-1, animated: false)
        //making the tableviews look more beautiful
        var path = UIBezierPath(roundedRect:colorsTableView.layer.bounds,
                                byRoundingCorners:[.bottomRight, .bottomLeft, .topLeft, .topRight],
                                cornerRadii: CGSize(width: 20, height:  20))
        var maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        colorsTableView.layer.mask = maskLayer
//        path = UIBezierPath(roundedRect:advOption1TableView.layer.bounds,
//                                byRoundingCorners:[.bottomRight, .bottomLeft, .topLeft, .topRight],
//                                cornerRadii: CGSize(width: 20, height:  20))
//        maskLayer = CAShapeLayer()
//        maskLayer.path = path.cgPath
//        advOption1TableView.layer.mask = maskLayer
//        advOption1TableView.backgroundColor = .lightGray
//        advOption1TableView.tintColor = .lightGray
//        path = UIBezierPath(roundedRect:advOption2TableView.layer.bounds,
//                                byRoundingCorners:[.bottomRight, .bottomLeft, .topLeft, .topRight],
//                                cornerRadii: CGSize(width: 20, height:  20))
//        maskLayer = CAShapeLayer()
//        maskLayer.path = path.cgPath
//        advOption2TableView.layer.mask = maskLayer
//        path = UIBezierPath(roundedRect:advOption3TableView.layer.bounds,
//                                byRoundingCorners:[.bottomRight, .bottomLeft, .topLeft, .topRight],
//                                cornerRadii: CGSize(width: 20, height:  20))
//        maskLayer = CAShapeLayer()
//        maskLayer.path = path.cgPath
//        advOption3TableView.layer.mask = maskLayer
        searchButton.layer.cornerRadius = searchButton.frame.height/2
        searchButton.isUserInteractionEnabled = false
        resetButton.layer.cornerRadius = resetButton.frame.height/2
        
        
       defaultValuesForFirstTime()
    
        
        //colors of the buttons to a same tint
        


//        colorsTableView.backgroundColor = UIColor.clear
//        colorsTableView.layer.shadowColor = UIColor.darkGray.cgColor
//        colorsTableView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
//        colorsTableView.layer.shadowOpacity = 1.0
//        colorsTableView.layer.shadowRadius = 2
//        colorsTableView.layer.cornerRadius = 10
//        colorsTableView.layer.masksToBounds = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //Setting shadows and other visual modifications
    override func viewDidLayoutSubviews() {
        antSizeSegmentControl.apportionsSegmentWidthsByContent = true
        chooseColorButton.addShadows(borderColor: .lightGray, backgroundColor: .brown)
        advOption1Button.addShadows(borderColor: .lightGray, backgroundColor: .white)
        advOption2Button.addShadows(borderColor: .lightGray, backgroundColor: .white)
        advOption3Button.addShadows(borderColor: .lightGray, backgroundColor: .white)
        antSizeSlider.frame.origin.y = antSizeSlider.frame.origin.y - 2
        buttons.append( chooseColorButton.frame)
        buttons.append( advOption1Button.frame )
        buttons.append( advOption2Button.frame )
        buttons.append( advOption3Button.frame )
        
        if (frame == nil){
            frame = searchButton.frame
        }
        if (frame2 == nil){
            frame2 = resetButton.frame

        }
        searchButton.frame = frame!
        resetButton.frame = frame2!

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //A method that sets default values when the screen is loaded for the first time
    func defaultValuesForFirstTime(){
        chooseColorButton.backgroundColor = UIColor.brown
        selectedColor = UIColor.brown
        antSizeBasic = " ( bodyLength > 1.5 AND bodyLength < 9 ) "
        basicAntSizeLabel.text = " 4.0 mm - 9.0 mm "
        segmentControl.selectedSegmentIndex = 1
        segmentControl.selectedSegmentTintColor = UIColor(hex: "C3C355")
        antSizeSegmentControl.selectedSegmentIndex = 2
        isProgressAntHair = true
        isProgressAntSize = true
        isProgressAntColor = true
        isAnyUserPutGiven = true
        updateProgress()
        resetButonUpdater()
    }

    // MARK:- User Input and Setup
    
    //Buttons and buttonActions
    @IBAction func colorDetailButtonClicked(_ sender: Any) {
        onClickChooseColor(self.colorDetailButton.imageView)

    }
    
    @IBAction func advOption3DetailButtonClicked(_ sender: Any) {
        advOption3ButtonClicked(self.advOption3DetailButton.imageView)
    }
    
    @IBAction func advOption2DetailButtonClicked(_ sender: Any) {
        advOption2ButtonClicked(self.advOption2DetailButton.imageView)
    }
    
    //Ant hail selection
    @IBAction func advOption1DetailButtonClicked(_ sender: Any) {
        advOption1ButtonClicked(self.advOption1DetailButton.imageView)
    }
    
    @IBAction func segmentControlIndexChanged(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex
            {
            case 0:
                segmentControl.selectedSegmentTintColor = UIColor(hex: "9E2A2B").withAlphaComponent(0.8)
            case 1:
                segmentControl.selectedSegmentTintColor = UIColor(hex: "C3C355")
            default:
                break
            }
        self.isAnyUserPutGiven = true
        resetButonUpdater()
        isProgressAntHair = true
        updateProgress()
    }
    
    //Advacne option1 i.e. ant head color
    @IBAction func advOption1ButtonClicked(_ sender: Any) {
        
//        if advOption1TableView.isHidden {
//            animate(toogle: true, viewName: advOption1TableView)
//        } else {
//            animate(toogle: false, viewName: advOption1TableView)
//        }
        
        
        //adding a color pcker to the button
        headColorPicker.autoDismissAfterSelection = true
        headColorPicker.scrollDirection = .vertical
        headColorPicker.style = .circle
        headColorPicker.pickerSize = CGSize(width: 260, height: 130)
        headColorPicker.allColors = headColorPicker.defaultPaletteColors
        headColorPicker.selectedColor = { color in
            self.advOption1Button.backgroundColor = color
            self.advOption1Button.setTitleColor(color.inverted, for: .normal)
            self.advHeadColor = color
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.advOption1DetailButton.isHidden = false
                self.advOption1DetailLabel.isHidden = false
                self.advOption1DetailButton.isUserInteractionEnabled = true
                if colorsList.keys.contains(color){
                    self.advOption1DetailLabel.text = colorsList[color]!
                }
                let center = self.advOption1Button.center
                self.advOption1Button.frame.size = CGSize(width: 50, height: 50)
                self.advOption1Button.layer.cornerRadius = 25
                self.advOption1Button.center = center
                self.advOption1Button.frame.origin.x = self.scrollView.frame.width/2
                self.advOption1Button.setTitle("", for: .normal)
                self.isAnyUserPutGiven = true
                self.resetButonUpdater()
                self.areAdvOptionsenabled[0] = true
            })
            self.advOption1Button.isUserInteractionEnabled = true
        }
        if let popoverController = headColorPicker.popoverPresentationController{
            popoverController.delegate = headColorPicker
            popoverController.permittedArrowDirections = .any
               //            popoverVC.delegate = self
            popoverController.sourceView = sender as! UIView
            popoverController.sourceRect = (sender as AnyObject).bounds
        }

        self.present(headColorPicker, animated: true, completion: nil)
        
    }
    
    //Advacne option 2 i.e. ant body color
    @IBAction func advOption2ButtonClicked(_ sender: Any) {
        
        //adding a color pcker to the button
        bodyColorPicker.autoDismissAfterSelection = true
        bodyColorPicker.scrollDirection = .vertical
        bodyColorPicker.style = .circle
        bodyColorPicker.pickerSize = CGSize(width: 260, height: 130)
        bodyColorPicker.allColors = bodyColorPicker.defaultPaletteColors
        bodyColorPicker.selectedColor = { color in
            self.advOption2Button.backgroundColor = color
            self.advOption2Button.setTitleColor(color.inverted, for: .normal)
            self.advBodyColor = color
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.advOption2DetailButton.isHidden = false
                self.advOption2DetailLabel.isHidden = false
                self.advOption2DetailButton.isUserInteractionEnabled = true
                if colorsList.keys.contains(color){
                    self.advOption2DetailLabel.text = colorsList[color]!
                }
                let center = self.advOption2Button.center
                self.advOption2Button.frame.size = CGSize(width: 50, height: 50)
                self.advOption2Button.layer.cornerRadius = 25
                self.advOption2Button.center = center
                self.advOption2Button.frame.origin.x = self.scrollView.frame.width/2
                self.advOption2Button.setTitle("", for: .normal)
                self.isAnyUserPutGiven = true
                self.resetButonUpdater()
                self.areAdvOptionsenabled[1] = true

            })
            self.advOption2Button.isUserInteractionEnabled = true

        }
        if let popoverController = bodyColorPicker.popoverPresentationController{
            popoverController.delegate = bodyColorPicker
            popoverController.permittedArrowDirections = .any
               //            popoverVC.delegate = self
            popoverController.sourceView = sender as! UIView
            popoverController.sourceRect = (sender as AnyObject).bounds
        }

        self.present(bodyColorPicker, animated: true, completion: nil)

    }
    
    //Advacne option 3 i.e. ant tail color

    @IBAction func advOption3ButtonClicked(_ sender: Any) {
        
//        if advOption3TableView.isHidden {
//            animate(toogle: true, viewName: advOption3TableView)
//        } else {
//            animate(toogle: false, viewName: advOption3TableView)
//        }
//        advOption3TableView.reloadData()
        
        //adding a color pcker to the button
        tailColorPicker.autoDismissAfterSelection = true
        tailColorPicker.scrollDirection = .vertical
        tailColorPicker.style = .circle
        tailColorPicker.pickerSize = CGSize(width: 260, height: 130)
        tailColorPicker.allColors = tailColorPicker.defaultPaletteColors
        tailColorPicker.selectedColor = { color in
            self.advOption3Button.backgroundColor = color
            self.advOption3Button.setTitleColor(color.inverted, for: .normal)
            self.advTailColor = color
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.advOption3DetailButton.isHidden = false
                self.advOption3DetialLabel.isHidden = false
                self.advOption3DetailButton.isUserInteractionEnabled = true
                if colorsList.keys.contains(color){
                    self.advOption3DetialLabel.text = colorsList[color]!
                }
                let center = self.advOption3Button.center
                self.advOption3Button.frame.size = CGSize(width: 50, height: 50)
                self.advOption3Button.layer.cornerRadius = 25
                self.advOption3Button.center = center
                self.advOption3Button.frame.origin.x = self.scrollView.frame.width/2
                self.advOption3Button.setTitle("", for: .normal)
                self.isAnyUserPutGiven = true
                self.resetButonUpdater()
                self.areAdvOptionsenabled[2] = true

            })
            self.advOption3Button.isUserInteractionEnabled = true

        }
        if let popoverController = tailColorPicker.popoverPresentationController{
            popoverController.delegate = tailColorPicker
            popoverController.permittedArrowDirections = .any
               //            popoverVC.delegate = self
            popoverController.sourceView = sender as! UIView
            popoverController.sourceRect = (sender as AnyObject).bounds
        }

        self.present(tailColorPicker, animated: true, completion: nil)

        
    }
    
    //Advanced options are visible or not?
    @IBAction func advancedOptionsClicked(_ sender: Any) {
        
        //if the button is pressed when they're hidden hence make them visible
        if(isAdvOptionsHidden == true){
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.advOptionsBigAntImage.isHidden = false
                self.advOptionSmallAntImage.isHidden = false
                self.advOptionsScale.isHidden = false
                self.selectedSizelabel.isHidden = false
                self.advOptionAntSizeLabel.isHidden = false
                self.antSizeSlider.isHidden = false
                self.advOption1Button.isHidden = false
                self.advOption2Button.isHidden = false
                self.advOption3Button.isHidden = false
                self.advOption1Label.isHidden = false
                self.advOption2Label.isHidden = false
                self.advOption3Label.isHidden = false
                if(self.areAdvOptionsenabled[0]){
                    self.advOption1DetailButton.isHidden = false
                    self.advOption1DetailLabel.isHidden = false

                }
                if(self.areAdvOptionsenabled[1]){
                    self.advOption2DetailButton.isHidden = false
                    self.advOption2DetailLabel.isHidden = false

                }
                if(self.areAdvOptionsenabled[2]){
                    self.advOption3DetailButton.isHidden = false
                    self.advOption3DetialLabel.isHidden = false
                }
                
                isAdvOptionsHidden = false
                self.showHideAdvancedOptionsButton.setImage( UIImage(systemName: "chevron.up"), for: .normal)
                var contentRect: CGRect = self.scrollView.subviews.reduce(into: .zero) { rect, view in
                    rect = rect.union(view.frame)
                }
                self.scrollView.contentSize = contentRect.size
                self.scrollView.contentSize.height = contentRect.size.height + 100
                //self.scrollView.contentSize = CGSize(width: 0, height: 900)
                self.searchButton.frame.origin.y = self.scrollView.contentSize.height - 55
                self.resetButton.frame.origin.y = self.scrollView.contentSize.height - 56
                self.progressBar.frame.origin.y = self.scrollView.contentSize.height - 55
                self.scrollView.bounces = true

            })
            

        }
        //if the button is pressed when they're visible hence hide them
        else{
            UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut, animations: {
                self.advOptionsBigAntImage.isHidden = true
                self.advOptionSmallAntImage.isHidden = true
                self.advOptionsScale.isHidden = true
                self.selectedSizelabel.isHidden = true
                self.advOptionAntSizeLabel.isHidden = true
                self.antSizeSlider.isHidden = true
                self.advOption1Button.isHidden = true
                self.advOption2Button.isHidden = true
                self.advOption3Button.isHidden = true
                self.advOption1Label.isHidden = true
                self.advOption2Label.isHidden = true
                self.advOption3Label.isHidden = true
                self.advOption1DetailLabel.isHidden = true
                self.advOption1DetailButton.isHidden = true
                self.advOption2DetailLabel.isHidden = true
                self.advOption2DetailButton.isHidden = true
                self.advOption3DetialLabel.isHidden = true
                self.advOption3DetailButton.isHidden = true
//                self.advOption1TableView.isHidden = true
//                self.advOption2TableView.isHidden = true
//                self.advOption3TableView.isHidden = true
                isAdvOptionsHidden = true
                self.showHideAdvancedOptionsButton.setImage( UIImage(systemName: "chevron.down"), for: .normal)
                self.searchButton.frame = frame!
                self.resetButton.frame = frame2!
                self.progressBar.frame = frame!
                self.scrollView.contentSize = CGSize(width: 0, height: self.height)
                //self.scrollView.contentSize = CGSize(width: 0, height: self.height)
                self.scrollView.contentOffset = CGPoint(x:0, y:0)
                self.scrollView.bounces = false

            })
            


        }
        
    }
    
    //A simple sege to connnect to the results screen
    @IBAction func searchButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "searchResultsSegue", sender: self)
    }
    
    //The basic options color picker
    @IBAction func onClickChooseColor(_ sender: Any) {
        
        //using a color picker to select the color
        basicColorPicker.autoDismissAfterSelection = true
        basicColorPicker.scrollDirection = .vertical
        basicColorPicker.style = .circle
        basicColorPicker.pickerSize = CGSize(width: 260, height: 130)
        basicColorPicker.allColors = basicColorPicker.defaultPaletteColors
        basicColorPicker.selectedColor = { color in
            self.chooseColorButton.backgroundColor = color
            self.chooseColorButton.setTitleColor(color.inverted, for: .normal)
            self.selectedColor = color
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.colorDetailButton.isHidden = false
                self.colorDetailLabel.isHidden = false
                self.colorDetailButton.isUserInteractionEnabled = true
                if colorsList.keys.contains(color){
                    self.colorDetailLabel.text = colorsList[color]!
                }
                let center = self.chooseColorButton.center
                self.chooseColorButton.frame.size = CGSize(width: 50, height: 50)
                self.chooseColorButton.layer.cornerRadius = 25
                self.chooseColorButton.center = center
                self.chooseColorButton.frame.origin.x = self.scrollView.frame.width/2 
                self.chooseColorButton.setTitle("", for: .normal)
                self.isAnyUserPutGiven = true
                self.resetButonUpdater()
            })
            //self.chooseColorButton.isUserInteractionEnabled = false
            isProgressAntColor = true
            self.updateProgress()
        }
        if let popoverController = basicColorPicker.popoverPresentationController{
                   popoverController.delegate = basicColorPicker
                   popoverController.permittedArrowDirections = .any
                   //            popoverVC.delegate = self
            popoverController.sourceView = sender as! UIView
            popoverController.sourceRect = (sender as AnyObject).bounds
               }

        self.present(basicColorPicker, animated: true, completion: nil)
        
//        if colorsTableView.isHidden {
//            animate(toogle: true, viewName: colorsTableView)
//        } else {
//            animate(toogle: false, viewName: colorsTableView)
//        }
    }
    
    //Basic options ant size. 4 segments for ease of use to new users
    @IBAction func antSizeSegmentChanged(_ sender: Any) {
        self.antSizeSegmentControl.selectedSegmentTintColor = UIColor(hex: "C3C355")
        switch antSizeSegmentControl.selectedSegmentIndex
            {
            case 0:
                antSizeBasic = " ( bodyLength > 0.0 AND bodyLength < 1.51 ) "
                basicAntSizeLabel.text = " 0.0 mm - 1.5 mm "
            case 1:
                antSizeBasic = " ( bodyLength > 1.5 AND bodyLength < 4.01 ) "
                basicAntSizeLabel.text = " 1.5 mm - 4.0 mm "
            case 2:
                antSizeBasic = " ( bodyLength > 4.0 AND bodyLength < 9.01 ) "
                basicAntSizeLabel.text = " 4.0 mm - 9.0 mm "
            case 3:
                antSizeBasic = " ( bodyLength > 9.0 ) "
                basicAntSizeLabel.text = " > 9.0 mm "
            default:
                break
            }
        self.isAnyUserPutGiven = true
        resetButonUpdater()
        isProgressAntSize = true
        updateProgress()
    }
    
    //Advacned options ant size. A more accurate ant size

    @IBAction func antSizeSliderChanged(_ sender: UISlider) {
        
        let sliderValue = sender.value * 10
        selectedSizelabel.text = "Size: \(String(format: "%.2f", sliderValue)) mm"
        if (sliderValue == 10){
            selectedSizelabel.text = "Size: >= 1 cm"

        }
        if (sliderValue > -1 && sliderValue < 1.5){
            antSizeSegmentControl.selectedSegmentIndex = 0
            basicAntSizeLabel.text = " 0.0 mm - 1.5 mm "
        } else if (sliderValue > 1.49 && sliderValue < 4.0){
            antSizeSegmentControl.selectedSegmentIndex = 1
            basicAntSizeLabel.text = " 1.5 mm - 4.0 mm "
        } else if (sliderValue > 3.99 && sliderValue < 9.0){
            antSizeSegmentControl.selectedSegmentIndex = 2
            basicAntSizeLabel.text = " 4.0 mm - 9.0 mm "
        } else {
            antSizeSegmentControl.selectedSegmentIndex = 3
            basicAntSizeLabel.text = " > 9.0 mm "
        }
        self.isAnyUserPutGiven = true
        resetButonUpdater()
    }

    
    @IBAction func resetButtonClicked(_ sender: Any) {
        
        self.isAnyUserPutGiven = false
        resetButonUpdater()
        if (isAdvOptionsHidden == false){
            advancedOptionsClicked(self)
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.chooseColorButton.frame = buttons[0]
            self.chooseColorButton.setTitle("", for: .normal)
            self.advOption1Button.frame = buttons[1]
            self.advOption1Button.setTitle("", for: .normal)
            self.advOption2Button.frame = buttons[2]
            self.advOption2Button.setTitle("", for: .normal)
            self.advOption3Button.frame = buttons[3]
            self.advOption3Button.setTitle("", for: .normal)
            self.chooseColorButton.layer.cornerRadius = self.chooseColorButton.layer.bounds.height/2
            self.advOption1Button.layer.cornerRadius = self.advOption1Button.layer.bounds.height/2
            self.advOption2Button.layer.cornerRadius = self.advOption2Button.layer.bounds.height/2
            self.advOption3Button.layer.cornerRadius = self.advOption3Button.layer.bounds.height/2
            //self.antSizeSegmentControl.selectedSegmentIndex = -1
            //self.segmentControl.selectedSegmentIndex = -1
            self.antSizeSlider.value = -1
            self.basicAntSizeLabel.text = "0.0 mm - 10.0 mm"
            self.selectedSizelabel.text = "Size: 0.00 mm"
            self.segmentControl.selectedSegmentTintColor = .clear
            //self.antSizeSegmentControl.selectedSegmentTintColor = .clear
            self.chooseColorButton.setTitleColor(.black, for: .normal)
            self.advOption1Button.setTitleColor(.black, for: .normal)
            self.advOption2Button.setTitleColor(.black, for: .normal)
            self.advOption3Button.setTitleColor(.black, for: .normal)
            isProgressAntHair = false
            isProgressAntSize = false
            isProgressAntColor = false
            previousProgressValue = 0
            self.updateProgress()
            self.colorDetailLabel.isHidden = true
            self.colorDetailButton.isHidden = true
            self.colorDetailButton.isUserInteractionEnabled = false
            self.advOption3DetailButton.isHidden = true
            self.advOption3DetialLabel.isHidden = true
            self.advOption3DetailButton.isUserInteractionEnabled = false
            self.advOption2DetailButton.isHidden = true
            self.advOption2DetailLabel.isHidden = true
            self.advOption2DetailButton.isUserInteractionEnabled = false
            self.advOption1DetailButton.isHidden = true
            self.advOption1DetailLabel.isHidden = true
            self.advOption1DetailButton.isUserInteractionEnabled = false
            self.chooseColorButton.isUserInteractionEnabled = true
            self.advOption1Button.isUserInteractionEnabled = true
            self.advOption2Button.isUserInteractionEnabled = true
            self.advOption3Button.isUserInteractionEnabled = true
            self.areAdvOptionsenabled = [false,false,false]
            self.searchButton.backgroundColor = .lightGray
            self.basicColorPicker = ColorPickerViewController()
            self.headColorPicker = ColorPickerViewController()
            self.tailColorPicker = ColorPickerViewController()
            self.bodyColorPicker = ColorPickerViewController()
            self.chooseColorButton.addShadows(borderColor: .lightGray, backgroundColor: .white)
            self.advOption1Button.addShadows(borderColor: .lightGray, backgroundColor: .white)
            self.advOption2Button.addShadows(borderColor: .lightGray, backgroundColor: .white)
            self.advOption3Button.addShadows(borderColor: .lightGray, backgroundColor: .white)
            self.searchButton.isUserInteractionEnabled = false
            self.defaultValuesForFirstTime()

        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            UIView.animate(withDuration: 0.2, animations: {
                
            })
        })
    }
    
    // MARK:- Tableview delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        var cell : UITableViewCell?
        
        if tableView == self.colorsTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell?.textLabel?.text = fruitList[indexPath.row]
            cell?.backgroundColor = .lightGray
            
        }
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.colorsTableView {
            chooseColorButton.setTitle("\(fruitList[indexPath.row])", for: .normal)
            animate(toogle: false, viewName: colorsTableView)
//            isProgressAntColor = true
//            updateProgress()
        }
        
    }
    
    //Adding animations when hiding/viewing advanced options
    func animate(toogle: Bool, viewName: UITableView) {
        
        if toogle {
            UIView.animate(withDuration: 0.2) {
                viewName.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                viewName.isHidden = true
            }
        }
    }
    
    //MARK:- Supporting methods
    
    // Amethod that tracks the progress of the required constrains for a feature based search
    func updateProgress()
    {
        var progresValue = 0
        if(isProgressAntColor){
            progresValue = progresValue + 1
        }
        if(isProgressAntSize){
            progresValue = progresValue + 1
        }
        if(isProgressAntHair){
            progresValue = progresValue + 1
        }

        //Update the progress bar for every constraint
        if(previousProgressValue != 3)
        {
            progressBar.setProgressWithAnimation(duration: 1, fromValue: Float(previousProgressValue)/3, toValue: Float(progresValue)/3)
//            searchButton.layer.borderColor = UIColor(hex: "C3C355").cgColor
            previousProgressValue = progresValue
        }
        
        //Make the search button clickable when all the options are satisfied.
        if(progresValue == 3)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                self.progressBar.progressLayer.strokeColor = UIColor(red: 195/255, green: 195/255, blue: 85/255, alpha: 1).cgColor
            }
            searchButton.isUserInteractionEnabled = true
            searchLabel.isHidden = false
            progressBar.isUserInteractionEnabled = false
            searchButton.backgroundColor = UIColor(hex: "E09F3E")

        }
        
    }
    
    //Enable or disable the reset button when called
    func resetButonUpdater(){
        if(isAnyUserPutGiven){
            resetButton.isUserInteractionEnabled = true
            resetButton.backgroundColor = UIColor(hex: "E09F3E")
        } else {
            resetButton.isUserInteractionEnabled = false
            resetButton.backgroundColor = UIColor.lightGray
        }
    }
    
    // A method for sending the selecteddata to the results screen for processing and display
    @objc func myviewTapped(_ sender: UITapGestureRecognizer) {

        self.performSegue(withIdentifier: "searchResultsSegue", sender: self)
        
    }
    
    //An ovverride method for performing a segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is SearchResultsViewController
        {
            let viewController = segue.destination as? SearchResultsViewController
            viewController?.antHair = segmentControl.selectedSegmentIndex
            //viewController?.antColor = (chooseColorButton.titleLabel?.text!)!
            viewController?.selectedColor = selectedColor!
            viewController?.basicAntSize = antSizeBasic
            if(!isAdvOptionsHidden){
                viewController!.advHeadColor = advHeadColor
                viewController!.advBodyColor = advBodyColor
                viewController!.advTailColor = advTailColor
                viewController!.antSize = antSizeSlider.value
                viewController!.isAdvancedOptionsEnabled = true
            }
        }
    }
}

struct SearchViewController_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, World!")
    }
}
