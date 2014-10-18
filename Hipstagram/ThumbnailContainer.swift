//
//  ThumbnailContainer.swift
//  Hipstagram
//
//  Created by Brian Mendez on 10/15/14.
//  Copyright (c) 2014 Brian Mendez. All rights reserved.
//

import UIKit

class ThumbnailContainer {

    var originalThumbnail : UIImage
    var filterName : String
    var imageQueue : NSOperationQueue
    var gpuContext : CIContext
    
    //for the function
    var filteredThumbnail : UIImage?
    var ciFilter : CIFilter?
    
    init(filterName: String, thumbnail: UIImage, queue: NSOperationQueue, context: CIContext){
        
        self.filterName = filterName
        self.originalThumbnail = thumbnail
        self.imageQueue = queue
        self.gpuContext = context
    }

    func generateFilterThumbnail(completionHandler : (filteredThumb : UIImage) -> (Void)) {

        self.imageQueue.addOperationWithBlock { () -> Void in
            
            //this sets pictures filter
            var image = CIImage(image: self.originalThumbnail)
            var imageFilter = CIFilter(name: self.filterName)
            imageFilter.setDefaults()
            imageFilter.setValue(image, forKey: kCIInputImageKey)
            
            
            var result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
            var extent = result.extent()
            var imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
            self.ciFilter = imageFilter
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.filteredThumbnail = UIImage(CGImage: imageRef)
                completionHandler(filteredThumb: self.filteredThumbnail!)
            })
        }
    }
}