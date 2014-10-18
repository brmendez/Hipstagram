//
//  Filter.swift
//  Hipstagram
//
//  Created by Brian Mendez on 10/15/14.
//  Copyright (c) 2014 Brian Mendez. All rights reserved.
//

import Foundation
import CoreData

class Filter: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var favorited: NSNumber

}
