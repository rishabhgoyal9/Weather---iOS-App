//
//  WeatherViewController.swift
//  Weather App
//
//  Created by Rishabh Goyal on 14/03/22.
//

import UIKit
import CoreLocation // Determine current Latitude & Longitude of a Device
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController , getLocationofUserChoice , CLLocationManagerDelegate {
    
    // CLLocationManagerDelegate -> The methods that you use to receive events from an associated location manager object.
    let locationManager = CLLocationManager()
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = Appid().APP_ID
    
    let weatherDataModel = WeatherDataModel( ) // object of class
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print( "in VC1 ")
        cityNameLabel.numberOfLines = 0
        
        //MARK: Setting up GPS on Device
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // requestWhenInUseAuthorization looks for key value in plist so add there
        locationManager.requestWhenInUseAuthorization() // request for location access
        locationManager.startUpdatingLocation()
        
    }

    //MARK: -
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Tells the delegate that new location is available
        // locationManager.startUpdatingLocation() -> each time it get new value -> it adds it on the didUpdateLocations array -> locations: [CLLocation] -> therefore , last value in array is more accurate....
        
        let location = locations[locations.count - 1]
        
        // as soon as result found -> stop updating location
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            // key name acc to => https://openweathermap.org/current
            let locationDict : [String:String] = [ "lat" : String(location.coordinate.latitude),
                            "lon" : String(location.coordinate.longitude),
                            "appid" : APP_ID ]
            locationManager.delegate = nil
            getWeatherData(url: WEATHER_URL, parameters: locationDict)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Tells the delegate that new locationManager is unable to retrieve a location due to airplane mode, net off, etc ..
        print("Error : Fail in location manager => Message :  " , error )
        cityNameLabel.text = "Location Unavailable :("
    }
   
    
    //MARK: Networking
    
    func getWeatherData( url : String , parameters : [String : String] ){
        Alamofire.request( url , method: .get , parameters: parameters ).responseJSON{
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                // response.result.value is of type Any?
                let weatherJSON :JSON = JSON(response.result.value!)
                // JSON - data type is accessable only because of SwiftyJSON
                
                print(weatherJSON)
                self.parseWeatherData(json: weatherJSON)
                
            }else{
                print( "Error occurs =>  " , response.result.error! )
                
                self.cityNameLabel.text = "Connection Issues :("
            }
        }
        
    }
    
    func parseWeatherData(json : JSON){
        // parse response and fill in object
        // .double = Double? & doubleValue is sure double
        // as we in if loop so need optional..... so use double .. not doubleValue
        
        if let tempResult = json["main"]["temp"].double {
            // - 273.15 ( kelvin to celcius )
            weatherDataModel.temperature = Int(tempResult-273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherConditionName = json["weather"][0]["description"].stringValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition )
            updateUIWeatherData( )
        }else{
            // possibility that result is success but city not found so..
//            Success! Got the weather data
//            {
//              "message" : "city not found",
//              "cod" : "404"
//            }
            
            cityNameLabel.text = "Unavailable :("
        }
    }
    
    func updateUIWeatherData( ){
        // weatherDataModel obj currently contains data from gps...
        // now update UI using that data
        
        cityNameLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)℃"
        weatherConditionLabel.text = weatherDataModel.weatherConditionName
        // image name is given by weatherdtamodel class function acc to id passed
        //  this image is present in assets
        weatherImageView.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToLocationVC" {
            let locationVC = segue.destination as! LocationViewController
            locationVC.delegate = self
        }
    }
    
    // providing body to Protocol fn
    func getLocation(location:String){
        print(location)
        
        // q -> cityname & appid -> APP_ID given in open weather ...
        let locationDict : [String:String] = [ "q" : location ,
                                               "appid" : APP_ID
        ]
        // call method
        getWeatherData(url: WEATHER_URL, parameters: locationDict)
        
    }
    
    @IBAction func button_pressed(_ sender: UIButton) {
        // segue performed automatically on pressing button as segue is set with ( button to VC ) and not with (VC to VC ) , no need to trigger it explicitly with function perform segue

        print("clicked on button on VC-1")
    }
    
}

