//
//  MasterViewController.swift
//  WeatherPM_2
//
//  Created by macuser on 23/10/2018.
//  Copyright © 2018 pawmat. All rights reserved.
//

import UIKit
import Alamofire

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    let maxDayIndex = 5;
    let group = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.preload3Locations()
        print("wait")
        group.wait()
        print("after wait")
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
//        let newObject = LocationForecast()
//        newObject.id = 523920
//        newObject.name = "Added"
//        objects.insert(newObject, at: 0)
//        let indexPath = IndexPath(row: 0, section: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
        performSegue(withIdentifier: "showAddItemView", sender: self)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! LocationForecast
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemUITableCell

        let object = objects[indexPath.row] as! LocationForecast
        tableView.rowHeight = 125
        cell.name = object.name
        cell.locationOutlet.text! = object.name
        cell.temperature = object.forecasts[0].temp
        cell.tempOutlet.text! = String(format: "%.0f", object.forecasts[0].temp) + " ℃"
        cell.conditionsImage = object.forecasts[0].image
        cell.imageOutlet.image = object.forecasts[0].image
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func preload3Locations() {
        let location1 = LocationForecast()
        location1.name = "Warsaw"
        location1.id = 523920
        loadLocationData(locationForecast: location1)
        let location2 = LocationForecast()
        location2.name = "London"
        location2.id = 44418
        loadLocationData(locationForecast: location2)
        let location3 = LocationForecast()
        location3.name = "Berlin"
        location3.id = 638242
        loadLocationData(locationForecast: location3)
        self.objects.insert(location1, at: 0)
        let indexPath1 = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath1], with: .automatic)
        self.objects.insert(location2, at: 1)
        let indexPath2 = IndexPath(row: 1, section: 0)
        self.tableView.insertRows(at: [indexPath2], with: .automatic)
        self.objects.insert(location3, at: 1)
        let indexPath3 = IndexPath(row: 2, section: 0)
        self.tableView.insertRows(at: [indexPath3], with: .automatic)
        
    }
    
    func loadLocationData(locationForecast : LocationForecast){
        group.enter()
        let urlString = "https://www.metaweather.com/api/location/\(String(locationForecast.id))/"
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
                for i in 0...self.maxDayIndex{
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
                    locationForecast.forecasts.append(dayForecast)
                }
                self.group.leave()
            }
            catch{
                self.group.leave()
                return
            }
        }
        task.resume()
    }

}

