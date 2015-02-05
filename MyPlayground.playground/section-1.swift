// Playground - noun: a place where people can play

import UIKit

let urlAsString = "http://date.jsontest.com"
let url = NSURL(string: urlAsString)

let urlSession = NSURLSession.sharedSession()

let jsonQuery = urlSession.dataTaskWithURL(url, completionHandler: { data! , response, error -> Void in
    if (error != nil) {
        println(error.localizedDescription)
    }
    
    var err:NSError?
    
    var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
    
    if(err != nil) {
        println("Json Error")
    }
    
    let jsonDate: String! = jsonResult["date"] as NSString
    let jsonTime: String! = jsonResult["time"] as NSString
    
    dispatch_async(dispatch_get_main_queue(), {
        println(jsonDate)
        println(jsonTime)
    })
    
    
})

jsonQuery.resume()
