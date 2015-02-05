//
//  AddRunViewController.swift
//  RunJournal
//
//  Created by Viktor Roos on 2015-02-05.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import UIKit
import MobileCoreServices


class AddRunViewController: ContextViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lengthTextView: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var thumbnailImageView: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addClick(sender: AnyObject) {
        if(!nameTextField.text.isEmpty) {
            var length:NSString = lengthTextView.text
            var imageData = thumbnailImageView.image == nil ? nil : UIImagePNGRepresentation(thumbnailImageView.image)
            addRun(nameTextField.text, length: length.doubleValue, date: datePicker.date, isCompleted: false, image: imageData)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    @IBAction func cancelClick(sender: AnyObject) {
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
}
