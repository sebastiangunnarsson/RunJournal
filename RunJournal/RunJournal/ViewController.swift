//
//  ViewController.swift
//  RunJournal
//
//  Created by David Karlsson on 2015-01-27.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import UIKit
var openWeather:OpenWeather = OpenWeather()

class ViewController: ContextViewController {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var rightTableView: UITableView!
    
    @IBOutlet weak var filterSegment: UISegmentedControl!
    
    var firstTableViewDelegate:TableViewDelegate!
    var secondTableViewDelegate:TableViewDelegate!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        firstTableViewDelegate = TableViewDelegate(coder: aDecoder)
        secondTableViewDelegate = TableViewDelegate(coder: aDecoder)
        
    }
    
    @IBAction func filterControlSelected(sender: AnyObject) {
        
        
            reloadRuns()
        
    }
    
    /*
        Hide the filter bar when landscape
    */
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if(UIDevice.currentDevice().orientation.rawValue == 3 ||
            UIDevice.currentDevice().orientation.rawValue == 4){
                filterSegment.hidden = true
                secondTableViewDelegate.reloadRuns(FilterType.Scheduled.rawValue)
                secondTableViewDelegate.reloadRuns(FilterType.Completed.rawValue)
                
        } else {
            filterSegment.hidden = false
            firstTableViewDelegate.reloadRuns(filterSegment.selectedSegmentIndex)
        }
    }
    
    func reloadRuns() {
        
        firstTableViewDelegate.reloadRuns(filterSegment.selectedSegmentIndex)
        secondTableViewDelegate.reloadRuns(filterSegment.selectedSegmentIndex)
        
        self.tableView.reloadData()
        self.rightTableView.reloadData()
    }
    
    enum FilterType: Int {
        case Completed = 0
        case Scheduled = 1
        case All = 2
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = firstTableViewDelegate
        tableView.dataSource = firstTableViewDelegate
        tableView.allowsMultipleSelectionDuringEditing = false
        
        rightTableView.delegate = secondTableViewDelegate
        rightTableView.dataSource = secondTableViewDelegate
        rightTableView.allowsMultipleSelectionDuringEditing = false
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        
        reloadRuns()
        
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
            var objId = self.firstTableViewDelegate!.runs?[indexRow!].objectID
            dvc.objId = objId
        } else if( segue.identifier == "runDetailsSecond") {
            var dvc = segue.destinationViewController as RunDetailsViewController
            var indexRow = self.rightTableView.indexPathForSelectedRow()?.row
            var objId = self.secondTableViewDelegate!.runs![0].objectID
            dvc.objId = objId
        }
    }
    
    
}

