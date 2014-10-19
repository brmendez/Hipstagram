//
//  ViewController.swift
//  Hipstagram
//
//  Created by Brian Mendez on 10/15/14.
//  Copyright (c) 2014 Brian Mendez. All rights reserved.
//

import UIKit
import CoreData
import CoreImage
import OpenGLES

class ViewController: UIViewController, PassToVCDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    
    var managedObjectContext : NSManagedObjectContext!
    var filters : [Filter]?
    var thumbnailContainers = [ThumbnailContainer]()
    var originalThumbnail : UIImage?
    
    var context : CIContext?
    
    let imageQueue = NSOperationQueue()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        
        var options = [kCIContextWorkingColorSpace : NSNull()]
        var myEAGLEContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        self.context = CIContext(EAGLContext: myEAGLEContext, options: options)

        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        
        //checks to see if we have filters in database
        let fetchRequest = NSFetchRequest(entityName: "Filter")
        var error : NSError?
        
        //First fetch, sees if we have anything in database.
        if let filters = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [Filter] {
            //checks if fetch produced any items
            if filters.isEmpty {
                //if empty, seed it!
                self.seedCoreData()
                self.filters = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [Filter]

            } else {
                //after running second time, code RUNS through this else
                self.filters = filters
            }
        }
            self.generateThumbnail()
            self.resetFilterThumbnails()
    }
    
    func generateThumbnail () {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        self.imageView.image?.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    //created filters here. Casts as Filter.swift
    func seedCoreData() {
        var sepiaFilter = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        sepiaFilter.name = "CISepiaTone"
        sepiaFilter.favorited = true
        
        var gaussianBlurFilter = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        gaussianBlurFilter.name = "CIGaussianBlur"
        gaussianBlurFilter.favorited = false
        
        var chromeEffect = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        chromeEffect.name = "CIPhotoEffectChrome"
        chromeEffect.favorited = true
        
        var error : NSError?
        //saves, error will have value if it didn't work
        self.managedObjectContext.save(&error)
        if error != nil {
        }
        
    }
    
    //datasource conform to protocol methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.thumbnailContainers.count
    }
    
    //dequeues cell, imageView in FiltersCell.swift
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as FiltersCell
        
        let thumbnailContainer = self.thumbnailContainers[indexPath.row]
        if thumbnailContainer.filteredThumbnail != nil {
            cell.imageView.image = thumbnailContainer.filteredThumbnail
        } else {
            cell.imageView.image = thumbnailContainer.originalThumbnail
            thumbnailContainer.generateFilterThumbnail({ (filteredThumb) -> (Void) in
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? FiltersCell {
                    cell.imageView.image = filteredThumb
                }
            })
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
//        self.imageQueue.addOperationWithBlock { () -> Void in
//            var image = CIImage(image: self.originalThumbnail)
//            var imageFilter = CIFilter(name: self.filters[indexPath.row].name)
//        }
        
        
        
        var filteredThumbnail = ThumbnailContainer(filterName: self.filters![indexPath.row].name, thumbnail: self.imageView.image!, queue: imageQueue, context: self.context!)
        filteredThumbnail.generateFilterThumbnail { (image) -> Void in
            self.imageView.image = image
        }
    }
    
    func resetFilterThumbnails () {
        var newFilters = [ThumbnailContainer]()
        for var index = 0; index < self.filters!.count; index++ {
            var filter = self.filters![index]
            var filterName = filter.name
            var thumbnail = ThumbnailContainer(filterName: filterName, thumbnail: self.originalThumbnail!, queue: self.imageQueue, context: self.context!)
            newFilters.append(thumbnail)
        }
        self.thumbnailContainers = newFilters
    }
    
    @IBAction func hipPhotosPressed(sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Menu", message: "Select a picture!", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let galleryAction = UIAlertAction(title: "Scenery Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("SHOW_GALLERY", sender: self)
        }
        
        let filterAction = UIAlertAction(title: "Filters", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.enterFilterMode()
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            }
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePicker.delegate = self
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("SHOW_PHOTO_LIBRARY", sender: self)
            
        }
        
        let avFoundationAction = UIAlertAction(title: "AVFoundation", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("SHOW_AV", sender: self)
        }
        
        alertController.addAction(galleryAction)
        alertController.addAction(filterAction)
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(avFoundationAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        self.imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.generateThumbnail()
        self.resetFilterThumbnails()
        self.collectionView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_GALLERY" {
            //phone calles to GalleryViewController
            let galleryVC = segue.destinationViewController as GalleryViewController
            //talks to and asks to be delegate of GalleryViewController. GVC Has the protocol that it requires, which is to be implemented below
            galleryVC.delegate = self
        } else if segue.identifier == "SHOW_PHOTO_LIBRARY" {
                let photoLibraryVC = segue.destinationViewController as PhotoLibraryViewController
            photoLibraryVC.delegate = self
//            photoLibraryVC.vcLargeCellSize = self.imageView.frame.size
            }
        }
    
    //conforms to PassToVCDelegate Protocol, protocol is up top on GalleryViewController
    func userDidSelectPhoto(image: UIImage) {
        self.imageView.image = image
        self.generateThumbnail()
        self.resetFilterThumbnails()
        collectionView.reloadData()
    }
    
    func enterFilterMode() {
        self.imageViewLeadingConstraint.constant = self.imageViewLeadingConstraint.constant * 3
        self.imageViewTrailingConstraint.constant = self.imageViewTrailingConstraint.constant * 3
        self.imageViewBottomConstraint.constant = self.imageViewBottomConstraint.constant * 2.1
        self.collectionViewBottomConstraint.constant = 100
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
    }
    
}