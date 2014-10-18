//
//  PhotoLibraryViewController.swift
//  Hipstagram
//
//  Created by Brian Mendez on 10/16/14.
//  Copyright (c) 2014 Brian Mendez. All rights reserved.
//

import UIKit
import Photos

class PhotoLibraryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var assetFetchResults : PHFetchResult!
    var imageManager : PHCachingImageManager!
    var assetCellSize : CGSize!
    
    var delegate : PassToVCDelegate?
    var vcLargeCellSize : CGSize!

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        //THIS IS THE START OF NEW STUFF WE LEARNED ON DAY 3
        
        // Get image image, asset fetch results
        //holds all images from photo library
        self.imageManager = PHCachingImageManager()
        
        // Pass nil, fetch all assets
        self.assetFetchResults = PHAsset.fetchAssetsWithOptions(nil)
        
        // Determine device scale, adjust asset cell size
        var scale = UIScreen.mainScreen().scale
        var flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        
        var cellSize = flowLayout.itemSize
        self.assetCellSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetFetchResults.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PHOTO_LIBRARY_CELL", forIndexPath: indexPath) as PhotoLibraryCell
        
        var asset = self.assetFetchResults[indexPath.row] as PHAsset
        
        self.imageManager.requestImageForAsset(asset, targetSize: self.assetCellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
            cell.imageView.image = image
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var asset = self.assetFetchResults[indexPath.row] as PHAsset
        self.imageManager.requestImageForAsset(asset, targetSize: self.assetCellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
            self.delegate?.userDidSelectPhoto(image)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }    
}