//
//  ViewController.swift
//  RunJournal
//
//  Created by David Karlsson on 2015-01-27.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import UIKit
var openWeather:OpenWeather = OpenWeather()

class ViewController: ContextViewController, UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    
    @IBOutlet weak var filterSegment: UISegmentedControl!
    
    @IBAction func filterControlSelected(sender: AnyObject) {
            reloadRuns()
    }
    
    func reloadRuns() {
        switch(filterSegment.selectedSegmentIndex)
        {
        case FilterType.Elapsed.rawValue:
            runs = getPreviouslyScheduledRuns()
            break
        case FilterType.Coming.rawValue:
            runs = getUpcomingScheduledRuns()
            break
        default:
            runs = getEntities("Run") as [Run]
            break
        }
        self.tableView.reloadData()
    }
    
    enum FilterType: Int {
        case  Elapsed = 0
        case Coming = 1
        case All = 2
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelectionDuringEditing = false
    }
    
    override func viewWillAppear(animated: Bool) {
        
        reloadRuns()
        
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
    
    /* Select row in table view.
     * Displays title detail page.
     *
     * Author: Samuel Eklund.
     */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //self.performSegueWithIdentifier("runDetail", sender: tableView)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if(segue.identifier ==  "runDetail") {
            var dvc = segue.destinationViewController as RunDetailsViewController
            var indexRow = self.tableView.indexPathForSelectedRow()?.row
            var objId = runs?[indexRow!].objectID
            dvc.objId = objId
        }
        //var x = runs![indexRow!].objectID
        
    }
    
    
}

