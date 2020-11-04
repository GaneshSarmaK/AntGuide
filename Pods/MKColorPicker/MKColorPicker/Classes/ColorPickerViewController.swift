//
// Copyright (c) 2017 malkouz
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

open class ColorPickerViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    open var selectedColor:((_ color:UIColor)->())?
    open var autoDismissAfterSelection = true
    open var style: ColorPickerViewStyle = .circle{
        didSet{
            colorPickerView.style = style
        }
    }
    
    open var defaultPaletteColors = [UIColor.black, UIColor.systemYellow, UIColor.systemOrange, UIColor.systemRed, UIColor.brown, UIColor.gray, UIColor.systemGreen, UIColor(red: 8/255, green: 3/255, blue: 110/255, alpha: 1)]

    
    open var pickerSize = CGSize(width: 250, height: 250){
        didSet{
            self.view.frame = CGRect(x: 0, y: 0, width: pickerSize.width, height: pickerSize.height)
            self.preferredContentSize = pickerSize
            
            
        }
    }
    
    open var allColors = [UIColor](){
        didSet{
            colorPickerView.colors = allColors
        }
    }
    
    open var scrollDirection: UICollectionView.ScrollDirection = .horizontal{
        didSet{
            colorPickerView.scrollDirection = scrollDirection
        }
    }

    
    
    
    let colorPickerView = ColorPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
   
    
    
    public init()
    {
        super.init(nibName: nil, bundle: nil)
        
        self.setup()
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup(){
        allColors = defaultPaletteColors
        colorPickerView.layoutDelegate = self
        colorPickerView.delegate = self
        colorPickerView.style = style
        colorPickerView.selectionStyle = .check
        colorPickerView.isSelectedColorTappable = false
//        colorPickerView.preselectedIndex = colorPickerView.colors.indices.first
        colorPickerView.colors = allColors
        self.view = colorPickerView
        self.preferredContentSize = colorPickerView.frame.size
        self.modalPresentationStyle = .popover
        
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - UIPopoverPresentationControllerDelegate
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // return UIModalPresentationStyle.FullScreen
        return UIModalPresentationStyle.none
    }
}

// MARK: - ColorPickerViewDelegateFlowLayout
extension ColorPickerViewController: ColorPickerViewDelegate, ColorPickerViewDelegateFlowLayout{
    
    // MARK: - ColorPickerViewDelegate
    
    public func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        self.selectedColor?(colorPickerView.colors[indexPath.item])
        //self.selectedColorView.backgroundColor = colorPickerView.colors[indexPath.item]
        if autoDismissAfterSelection{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - ColorPickerViewDelegateFlowLayout
    public func colorPickerView(_ colorPickerView: ColorPickerView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 48, height: 48)
    }
    
    public func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 11
    }
    
    public func colorPickerView(_ colorPickerView: ColorPickerView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    public func colorPickerView(_ colorPickerView: ColorPickerView, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}

