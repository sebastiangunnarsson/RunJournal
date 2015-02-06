//
//  ViewController.swift
//  RunJournal
//
//  Created by David Karlsson on 2015-01-27.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import UIKit

class ViewController: ContextViewController, UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelectionDuringEditing = false
    }
    
    override func viewWillAppear(animated: Bool) {
        runs = getEntities("Run") as [Run]
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runs!.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if(editingStyle == UITableViewCellEditingStyle.Delete) {
            let run = runs?[indexPath.row] as Run
            deleteRun(run)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RunTableCell", forIndexPath: indexPath) as RunTableCell
        
        let run = runs?[indexPath.row] as Run
        
        cell.nameLabel.text = run.name
        cell.dateLabel.text = NSDateFormatter.localizedStringFromDate(run.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        if(run.image != nil) {
            cell.thumbnailImageView.image = run.GetImage()
        }
        
        return cell
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
}

