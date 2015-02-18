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

class AddRunViewController: ContextViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate {

    
    
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lengthTextView: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var addToCalendarSwitch: UISwitch!
    @IBOutlet weak var calendarCollisionSwitch: UISwitch!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var calendarCollisionLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    
    var loadingSpinner:UIActivityIndicatorView!
    
    // References to the weather label and weather image
    @IBOutlet weak var weatherTextLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //contentView.userInteractionEnabled = false
        calendarCollisionLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        
        // Do any additional setup after loading the view.
    }

    
    
    @IBAction func addToCalendarSwitchDidChange(sender: AnyObject) {
        
        calendarCollisionSwitch.enabled = true
        
        calendarCollisionLabel.textColor = (addToCalendarSwitch.on == true) ? UIColor.blackColor() : UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func addClick(sender: AnyObject) {
        
        self.startLoading()
        
        nameTextField.resignFirstResponder()
        durationTextField.resignFirstResponder()
        lengthTextView.resignFirstResponder()
       
        if(!nameTextField.text.isEmpty) {
            
            if(durationTextField.text.isEmpty){
                showErrorDialog("Duration is required!")
                stopLoading()
            }
            
            var duration:Int = (durationTextField.text as NSString).integerValue
            var length:NSString = lengthTextView.text
            var imageData = thumbnailImageView.image == nil ? nil : UIImagePNGRepresentation(thumbnailImageView.image)
            
            addRunWith(nameTextField.text, length: length.doubleValue, start: datePicker.date, duration: duration, image: imageData)
        } else {
            showErrorDialog("Name is required!")
            stopLoading()
        }
    }
    
    func createCalendarEventFor(title:String, date:NSDate, notes:String, duration:Int, store:EKEventStore) -> EKEvent {
        
        let components = getComponentsFromDate(date);
        let year:Int = components!.year
        let month:Int = components!.month
        let day:Int = components!.day
        let hour:Int = components!.hour
        let min:Int = components!.minute
        
        // get the start date
        let startDate = createDate(year, month: month, day: day, hour: hour, minute: min, second: 0)
        
        // get the end date by adding the duration
        let endDate = startDate?.dateByAddingTimeInterval(NSTimeInterval(60*duration))
        
        
        var event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
        event.calendar = store.defaultCalendarForNewEvents
        
        return event
        //store.saveEvent(event, span: EKSpanThisEvent, error: &error)
        
        
        
    }
    
    // check if anything in the default calendar collides with the given date
    func addRunWith(name:String, length:Double, start:NSDate, duration:Int, image: NSData?) {
        
        var eventStore = EKEventStore()
        
        // Förfrågar om att få använda kalendern
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
        
        
        
        
    }


    
    @IBAction func cancelClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // visar popup dialog med givet felmeddelande
    func showErrorDialog(message:String) {
        var dialog = UIAlertView()
        dialog.title = message
        dialog.addButtonWithTitle("Ok")
        dialog.show()
    }
    
    @IBAction func addPictureClick(sender: AnyObject) {
        var dialog = UIAlertView()
        dialog.delegate = self
        dialog.message = "Take a new photo or select an existing from your library."
        dialog.addButtonWithTitle("Camera")
        dialog.addButtonWithTitle("Photo Library")
        dialog.title = "Select photo"
        dialog.show()
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
}
