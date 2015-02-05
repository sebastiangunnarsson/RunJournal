//
//  RunJournal.swift
//  RunJournal
//
//  Created by Viktor Roos on 2015-02-05.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Run: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var isCompleted: NSNumber
    @NSManaged var length: NSNumber
    @NSManaged var name: String
    @NSManaged var image: NSData?
    

    
    func IsToday() -> Bool? {
        var calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        
        return calendar?.isDateInToday(date)
    }
    
    func GetImage() -> UIImage? {
        if(image == nil) {
            return nil
        }
        return UIImage(data: image!)
    }
}
