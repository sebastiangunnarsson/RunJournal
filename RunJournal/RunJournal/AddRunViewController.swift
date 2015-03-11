//
//  AddRunViewController.swift
//  RunJournal
//
//  Created by Viktor Roos on 2015-02-05.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import UIKit
import MobileCoreServices
import EventKit

extension NSDate {
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitHour, fromDate: date, toDate: self, options: nil).hour
    }
}

class AddRunViewController: ContextViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate {

    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var calendarCollisionLabel: UILabel!
    @IBOutlet weak var calendarCollisionSwitch: UISwitch!
    @IBOutlet weak var addToCalendarSwitch: UISwitch!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lengthTextView: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var weatherDescLabel: UILabel!
    @IBOutlet weak var imageURL: UIImageView!
    @IBOutlet weak var addPictureButton: UIButton!
    
    var loadingSpinner:UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openWeather.test()
        // Do any additional setup after loading the view.
        calendarCollisionLabel.textColor = UIColor(red: 0, green: 0, blue:0, alpha: 0.1)
        weatherDescLabel.text = ""
        
        imageURL.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addToCalendarSwitchDidChange(sender: AnyObject) {
        
        calendarCollisionSwitch.enabled = (addToCalendarSwitch.on == true) ? true : false
        
        
        calendarCollisionLabel.textColor = (addToCalendarSwitch.on == true) ? UIColor.blackColor() : UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        
    }
    
    // Påbörjar loading spinnaren centrerad
    func startLoading() {
        self.loadingSpinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.loadingSpinner.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.width, self.view.frame.height);
        
        self.loadingSpinner.center = self.view.center
        self.loadingSpinner.startAnimating()
        self.view.addSubview( self.loadingSpinner )
    }
    
    // döljer laddarsnurran
    func stopLoading() {
        if(self.loadingSpinner != nil) {
            self.loadingSpinner.stopAnimating()
        }
    }
    
    @IBAction func datePickerChange(sender: AnyObject) {
        var date = NSDate()
        
        var weatherIndex = datePicker.date.hoursFrom(date) / 24
        
        if(weatherIndex < 16 && weatherIndex >= 0){
            weatherDescLabel.text = openWeather.weatherList[weatherIndex].weather["description"]
            var iconName = openWeather.weatherList[weatherIndex].weather["icon"]

            
            if let checkedUrl = NSURL(string: "http://openweathermap.org/img/w/" + iconName! + ".png") {
                downloadImage(checkedUrl)
            }
        } else {
            weatherDescLabel.text = "N/A"
        }
        println(datePicker.date.hoursFrom(date) / 24)
    }
    
    
    @IBAction func addClick(sender: AnyObject) {
        self.startLoading()
        
        var errs = [String]()
        
        if(nameTextField.text.isEmpty)
        {
            errs.append("Name is required")
        }
        if(durationTextField.text.isEmpty)
        {
            errs.append("Duration is required")
        }
        
        if(errs.count > 0)
        {
            stopLoading()
            showErrorsDialog(errs)
            return
        }
        
        var duration:Int = (durationTextField.text as NSString).integerValue
        var length:NSString = lengthTextView.text
        var imageData = thumbnailImageView.image == nil ? nil : UIImageJPEGRepresentation(thumbnailImageView.image, 0.1)
        
        
        addRunWith(nameTextField.text, length: length.doubleValue, start: datePicker.date, duration: duration, image: imageData)
    }
    
    // Made by Sebastian Gunnarsson
    func createCalendarEventFor(title:String, date:NSDate, notes:String, duration:Int, store:EKEventStore) -> EKEvent {
        
        
        // get the start date
        let startDate = date;
        // get the end date by adding the duration
        let endDate = startDate.dateByAddingTimeInterval(NSTimeInterval(60*duration))
        
        
        var event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
        event.calendar = store.defaultCalendarForNewEvents
        
        return event
        //store.saveEvent(event, span: EKSpanThisEvent, error: &error)
        
        
        
    }
    
    // Made by Sebastian Gunnarsson
    // check if anything in the default calendar collides with the given date
    func addRunWith(name:String, length:Double, start:NSDate, duration:Int, image: NSData?) {
        
        var eventStore = EKEventStore()
        
        // fixa så inte addRun stannar om man inte väljer kalender
        if(self.addToCalendarSwitch.on) {
        
            // Makes a request to use the calendar
            eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion: {
                granted, error in
                if(granted) && (error == nil) {
                    println("granted")
                    
                    // kollar om använder vill se om löprundan krockar med tillagda events
                    if(self.calendarCollisionSwitch.enabled && self.calendarCollisionSwitch.on) {
                        
                        var collides:Bool = true;
                        var interval = NSTimeInterval(duration * 60) // interval i sekunder
                        var startDate = start
                        var endDate = start.dateByAddingTimeInterval(interval) // lägger till duration på startdate
                        
                        // predikat som matchar alla event som ligger mellan start och start + duration
                        var predicate2 = eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: nil)
                        // hämtar alla events som matchar predikatet
                        var eV = eventStore.eventsMatchingPredicate(predicate2) as [EKEvent]!
                        
                        // kollar om evenStore är noll eller att det finns 0 events == ingen krock
                        if eV != nil {
                            if( eV.count == 0) {
                                collides = false // no entries
                            }
                        } else {
                            collides = false // event return nil, = no entries
                        }
                        
                        if(collides) { // eventet krockar
                            self.showErrorDialog("This run collides with another event!")
                            self.stopLoading()
                            return;
                        } else {
                            self.addRun(name, length: length, date:start, isCompleted: false, image: image, duration:duration)
                            var event = self.createCalendarEventFor(name, date: start, notes: "You have a scheduled run with RunJournal!", duration: duration, store:eventStore)
                            eventStore.saveEvent(event, span: EKSpanThisEvent, error: nil) // sparar eventet
                            self.dismissViewControllerAnimated(true, completion: nil) // dismissar vyn så man kommer tillbaka till start sidan
                            return;
                        }
                    }
                    
                    // lägger till eventet om användaren inte bryr sig om det krockar
                    self.addRun(name, length: length, date:start, isCompleted: false, image: image, duration:duration)
                    // lägger till i kalendern om det är valt
                    if(self.addToCalendarSwitch.on) {
                        var event = self.createCalendarEventFor(name, date: start, notes: "You have a scheduled run with RunJournal!", duration: duration, store:eventStore)
                        eventStore.saveEvent(event, span: EKSpanThisEvent, error: nil)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                } else {
                    // användaren vägrade ge tillåtelse till kalendern
                    self.showErrorDialog("Could not add event, permission not granted to calendr!")
                    self.stopLoading()
                }
            })
        
        } else {
            self.addRun(name, length: length, date: start, isCompleted: true, image: image, duration: duration)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        
    }
    
    @IBAction func cancelClick(sender: AnyObject) {
        println(openWeather.country)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Made by Sebastian Gunnarsson
    // visar popup dialog med givet felmeddelande
    func showErrorDialog(message:String) {
        var dialog = UIAlertView()
        dialog.title = message
        dialog.addButtonWithTitle("Ok")
        dialog.show()
    }
    
    // Made by Sebastian Gunnarsson
    // Visar popup för multipla fel
    func showErrorsDialog(messages:[String]){
        var dialog = UIAlertView()
        
        var errormess = ""
        
        for mess in messages
        {
            errormess += mess + "\n"
        }
        dialog.title = errormess
        dialog.addButtonWithTitle("OK")
        dialog.show()
        
    }
    
    @IBAction func addPictureClick(sender: AnyObject) {
        if(thumbnailImageView.image == nil) {
            var dialog = UIAlertView()
            dialog.delegate = self
            dialog.message = "Take a new photo or select an existing from your library."
            dialog.addButtonWithTitle("Camera")
            dialog.addButtonWithTitle("Photo Library")
            dialog.addButtonWithTitle("Cancel")
            dialog.title = "Select photo"
            dialog.show()
        } else {
            thumbnailImageView.image = nil
            addPictureButton.setTitle("Add Related Picture", forState: UIControlState.Normal)
        }
    }
    
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex{
        case 0:
            getPhoto(.Camera)
            break
        case 1:
            getPhoto(.SavedPhotosAlbum)
            break
        default:
            break
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        thumbnailImageView.image = image
        addPictureButton.setTitle("Remove Picture", forState: UIControlState.Normal)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func getPhoto(type: UIImagePickerControllerSourceType) {
        if (UIImagePickerController.isSourceTypeAvailable(type)){
            var imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = type
            imag.mediaTypes = [kUTTypeImage]
            imag.allowsEditing = false
            self.presentViewController(imag, animated: true, completion: nil)
        }
    }
    
    /*Image download*/
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: NSData(data: data))
            }.resume()
    }
    
    func downloadImage(url:NSURL){
        println("Started downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
        getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                println("Finished downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
                self.imageURL.image = UIImage(data: data!)
            }
        }
    }
    
}
