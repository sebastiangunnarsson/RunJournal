//
//  AddRunViewController.swift
//  RunJournal
//
//  Created by Viktor Roos on 2015-02-05.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import UIKit
import MobileCoreServices

extension NSDate {
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitHour, fromDate: date, toDate: self, options: nil).hour
    }
}

class AddRunViewController: ContextViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lengthTextView: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var weatherDescLabel: UILabel!
    @IBOutlet weak var imageURL: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        openWeather.test()
        // Do any additional setup after loading the view.
        
        imageURL.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func datePickerChange(sender: AnyObject) {
        var date = NSDate()
        
        var weatherIndex = datePicker.date.hoursFrom(date) / 24
        
        if(weatherIndex < 16 && weatherIndex > 0){
            weatherDescLabel.text =     openWeather.weatherList[weatherIndex].weather["icon"]
            var iconName = openWeather.weatherList[weatherIndex].weather["icon"]

            
            if let checkedUrl = NSURL(string: "http://openweathermap.org/img/w/" + iconName! + ".png") {
                downloadImage(checkedUrl)
            }
        }
        println(datePicker.date.hoursFrom(date) / 24)
    }
    
    
    @IBAction func addClick(sender: AnyObject) {
        if(!nameTextField.text.isEmpty) {
            var length:NSString = lengthTextView.text
            var imageData = thumbnailImageView.image == nil ? nil : UIImagePNGRepresentation(thumbnailImageView.image)
            addRun(nameTextField.text, length: length.doubleValue, date: datePicker.date, isCompleted: false, image: imageData)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func weatherButtonClick(sender: AnyObject) {
        weatherDescLabel.text = openWeather.weatherList[0].weather["description"]}
    
    @IBAction func cancelClick(sender: AnyObject) {
        println(openWeather.country)
        self.dismissViewControllerAnimated(true, completion: nil)
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
