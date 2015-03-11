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
        runs = getEntities("Run") as [Run]
    }
    
    
    func reloadRuns(val:Int) {
        
        switch(val)
        {
        case 0:
            runs = getCompletedRuns()
            break
        case 1:
            runs = getScheduledRuns()
            break
        default:
            runs = getEntities("Run") as [Run]
            break
        }
        //self.tableView.reloadData()
    }
    
    enum FilterType: Int {
        case  Elapsed = 0
        case Coming = 1
        case All = 2
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
        } else {
            cell.thumbnailImageView.image = nil
        }
        
        return cell
    }
    
}
