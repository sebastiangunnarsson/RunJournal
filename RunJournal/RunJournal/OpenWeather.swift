//
//  OpenWeather.swift
//  RunJournal
//
//  Created by Samuel Eklund on 2015-02-07.
//  Copyright (c) 2015 David Karlsson. All rights reserved.
//

import Foundation

/* OpenWeather Class.
 * 
 * Author: Samuel Eklund */
class OpenWeather {
    var city: [String: String] = [
        "id": "",
        "name": ""
    ]
    var cords: [String: Float?] = [
        "lon": nil,
        "lat": nil
    ]
    var country = ""
    var weatherList:[Weather] = []
    
    /* loadWeatherData()
     *
     */
    func loadWeatherData(){
        DataManager.get16DaysForecastDataFromOpenWeatherMapJSON{ (openWeatherData) -> Void in
            let json = JSON(data: openWeatherData)
            
            // City ID
            if let cityID = json["city"]["id"].stringValue {
                self.city["name"] = cityID
            }
            // City Name
            if let cityName = json["city"]["name"].stringValue {
                self.city["name"] = cityName
            }
            // City Cordinates Lon
            if let cityCordLon = json["city"]["coord"]["lon"].floatValue {
                self.cords["lon"] = cityCordLon
            }
            // City Cordinates Lat
            if let cityCordLat = json["city"]["coord"]["lat"].floatValue {
                self.cords["lon"] = cityCordLat
            }
            // Country
            if let country = json["city"]["country"].stringValue {
                self.country = country
            }
            if let weatherList = json["list"].arrayValue {
                // parses weatherList to weatherObjects.
                for weatherObject in weatherList {
                    var tempWeather = Weather()
                    // Temp
                    if let temp = weatherObject["temp"]["day"].doubleValue {
                        tempWeather.temp = temp - 273.15
                    }
                    // Description
                    if let weatherDesc = weatherObject["weather"]["desc"].stringValue {
                        tempWeather.weather["description"] = weatherDesc
                    }
                    // Pressure
                    if let pressure = weatherObject["pressure"].doubleValue {
                        tempWeather.pressure = pressure
                    }
                    // Humidity
                    if let humidity = weatherObject["humidity"].integerValue {
                        tempWeather.humidity = humidity
                    }
                    // WeatherID
                    if let weatherID = weatherObject["weather"][0]["id"].stringValue {
                        tempWeather.weather["id"] = weatherID
                    }
                    if let weatherDesc = weatherObject["weather"][0]["description"].stringValue {
                        tempWeather.weather["description"] = weatherDesc
                    }
                    // Clouds
                    if let weatherClouds = weatherObject["clouds"].stringValue {
                        tempWeather.weather["clouds"] = weatherClouds
                    }
                    // Icon
                    if let weatherIcon = weatherObject["weather"][0]["icon"].stringValue {
                        tempWeather.weather["icon"] = weatherIcon
                    }
                    self.weatherList.append(tempWeather)
                }
            }
        }
    }
}

/* Weather class
 * Holds weather info.
 *
 * Author: Samuel Eklund. */
class Weather {
    var temp = 0.0
    var pressure = 0.0
    var humidity = 0
    var weather: [String:String] = [
        "id": "",
        "clouds" : "",
        "description": "",
        "icon" : ""
    ]
}
