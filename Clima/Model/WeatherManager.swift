//
//  WeatherManager.swift
//  Clima
//
//  Created by FENTON, EDWARD F on 1/3/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager , weather: WeatherModel)
    func didFailWithError(error: Error)
}


struct WeatherManager{
    
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=1285c796b06c2212beb936549baaa0e4&units=imperial"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let  urlString = ("\(weatherURL)&q=\(cityName)")
       
        performRequest(with: urlString)
        
    }
    func fetchWeather(longitude: CLLocationDegrees , latitude: CLLocationDegrees){
        let urlString = ("\(weatherURL)&lon=\(longitude)&lat=\(latitude)")
        
        performRequest(with: urlString)
        
    }
    
    func performRequest(with urlString: String){
        //1.create URL
        if let url = URL(string: urlString){
            //2. Create URLSession
            
            let session = URLSession(configuration: .default)
            
            //3.Give the session a task
            
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                        
                    }
                }
            }
            task.resume()
        }
    }
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
            let lon = decodedData.coord.lon
            let lat = decodedData.coord.lat
            
           //print(decodedData.weather[0].id)
            
            let weather = WeatherModel(conditionID: id, cityName: name, temperature: temp, longitude: lon, latitude: lat)
            //print(weather.temperatureString)
            return weather
        }
        catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
}

