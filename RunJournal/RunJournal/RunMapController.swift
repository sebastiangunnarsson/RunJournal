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
    
    var locationManager:CLLocationManager!
    var myLocations: [CLLocation] = []
    var oldLocation:CLLocation!;
    var totalDistane:Double = 0;
    var objId:NSManagedObjectID?
    
    var allRuns:[Run]!
    var run:Run!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //distanceLabel.text = "\(runIndexPath)"
        self.mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsBuildings = true
        createLocationManager()
        
        allRuns = getEntities("Run") as [Run]
        run = getRunByObjectId(objId!)
        
      //  println("Locations \(run.locations)")
        
        var i = 0
        var sourceLocation:Location!
        
        for location in run.locations.array{
            var currentLocation = location as Location
            if (i > 1){
                println( sourceLocation.latitude)
                println( sourceLocation.longitude)

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
            }
            sourceLocation = location as Location
            i = i + 1
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 20
        locationManager.activityType = .Fitness
        locationManager.requestAlwaysAuthorization()

    }
    
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
        }
    }
    
    @IBAction func startRunClick(sender: AnyObject) {
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func stopRunClick(sender: AnyObject) {
        locationManager.stopUpdatingLocation()
        
        var locationArray = NSMutableArray()
        
        for location:CLLocation in self.myLocations {
            let newItem = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: self.manageContext) as Location
            
            newItem.latitude = location.coordinate.latitude
            newItem.longitude = location.coordinate.longitude
            newItem.run = run
            locationArray.addObject(newItem)
        }
        println(locationArray)
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
            polylineRenderer.lineWidth = 6
            return polylineRenderer
        }
        return nil
    }
    

}
