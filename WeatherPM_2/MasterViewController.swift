//
//  MasterViewController.swift
//  WeatherPM_2
//
//  Created by macuser on 23/10/2018.
//  Copyright © 2018 pawmat. All rights reserved.
//

import UIKit

class Location{
    var name : String!
    var id : Int!
    var miniForecast = DayConditions()
    var img = UIImageView()
}

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    let group = DispatchGroup()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        let newObject = Location()
        newObject.id = 523920
        newObject.name = "Warsaw"
        self.group.enter()
        getCurrentDayData(locationId: newObject.id, location : newObject)
        self.group.wait()
        print(String(newObject.miniForecast.temp))
        objects.insert(newObject, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! Location
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row] as! Location
        cell.textLabel!.text = object.name //+ String(format: "%.0f", object.miniForecast.temp) + " ℃"
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

    func loadImage(abbr : String, viewToUpdate : UIImageView){
        let url = URL(string : "https://www.metaweather.com/static/img/weather/png/\(abbr).png")!
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            if error != nil {
                return
            }
            if (response as? HTTPURLResponse) != nil {
                if let imageData = data {
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        viewToUpdate.image = image
                    }
                
                } else {
                    return
                }
            }
        }
        task.resume()
        self.group.leave()
    }
    
    func getCurrentDayData(locationId : Int, location : Location) {
        let urlString = "https://www.metaweather.com/api/location/\(String(locationId))/"
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
                let currentDayForecast = array[0]
                let dateString = (currentDayForecast["applicable_date"] as! String)
                let dateArray = dateString.split(separator: "-").map(String.init)
                location.miniForecast.day = Int(dateArray[2])
                location.miniForecast.month = Int(dateArray[1])
                location.miniForecast.year = Int(dateArray[0])
                location.miniForecast.conditionType = (currentDayForecast["weather_state_name"] as! String)
                location.miniForecast.conditionTypeAbbr = (currentDayForecast["weather_state_abbr"] as! String)
                location.miniForecast.temp = (currentDayForecast["the_temp"] as! Double)
                location.miniForecast.windSpeed = (currentDayForecast["wind_speed"] as! Double)
                location.miniForecast.maxTemp = (currentDayForecast["max_temp"] as! Double)
                location.miniForecast.minTemp = (currentDayForecast["min_temp"] as! Double)
                location.miniForecast.windDirection = (currentDayForecast["wind_direction_compass"] as! String)
                location.miniForecast.airPressure = (currentDayForecast["air_pressure"] as! Double)
                self.loadImage(abbr: location.miniForecast.conditionTypeAbbr, viewToUpdate: location.img)
            }
            catch{
                return
            }
        }
        task.resume()
    }
}

