//
//  AddItemViewController.swift
//  WeatherPM_2
//
//  Created by macuser on 27/10/2018.
//  Copyright © 2018 pawmat. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class AddItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate{

    @IBOutlet weak var tableOutlet: UITableView!
    @IBOutlet weak var searchFieldOutlet: UITextField!
    @IBOutlet weak var findButtonOutlet: UIButton!
    @IBOutlet weak var locationOutlet: UILabel!
    
    var objects = [LocationForecast]()
    var selectedObject = LocationForecast()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableOutlet.rowHeight = 50
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = manager.location
        let geoCoder = CLGeocoder()
        var labelText = "Currently in: "
        geoCoder.reverseGeocodeLocation(currentLocation!, completionHandler: { (placemarks, error) -> Void in
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            labelText += placeMark.locality!
            labelText += ", "
            labelText += placeMark.country!
            self.locationOutlet.text = labelText
            })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableOutlet.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        cell.locationLabelOutlet.text! = objects[indexPath.row].name
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backFromAddView" {
            if let indexPath = tableOutlet.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                loadLocationForecasts(location: object)
                selectedObject = object;
            }
        }
    }
    
    @IBAction func findAction(_ sender: Any) {
        clearTableView()
        let phrase = searchFieldOutlet.text!
        let stringUrl = "https://www.metaweather.com/api/location/search?query=\(phrase)"
        let url = URL(string: stringUrl)!
        Alamofire.request(url).responseJSON{
            (response) in
            if let result = response.result.value{
                let locationsArray = result as! [[String:Any]]
                for i in 0..<locationsArray.count{
                    let location = LocationForecast()
                    location.id = ((locationsArray[i])["woeid"] as! Int)
                    location.name = ((locationsArray[i])["title"] as! String)
                    self.objects.append(location)
                }
                self.tableOutlet.beginUpdates()
                self.tableOutlet.insertRows(at: self.prepareIndexPaths(num: self.objects.count), with: .automatic)
                self.tableOutlet.endUpdates()
            }
        }
    }
    
    func prepareIndexPaths(num : Int) -> [IndexPath]{
        var indexPaths = [IndexPath]()
        for i in 0 ..< num{
            indexPaths.append(IndexPath(row: i, section: 0))
        }
        return indexPaths
    }
    
    func clearTableView() -> Void{
        self.tableOutlet.beginUpdates()
        self.tableOutlet.deleteRows(at: prepareIndexPaths(num: self.objects.count), with: .automatic)
        self.objects.removeAll()
        self.tableOutlet.endUpdates()
    }
    
    func loadLocationForecasts(location : LocationForecast){
        let group = DispatchGroup();
        group.enter()
        let urlString = "https://www.metaweather.com/api/location/\(String(location.id))/"
        let url = URL(string : urlString)!
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            if error != nil {
                return
            }
            let responseJson = data
            do{
                let response = try JSONSerialization.jsonObject(with: responseJson!) as! [String: Any]
                let array = response["consolidated_weather"] as! [[String:Any]]
                for i in 0...5{
                    let currentDayForecast = array[i]
                    let dateString = (currentDayForecast["applicable_date"] as! String)
                    let dateArray = dateString.split(separator: "-").map(String.init)
                    let dayForecast = DayConditions()
                    dayForecast.day = Int(dateArray[2])
                    dayForecast.month = Int(dateArray[1])
                    dayForecast.year = Int(dateArray[0])
                    dayForecast.conditionType = (currentDayForecast["weather_state_name"] as! String)
                    dayForecast.conditionTypeAbbr = (currentDayForecast["weather_state_abbr"] as! String)
                    dayForecast.temp = (currentDayForecast["the_temp"] as! Double)
                    dayForecast.windSpeed = (currentDayForecast["wind_speed"] as! Double)
                    dayForecast.maxTemp = (currentDayForecast["max_temp"] as! Double)
                    dayForecast.minTemp = (currentDayForecast["min_temp"] as! Double)
                    dayForecast.windDirection = (currentDayForecast["wind_direction_compass"] as! String)
                    dayForecast.airPressure = (currentDayForecast["air_pressure"] as! Double)
                    dayForecast.image = UIImage(named: dayForecast.conditionTypeAbbr! + ".png")
                    location.forecasts.append(dayForecast)
                }
                group.leave()
            }
            catch{
                group.leave()
                return
            }
        }
        task.resume()
        group.wait()
    }
}
