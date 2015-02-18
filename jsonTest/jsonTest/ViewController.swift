//
//  ViewController.swift
//  jsonTest
//
//  Created by David Karlsson on 2015-02-02.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var eventStore = EKEventStore()
        eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion: {
            granted, error in
            if(granted) && (error == nil) {
                println("granted")
            
                
                var event = EKEvent(eventStore: eventStore)
                event.title = "Test title"
                event.startDate = NSDate()
                event.endDate = NSDate()
                event.notes = "this is a note"
                event.calendar = eventStore.defaultCalendarForNewEvents
                eventStore.saveEvent(event, span: EKSpanThisEvent, error: nil)
                println("saved event")

                
                
            }
        })
        
        func createReminder() {
            
            let reminder = EKReminder(eventStore: appDelegate!.eventStore)
            
            reminder.title = reminderText.text
            reminder.calendar =
                appDelegate!.eventStore!.defaultCalendarForNewReminders()
            let date = myDatePicker.date
            let alarm = EKAlarm(absoluteDate: date)
            
            reminder.addAlarm(alarm)
            
            var error: NSError?
            appDelegate!.eventStore!.saveReminder(reminder,
                commit: true, error: &error)
            
            if error != nil {
                println("Reminder failed with error \(error?.localizedDescription)")
            }
        }
        
        eventStore.requestAccessToEntityType(EKEntityTypeReminder, completion: {
            granted, error in
            if(granted) && (error == nil) {
                println("granted")
                
                
                let reminder = EKReminder(eventStore: eventStore)
                
                reminder.title = "Go to the store and buy milk"
                reminder.calendar = eventStore.defaultCalendarForNewReminders()
                
                
                var error: NSError?
                
                eventStore.saveReminder(reminder, commit: true, error: &error)
                
                
            }
        })

        
        /*
        
            // What about Calendar entries?
        var startDate=NSDate().dateByAddingTimeInterval(-60*60*24)
        var endDate=NSDate().dateByAddingTimeInterval(60*60*24*3)
        var predicate2 = eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: nil)
        
        println("startDate:\(startDate) endDate:\(endDate)")
        var eV = eventStore.eventsMatchingPredicate(predicate2) as [EKEvent]!
        
        if eV != nil {
            for i in eV {
                println("Title  \(i.title)" )
                println("stareDate: \(i.startDate)" )
                println("endDate: \(i.endDate)" )
                
                
                eventStore.removeEvent(i, span: EKSpanThisEvent, error: nil)
                
            }
        }
        */
        
    
    }
    
    func updateEvent(event:EKEvent, newEvent:EKEvent) {
    
    }
    
    func getCalendarEvents(from:NSDate, until:NSDate) -> [EKEvent]! 	{
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

