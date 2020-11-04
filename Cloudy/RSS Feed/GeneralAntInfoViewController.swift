////
////  GeneralAntInfoViewController.swift
////  Cloudy
////
////  Created by NVR4GET on 16/5/20.
////  Copyright © 2020 Ganesh. All rights reserved.
////
//
//import UIKit
//import CollectionViewPagingLayout
//import SnapLikeCollectionView
//
//class GeneralAntInfoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//
//    @IBOutlet weak var collectionView: UICollectionView!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let layout = CollectionViewPagingLayout()
//        layout.numberOfVisibleItems = 10
//        collectionView.collectionViewLayout = layout
//        collectionView.isPagingEnabled = true
//        collectionView.delegate = self
//        collectionView.dataSource = self
//
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.clipsToBounds = false
//        collectionView.backgroundColor = .clear
//        
//        let nib = UINib(nibName: GenericAntInfoCollectionViewCell.nibName, bundle: nil)
//        collectionView?.register(nib, forCellWithReuseIdentifier: GenericAntInfoCollectionViewCell.reuseIdentifier)
//        if let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
//            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
//        }
//
//
//        updateTable()        // Do any additional setup after loading the view.
//    }
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int{
//        return 1
//    }
//    
//    //A collectionView method that tells the number of items in a collection
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//
//        return 10
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//       
//        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenericAntInfoCollectionViewCell.reuseIdentifier, for: indexPath) as? GenericAntInfoCollectionViewCell {
//            cell.configureCell(heading: "Abcd \(Float.random(in: 0 ..< 1))", info: "info1", image: UIImage(systemName: "ant")!)
//            return cell
//            }
//        return UICollectionViewCell()
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        return CGSize(width: 350, height: 600)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 20
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 20
//    }
//
//    @IBAction func leftButtonClicked(_ sender: Any) {
//        var index:Int = self.collectionView.indexPathsForVisibleItems.first!.row
//        index = index - 1
//        self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: UICollectionView.ScrollPosition.left, animated: true)
//    }
//    
//    @IBAction func rightButtonClicked(_ sender: Any) {
//        var index:Int = self.collectionView.indexPathsForVisibleItems.first!.row
//        index = index + 1
//        self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: UICollectionView.ScrollPosition.right, animated: true)
//    }
//    
//    func updateTable(){
//        collectionView.reloadData()
//        collectionView.performBatchUpdates({
//            self.collectionView.collectionViewLayout.invalidateLayout()
//        }, completion: nil)
//    }
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
