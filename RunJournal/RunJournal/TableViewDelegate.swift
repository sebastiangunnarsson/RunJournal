//
//  TableViewDelegate.swift
//  RunJournal
//
//  Created by David Karlsson on 2015-03-09.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import UIKit

class TableViewDelegate: ContextViewController , UITableViewDelegate,UITableViewDataSource {
   
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        runs = getEntities("Run")
    }
    
    /* reloadRuns
     * Reloads different runs depending on filtering.
     *
     * Authors: Samuel Eklund, David Kalrsson. */
    func reloadRuns(val:Int) {
        
        switch(val)
        {
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
            break
        }
        //self.tableView.reloadData()
    }
    
    enum FilterType: Int {
        case  Scheduled = 0
        case Completed = 1
        case Passed = 2
        case All = 3
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
        
        if(run.isCompleted == true) {
            cell.completedLabel.text = "Completed"
            cell.completedLabel.textColor = UIColor.greenColor()
        }else if(dateHasPassed(run.date)){
            cell.completedLabel.text = "Passed"
            cell.completedLabel.textColor = UIColor.redColor()
        } else {
            cell.completedLabel.text = "Scheduled"
            cell.completedLabel.textColor = UIColor.orangeColor()
        }
        
        cell.nameLabel.text = run.name
        cell.dateLabel.text = NSDateFormatter.localizedStringFromDate(run.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        if(run.image != nil) {
            cell.thumbnailImageView.image = run.GetImage()
        } else {
            cell.thumbnailImageView.image = nil
            cell.thumbnailImageView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        }
        
        return cell
    }
    
}
