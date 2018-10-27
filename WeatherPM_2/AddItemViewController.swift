//
//  AddItemViewController.swift
//  WeatherPM_2
//
//  Created by macuser on 27/10/2018.
//  Copyright © 2018 pawmat. All rights reserved.
//

import UIKit
import Alamofire

class AddItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableOutlet: UITableView!
    @IBOutlet weak var searchFieldOutlet: UITextField!
    @IBOutlet weak var findButtonOutlet: UIButton!
    @IBOutlet weak var navigationOutlet: UINavigationItem!
    
    var objects = [LocationForecast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableOutlet.rowHeight = 50
        self.navigationController?.navigationBar.backItem?.title = "Cancel"
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print(objects[indexPath.row].name! + "  " + String(indexPath.row))
        performSegue(withIdentifier: "backFromAddView", sender: self)
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
}
