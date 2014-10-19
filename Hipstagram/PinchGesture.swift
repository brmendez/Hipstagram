//
//  PinchGesture.swift
//  Hipstagram
//
//  Created by Brian Mendez on 10/17/14.
//  Copyright (c) 2014 Brian Mendez. All rights reserved.
//

import UIKit

class PinchGesture : NSObject {
    
    var collectionView : UICollectionView?
    var flowLayout : UICollectionViewFlowLayout?
    
    override init() {

    }
    
    func activatePinch (gestureRecognizer: UIPinchGestureRecognizer) {
    
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            
        }
        if gestureRecognizer.state == UIGestureRecognizerState.Changed {
            
        }
        if gestureRecognizer.state == UIGestureRecognizerState.Ended {
            self.collectionView!.performBatchUpdates({ () -> Void in
                var currentSize = self.flowLayout!.itemSize
                if gestureRecognizer.velocity < 0 {
                    self.flowLayout!.itemSize = CGSize(width: currentSize.width * 2, height: currentSize.height * 2)
                } else {
                    self.flowLayout!.itemSize = CGSize(width: currentSize.width / 2, height: currentSize.height / 2)
                }
            }, completion: nil)
        }
        
    }
}