//
//  ContextViewController.swift
//  RunJournal
//
//  This class will handle the communication against core data
//
//  Created by David Karlsson on 2015-01-27.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import UIKit
import CoreData

class ContextViewController: UIViewController {

    var runs:[NSManagedObject]?
    var manageContext:NSManagedObjectContext
    
    
    // konstruktorn som initierar contexten för att användas
    required init(coder aDecoder: NSCoder) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        manageContext = appDelegate.managedObjectContext!
        runs = nil
        super.init(coder: aDecoder)
        runs = getEntities("Run") as [Run]
    }
    
    
    // Hämtar ett objekt genom dess id.
    // ID:t från en löptur får man genom följande, givet att man har en löptur
    // getRunByObjectId ( myRunObject.objectId )
    func getRunByObjectId(objectId:NSManagedObjectID) -> Run {
        return manageContext.objectWithID(objectId) as Run
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    // Skapar ett datumobjekt från komponenter
    func createDate(year:Int, month:Int, day:Int, hour:Int, minute:Int, second:Int) -> NSDate? {
        var calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        var components = NSDateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        
        return calendar?.dateFromComponents(components)
    }

    // Hämtar alla datumkomponenter från ett datumobjekt (Exempelvis år, månad, dag etc)
    // Komponenter från dagens datum får man genom följande:
    // var currentDateComponents = getComponentsFromDate( NSDate() )
    func getComponentsFromDate(date:NSDate) -> NSDateComponents? {
        var calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        
        return calendar?.components(NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond, fromDate: date)
    
    }
    
    // Lägger till en löptur med givna parametrar (Och sparar dessa i CoreData efteråt)
    func addRun(name:String, length:Double, date:NSDate, isCompleted:Bool, image:NSData?) {
        
        let entity = NSEntityDescription.entityForName("Run", inManagedObjectContext: manageContext)
        let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: manageContext) as Run
        item.date = date
        item.name = name
        item.length = length
        item.isCompleted = isCompleted
        item.image = image
        runs?.append(item)
        
        saveEntities()
        
    }
    
    // Hämtar alla inkommande löpturer (Imorgon och framåt)
    func getUpcomingScheduledRuns() -> [Run] {
        var calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        
        var result = [Run]()
        var currentDate = NSDate()
        for(var i = 0; i < runs?.count; i++) {
            var run = runs?[i] as Run
            
            if( run.date.compare(currentDate) == NSComparisonResult.OrderedDescending) {
                if( calendar?.isDateInToday(run.date) == false) {
                    result.append( run )
                }
            }
        }
        return result
    }
    
    // Hämtar alla föregående löpturer (Igår och bakåt)
    func getPreviouslyScheduledRuns() -> [Run] {
        var calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        
        var result = [Run]()
        var currentDate = NSDate()
        for(var i = 0; i < runs?.count; i++) {
            var run = runs?[i] as Run
            if( run.date.compare(currentDate) == NSComparisonResult.OrderedAscending) {
                if( calendar?.isDateInToday(run.date) == false) {
                    result.append( run )
                }
            }
        }
        return result
    }
    
    // Hämtar alla löpturer för idag
    func getTodaysScheduledRuns() -> [Run] {
        var calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        
        var result = [Run]()
        var currentDate = NSDate()
        for(var i = 0; i < runs?.count; i++) {
            var run = runs?[i] as Run
            if( calendar?.isDateInToday(run.date) == true) {
                result.append( run )
            }
        }
        return result
    }
    
    // Hämtar alla entities from en viss tabell (som en array av NSManagedObjects)
    // Vill man ha alla objekt från tabellen Run så kör man bara följande:
    // var runs = getEntities("Run") as [Run]
    func getEntities(entityName:String) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        
        var error: NSError?
        
        let fetchedResults = manageContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            return results
        }
        print(error);
        return [NSManagedObject]()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Sparar alla ändringar till Contexten
    func saveEntities() {
        manageContext.save(nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
