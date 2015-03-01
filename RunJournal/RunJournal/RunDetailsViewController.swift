//
//  RunDetailsViewController.swift
//  RunJournal
//
//  Created by David Karlsson on 2015-02-28.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import UIKit
import CoreData

class RunDetailsViewController: ContextViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lengthTextField: UITextField!
    @IBOutlet weak var enableEditingSwitch: UISwitch!
    
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    var objId:NSManagedObjectID?
    var run:Run?
    
    override func viewDidLoad() {
        run = getRunByObjectId(self.objId!)
        nameTextField.text = run!.name
        durationTextField.text = "\(run!.duration!)"
        
        lengthTextField.text = "\(run!.length)"
        datePicker.date = run!.date
    }
    
    @IBAction func OnSaveClicked(sender: AnyObject) {
        
    }
    
    @IBAction func OnCancelClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
   
    @IBAction func onEnableEditingSwitchChanged(sender: AnyObject) {
        nameTextField.enabled = (enableEditingSwitch.on == true) ? true : false
        
        durationTextField.enabled = (enableEditingSwitch.on == true) ? true : false
        
        lengthTextField.enabled = (enableEditingSwitch.on == true) ? true : false
        
        datePicker.userInteractionEnabled = (enableEditingSwitch.on == true) ? true : false

        
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
            let dvc = segue.destinationViewController as RunMapController
            dvc.objId = objId
        
        
    }
    

}
