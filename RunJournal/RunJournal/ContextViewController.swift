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
    
    func deleteRun(run: NSManagedObject, lastFilter:Int) {
        manageContext.deleteObject(run)
        saveEntities()
        
        switch(lastFilter){
        case 0:
            runs = getScheduledRuns()
            break
        case 1:
            runs = getCompletedRuns()
            break
        case 2:
            runs = getPassedRuns()
            break
        default:
            runs = getEntities("Run")
            
        }
        
       
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
    func addRun(name:String, length:Double, date:NSDate, isCompleted:Bool, image:NSData?, duration:Int) {
        
        let entity = NSEntityDescription.entityForName("Run", inManagedObjectContext: manageContext)
        let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: manageContext) as Run
        item.date = date
        item.name = name
        item.length = length
        item.isCompleted = isCompleted
        item.actualDuration = 0
        item.image = image
        item.actualLength = 0.0
        item.duration = duration
        runs?.append(item)
        
        saveEntities()
        
    }
    
    // Hämtar alla avklarade löprundor
    func getCompletedRuns() -> [Run] {
        var allRuns = getEntities("Run")
        var result = [Run]()
        
        for(var i = 0; i < allRuns.count; i++) {
            var run = allRuns[i] as Run
            
            
            if(run.isCompleted == true) {
                    result.append( run )
            }
        }
        return result
    }
    
    // Hämtar alla icke avklarade löprundor
    func getScheduledRuns() -> [Run] {
        
        var allRuns = getEntities("Run")
        var result = [Run]()
        
        for(var i = 0; i < allRuns.count; i++) {
            var run = allRuns[i] as Run
            
            if(run.isCompleted == false && dateHasPassed(run.date) == false) {
                result.append( run )
            }
        }
        return result
    }
    
    func getPassedRuns() -> [Run] {
        var allRuns = getEntities("Run")
        var result = [Run]()
        
        for(var i = 0; i < allRuns.count; i++) {
            var run = allRuns[i] as Run
            
            if(run.isCompleted == false && dateHasPassed(run.date) == true) {
                result.append( run )
            }
        }
        return result
    }
    
    // Check whether the date has passed
    func dateHasPassed(date:NSDate) -> Bool {
        var calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        
        return (date.timeIntervalSinceNow < 0)
        
        /*
        if( date.compare(date) == NSComparisonResult.OrderedAscending && calendar?.isDateInToday(date) == false) {
                return true
        }
        return false
        */
    }
    
    
    
    // Hämtar alla inkommande löpturer (Idag och framåt)
    func getUpcomingScheduledRuns() -> [Run] {
        var calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        runs = getEntities("Run")
        var result = [Run]()
        var currentDate = NSDate()
        for(var i = 0; i < runs?.count; i++) {
            var run = runs?[i] as Run
            
            
            
            if( run.date.compare(currentDate) == NSComparisonResult.OrderedDescending || calendar?.isDateInToday(run.date) == true) {
                //if( calendar?.isDateInToday(run.date) == false) {
                    result.append( run )
               // }
            }
        }
        return result
    }
    
    // Hämtar alla föregående löpturer (Igår och bakåt)
    func getPreviouslyScheduledRuns() -> [Run] {
        var calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        
        runs = getEntities("Run")
        
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
        
        runs = getEntities("Run")
        
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
    func getEntities(entityName:String) -> [Run] {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        
        var error: NSError?
        
        let fetchedResults = manageContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            
            var result = results as [Run]
            
            result.sort({ $0.date.timeIntervalSinceNow < $1.date.timeIntervalSinceNow })
            return result
        }
        print(error);
        return [Run]()
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
