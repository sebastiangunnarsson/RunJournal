//
//  RunJournal.swift
//  RunJournal
//
//  Created by Samuel Eklund on 2015-02-17.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import Foundation
import CoreData

class Location: NSManagedObject {

    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var timestamp: NSNumber
    @NSManaged var run: RunJournal.Run

}
