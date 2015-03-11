//
//  RunDetailsViewController.swift
//  RunJournal
//
//  Created by David Karlsson on 2015-02-28.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import UIKit
import CoreData
import MobileCoreServices
import EventKit

class RunDetailsViewController: ContextViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate {

    
    @IBOutlet weak var startRunButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lengthTextField: UITextField!
    @IBOutlet weak var enableEditingSwitch: UISwitch!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var relatedPicImageView: UIImageView!
    @IBOutlet weak var addRelatedPicButton: UIButton!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    var objId:NSManagedObjectID?
    var run:Run?
    
    override func viewDidLoad() {
        run = getRunByObjectId(self.objId!)
        nameTextField.text = run!.name
        durationTextField.text = "\(run!.duration!)"
        lengthTextField.text = "\(run!.length)"
        datePicker.date = run!.date
        if(run?.image != nil) {
            relatedPicImageView.image = run?.GetImage()
            addRelatedPicButton.setTitle("Remove Picture", forState: UIControlState.Normal)
        }
        addRelatedPicButton.enabled = false
        saveBarButton.enabled = false
        
        // disable start run if its completed or passed
        if(run!.isCompleted == true || dateHasPassed(run!.date)){
            startRunButton.enabled = false
        }
        
    }
    
    @IBAction func OnSaveClicked(sender: AnyObject) {
        var duration:Int = (durationTextField.text as NSString).integerValue
        var length:Int = (lengthTextField.text as NSString).integerValue
        var name:NSString = nameTextField.text
        var imageData = relatedPicImageView.image == nil ? nil : UIImageJPEGRepresentation(relatedPicImageView.image, 0.1)
    
        run?.name = name
        run?.duration = duration
        run?.length = length
        run?.date = datePicker.date
        run!.image = imageData
        
        run?.managedObjectContext?.save(nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func OnCancelClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
   
    
    
    @IBAction func onEnableEditingSwitchChanged(sender: AnyObject) {
        nameTextField.enabled = (enableEditingSwitch.on == true) ? true : false
        
        durationTextField.enabled = (enableEditingSwitch.on == true) ? true : false
        
        lengthTextField.enabled = (enableEditingSwitch.on == true) ? true : false
        
        datePicker.userInteractionEnabled = (enableEditingSwitch.on == true) ? true : false

        addRelatedPicButton.enabled = (enableEditingSwitch.on == true) ? true : false

        saveBarButton.enabled = (enableEditingSwitch.on == true) ? true : false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
            let dvc = segue.destinationViewController as RunMapController
            dvc.objId = objId
        
        
    }
    
    
    @IBAction func relatedButtonClick(sender: AnyObject) {
        if(relatedPicImageView.image == nil) {
            var dialog = UIAlertView()
            dialog.delegate = self
            dialog.message = "Take a new photo or select an existing from your library."
            dialog.addButtonWithTitle("Camera")
            dialog.addButtonWithTitle("Photo Library")
            dialog.addButtonWithTitle("Cancel")
            dialog.title = "Select photo"
            dialog.show()
        } else {
            relatedPicImageView.image = nil
            addRelatedPicButton.setTitle("Add Related Picture", forState: UIControlState.Normal)
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
        relatedPicImageView.image = image
        addRelatedPicButton.setTitle("Remove Picture", forState: UIControlState.Normal)
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
