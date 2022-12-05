//
//  ViewController.swift
//  iosproject2
//
//  Created by Athul Tony on 2022-12-04.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var onSearchText: UITextField!
    
    @IBOutlet weak var onWeatherCondition: UIImageView!
    
    @IBOutlet weak var onTempLabel: UILabel!
    
    @IBOutlet weak var onWeatherLabel: UILabel!
    @IBOutlet weak var onLocationLabel: UILabel!
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        displayTempImage()
        onSearchText.delegate = self
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        print(textField.text ?? "")
        return true
    }
    
    private func displayTempImage(){
        let config = UIImage.SymbolConfiguration(paletteColors: [
            .systemRed, .systemOrange, .systemTeal
        ])
        onWeatherCondition.preferredSymbolConfiguration = config
        
        onWeatherCondition.image = UIImage(systemName: "sun.max")
        
    }

    @IBAction func onLocationBtn(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.requestLocation()
    }
    
    private func displayLocation(locationText: String) {
        onLocationLabel.text = locationText
    }
    
    @IBAction func onSearchBtn(_ sender: UIButton) {
        weatherLoad(search: onSearchText.text)
    }
    
    private func weatherLoad(search: String?){
        guard let search = search else {
           
            return
        }
        
        guard let url = getURL(query: search) else {
            print("Cannot get the url")
            return
        }
        
        let session = URLSession.shared
        
         let dataTask = session.dataTask(with: url)  { data, response, error in
            print("Network call is completed")
             
             guard error == nil else {
                 print("Recieved error")
                 return
             }
             
             guard let data = data else {
                 print("No data")
                 return
             }
              
             if let weatherResponse = self.parseJson(data: data) {
                 print(weatherResponse.location.name)
                 print(weatherResponse.current.temp_c)
                 print(weatherResponse.current.condition.text)
                 var code = weatherResponse.current.condition.code
                 DispatchQueue.main.async {
                     self.onLocationLabel.text = weatherResponse.location.name
                     self.onTempLabel.text = "\(weatherResponse.current.temp_c)C"
                     self.onWeatherLabel.text=weatherResponse.current.condition.text
                     
                     if (code == 1000) {
                         self.onWeatherCondition.image = UIImage(systemName: "sun.max")
                     }
                     else if (code == 1003) {
                         self.onWeatherCondition.image = UIImage(systemName: "cloud")
                     }
                     else if (code == 1006) {
                         self.onWeatherCondition.image = UIImage(systemName: "cloud.fill")
                     }
                     else if (code == 1114) {
                         self.onWeatherCondition.image = UIImage(systemName: "snowflake")
                     }
                     else if (code == 1183) {
                         self.onWeatherCondition.image = UIImage(systemName: "cloud.drizzle")
                     }
                     else if (code == 1195) {
                         self.onWeatherCondition.image = UIImage(systemName: "cloud.rain")
                     }
                 }
                 
             }
        }
        
        dataTask.resume()
    }
    
    private func getURL(query: String) -> URL?{
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "511594a4f2a54606900233417220412"
        guard let url = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        print(url)
        
        return URL(string: url)
        
    }
    
    private func parseJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
       var weather: WeatherResponse?
       do{
           weather = try decoder.decode(WeatherResponse.self, from: data)
       } catch {
           print("Error decoding")
       }
        return weather
    }
    
    
    
    
}
struct WeatherResponse: Decodable{
     let location: Location
     let current: Weather
 }
 struct Location: Decodable {
     let name: String
 }
 struct Weather: Decodable {
     let temp_c: Float
     let condition: WeatherCondition
 }
 struct WeatherCondition : Decodable{
     let text: String
     let code: Int
 }

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got the Location")
        
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print("LatLng: (\(latitude),\(longitude))")
            displayLocation(locationText: "(\(latitude),\(longitude))")
        }
    }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}












