//
//  Run.swift
//  RunJournal
//
//  Created by David Karlsson on 2015-01-30.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import Foundation
import CoreData

class Run: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var length: NSNumber
    @NSManaged var date: NSDate
    @NSManaged var isCompleted: NSNumber
    
    func IsToday() -> Bool? {
        var calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        
        
        
        
        
        return calendar?.isDateInToday(date)
    }
    
    
}
