//
//  RunDetailedController.swift
//  RunJournal
//
//  Created by Samuel Eklund on 2015-02-17.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class RunMapController: ContextViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startRunBtn: UIButton!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var locationManager:CLLocationManager!
    var myLocations: [CLLocation] = []
    var oldLocation:CLLocation!;
    var totalDistane:Double = 0;
    var objId:NSManagedObjectID?

    var timer:NSTimer?
    var start:NSDate?
    
    var allRuns:[Run]!
    var run:Run!
    
    func timeFormat(since:NSDate) -> String {
        
        var timePassed = Int(NSDate().timeIntervalSinceDate(since))
        
        var hourStr:String = "", minStr:String = "", secStr:String = ""
        
        var mins = timePassed / 60
        var hours = mins / 60
        var seconds = timePassed % 60
        
        if(hours > 0) {
            hourStr = "\(hours) h"
        }
        
        if(mins > 0 || (mins == 0 && hours > 1)) {
            minStr = "\(mins) m"
        }
        
        return "Elapsed time: " + hourStr + " " + minStr + " \(seconds) s"
        
    }
    
    func update() {
        timeLabel.text = timeFormat(start!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsBuildings = true
        createLocationManager()
        
        
        
        allRuns = getEntities("Run") as [Run]
        run = getRunByObjectId(objId!)
        
        var i = 0
        var sourceLocation:Location!
        
        for location in run.locations.array{
            startRunBtn.hidden = true
            var currentLocation = location as Location
            if i == 1 {
                var anotation = MKPointAnnotation()
                var latitude = currentLocation.latitude as CLLocationDegrees
                var longitude = currentLocation.longitude as CLLocationDegrees
                anotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                anotation.title = "Start Location"
                anotation.subtitle = "This is the runs start location!"
                mapView.addAnnotation(anotation)
            }
            
            if (i > 1){
                let location1 = CLLocationCoordinate2D(
                    latitude: sourceLocation.latitude as Double,
                    longitude: sourceLocation.longitude as Double
                )
                
                let location2 = CLLocationCoordinate2D(
                    latitude: currentLocation.latitude as Double,
                    longitude: currentLocation.longitude as Double
                )
                
                var newRegion = MKCoordinateRegion(center: location1, span: MKCoordinateSpanMake(0.005, 0.005))
                mapView.setRegion(newRegion, animated: true)
                
                var a = [location1, location2]
                mapView.setCenterCoordinate(location1, animated: true)

                var polyline = MKPolyline(coordinates: &a, count: a.count)
                self.mapView.addOverlay(polyline, level: MKOverlayLevel.AboveLabels)
                
                if i == run.locations.count - 1 {
                    var anotation = MKPointAnnotation()
                    var latitude = currentLocation.latitude as CLLocationDegrees
                    var longitude = currentLocation.longitude as CLLocationDegrees
                    anotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    anotation.title = "End Location"
                    anotation.subtitle = "This is the runs end location!"
                    mapView.addAnnotation(anotation)
                }
            }
            sourceLocation = location as Location
            i = i + 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onRunDetailsClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
   /* createLocationManager()
    * Initialize member varible, locationManager.
    *
    * Author: Samuel Eklund
    */
    func createLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 20
        locationManager.activityType = .Fitness
        locationManager.requestAlwaysAuthorization()
    }
    
   /* locationManager(didUpdateLocations)
    * Handels CLLocation location updates.
    * Updates mapView and draws polyline, new location are also stored in myLocations.
    *
    * Author: Samuel Eklund
    */
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let currentLocation = locations.first as? CLLocation
        {
            myLocations.append(currentLocation)
            
            
            
            mapView.setCenterCoordinate(currentLocation.coordinate, animated: true)
            
            var newRegion = MKCoordinateRegion(center: currentLocation.coordinate, span: MKCoordinateSpanMake(0.005, 0.005))
            mapView.setRegion(newRegion, animated: true)
            
            if (myLocations.count > 1){
                var sourceIndex = myLocations.count - 1
                var destinationIndex = myLocations.count - 2
                
                let c1 = myLocations[sourceIndex].coordinate
                let c2 = myLocations[destinationIndex].coordinate
                var a = [c1, c2]
                
                println(c1.latitude)
                println(c1.longitude)
                
                var polyline = MKPolyline(coordinates: &a, count: a.count)
                mapView.addOverlay(polyline)
                
                let delta: Double = myLocations[destinationIndex].distanceFromLocation(myLocations[sourceIndex])
                totalDistane += delta
            }
            distanceLabel.text = String(format: "Distance:          %.2f km", totalDistane / 1000.0)
        }
    }
    
   /* startRunClick()
    * (Missleading name) Handels user start/stop run interation.
    *
    * Author: Samuel Eklund
    */
    @IBAction func startRunClick(sender: AnyObject) {
        if startRunBtn.titleLabel?.text == "Start run session" {
            startRunBtn.setTitle("End run session", forState: UIControlState.Normal)
            startRunBtn.backgroundColor = UIColor.cyanColor()
            locationManager.startUpdatingLocation()
            start = NSDate()
            timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
            
        }else if startRunBtn.titleLabel?.text == "End run session" {
            startRunBtn.setTitle("Start run session", forState: UIControlState.Normal)
            timer?.invalidate()
            showSaveDialog()
        }
    }
   
   /* showSaveDialog()
    * Asks user if current run should be saved.
    *
    * Author: Samuel Eklund
    */
    func showSaveDialog() {
        var dialog = UIAlertView()
        dialog.delegate = self
        dialog.message = "Would you like to save current run session?"
        dialog.addButtonWithTitle("End and save")
        dialog.addButtonWithTitle("Clear run")
        dialog.addButtonWithTitle("Cancel")
        dialog.title = "Save Run"
        dialog.show()
    }
   
   /* alertView()
    * Handels alert view Click.
    *
    * Author: Samuel Eklund
    */
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex{
        case 0:
            storeRunSessionData()
            locationManager.stopUpdatingLocation()
            startRunBtn.hidden = true
            run.isCompleted = true
            run.actualLength = totalDistane
            saveEntities()
            break
        case 1:
            locationManager.stopUpdatingLocation()
            myLocations = []
            break
        default:
            break
        }
    }
   
   /* storeRunSessionData()
    * Stores current run session in coreData.
    *
    * Author: Samuel Eklund
    */
    func storeRunSessionData(){
        var locationArray = NSMutableArray()
        for location:CLLocation in self.myLocations {
            let newItem = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: self.manageContext) as Location
            newItem.latitude = location.coordinate.latitude
            newItem.longitude = location.coordinate.longitude
            newItem.run = run
            locationArray.addObject(newItem)
        }
        
        
        saveEntities()
    }
    
 
    
    /* mapView(MKMapView!, MKOverlay!) -> MKOverlayRenderer!
     * Returns polylineRender that will be used when printing line on map.
     * 
     * Author: Samuel Eklund
     */
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        println(overlay)

        if overlay is MKPolyline {

            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.lightGrayColor()
            polylineRenderer.lineWidth = 3
            return polylineRenderer
        }
        return nil
    }
}
