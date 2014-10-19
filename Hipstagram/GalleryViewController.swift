//
//  GalleryViewController.swift
//  Hipstagram
//
//  Created by Brian Mendez on 10/15/14.
//  Copyright (c) 2014 Brian Mendez. All rights reserved.
//

import UIKit

protocol PassToVCDelegate /*help from Jeff Chavez*/ {
    func userDidSelectPhoto(image : UIImage) -> (Void)
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var images = [UIImage]()
    
    var delegate : PassToVCDelegate?
    var flowlayout : UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var image1 = UIImage(named: "photo1.jpg")
        var image2 = UIImage(named: "photo2.jpg")
        var image3 = UIImage(named: "photo3.jpg")
        var image4 = UIImage(named: "photo4.jpg")
        self.images.append(image1!)
        self.images.append(image2!)
        self.images.append(image3!)
        self.images.append(image4!)
        
        self.flowlayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        // Do any additional setup after loading the view.
        
        var pinch = UIPinchGestureRecognizer(target: self, action: "pinchAction:")
        self.collectionView.addGestureRecognizer(pinch)
        
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func pinchAction(pinch : UIPinchGestureRecognizer) {
        
        
        if pinch.state == UIGestureRecognizerState.Ended {
            println(pinch.velocity)
            self.collectionView.performBatchUpdates({ () -> Void in
                if pinch.velocity < 0 {
                    self.flowlayout.itemSize = CGSize(width: self.flowlayout.itemSize.width * 2, height: self.flowlayout.itemSize.height * 2)
                } else {
                    self.flowlayout.itemSize = CGSize(width: self.flowlayout.itemSize.width / 0.5, height: self.flowlayout.itemSize.height / 0.5)
                }
                }, completion: nil )
        }
        
    }
    

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HEADER", forIndexPath: indexPath) as HeaderView
            view.headerLabel.text = "Photo Album"
            return view
        } else {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "FOOTER", forIndexPath: indexPath) as FooterView
            view.footerLabel.text = "\(images.count.description) Photos"
            return view
        }
    }
    
    //needed for datasource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    //needed for datasource
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
        cell.imageView.image = self.images[indexPath.row]
        return cell
    }
    //needed for delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var selectedImage = images[indexPath.row]
        self.delegate?.userDidSelectPhoto(selectedImage)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
