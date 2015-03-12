//
//  DataManager.swift
//  RunJournal
//
//  Created by Samuel Eklund on 2015-02-07.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import Foundation

let openWeatherURL = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=57.766666&lon=14.150000&cnt=16&mode=json"

class DataManager {
    
    /*
     * get16DaysForecastDataFromOpenWeatherMap(openWeatherData)
     * Featches data from openWeather API and sets the respons to openWeatherData param.
     *
     * Author: Samuel Eklund
     * Date: 2015-02-27
     */
    class func get16DaysForecastDataFromOpenWeatherMapJSON(success: ((openWeatherData: NSData!) -> Void)) {
        loadDataFromURL(NSURL(string: openWeatherURL)!, completion:{(data, error) -> Void in
            if let urlData = data {
                success(openWeatherData: urlData)
            }
        })
    }

    /*
     * loadDataFromURL(url, Completion:(data, error))
     * Loads data from url param, iff success, data are stored and error is set to nil.
     * Else error message is stored in error param.
     *
     * Author: Samuel Eklund
     * Date: 2015-02-07
     */
    class func loadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
        var session = NSURLSession.sharedSession()
        
        // Uses NSURLSession to get data from openWeatherURL Asyncronus.
        let loadDataTask = session.dataTaskWithURL(url, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            // Checks for responsErrors.
            if let responseError = error {
                completion(data: nil, error: responseError)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                // Checks if statuscode is 200, if not, status error are set, else data is set.
                if httpResponse.statusCode != 200 {
                    var statusError = NSError(domain:"", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                } else {
                    completion(data: data, error: nil)
                }
            }
        })
        loadDataTask.resume()
    }
}