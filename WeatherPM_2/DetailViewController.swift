//
//  DetailViewController.swift
//  WeatherPM_2
//
//  Created by macuser on 23/10/2018.
//  Copyright © 2018 pawmat. All rights reserved.
//

import UIKit

class DayConditions{
    var day : Int!
    var month : Int!
    var year : Int!
    var conditionType : String!
    var conditionTypeAbbr : String!
    var temp : Double!
    var maxTemp : Double!
    var minTemp : Double!
    var windSpeed : Double!
    var windDirection : String!
    var rainfall : String!
    var airPressure : Double!
    var image : UIImage!
}


class DetailViewController: UIViewController {
    
    var detailItem: LocationForecast? {
        didSet {
            
        }
    }

    var currentDayIndex = 0;
    let maxDayIndex = 5;
    @IBOutlet weak var dateOutlet: UITextField!
    @IBOutlet weak var conditionsOutlet: UITextField!
    @IBOutlet weak var tempOutlet: UITextField!
    @IBOutlet weak var maxTempOutlet: UITextField!
    @IBOutlet weak var minTempOutlet: UITextField!
    @IBOutlet weak var windDirOutlet: UITextField!
    @IBOutlet weak var windSpeedOutlet: UITextField!
    @IBOutlet weak var airPressureOutlet: UITextField!
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var navbarOutlet: UINavigationItem!
    
    @IBOutlet weak var nextButtonOutlet: UIButton!
    @IBOutlet weak var previousButtonOutlet: UIButton!
    @IBOutlet weak var detailDescriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        navbarOutlet.title = detailItem?.name
        self.previousButtonOutlet.isEnabled = false;
        updateView(dayNo: 0)
    }
    
    func updateView(dayNo : Int) -> Void {
        let forecast = detailItem!.forecasts[dayNo]
        self.dateOutlet.text = "\(String(forecast.year))-\(String(forecast.month))-\(String(forecast.day))"
        self.conditionsOutlet.text = forecast.conditionType
        self.tempOutlet.text = String(format: "%.0f", forecast.temp) + " ℃"
        self.maxTempOutlet.text = String(format: "%.0f", forecast.maxTemp) + " ℃"
        self.minTempOutlet.text = String(format: "%.0f", forecast.minTemp) + " ℃"
        self.windDirOutlet.text = forecast.windDirection
        self.windSpeedOutlet.text = String(format: "%.0f", forecast.windSpeed) + " mph"
        self.airPressureOutlet.text = String(format: "%.0f", forecast.airPressure) + " mbar"
        self.imageOutlet.image = forecast.image
    }

    @IBAction func nextButtonAction() {
        self.previousButtonOutlet.isEnabled = true
        self.currentDayIndex += 1
        self.updateView(dayNo: currentDayIndex)
        if currentDayIndex == self.maxDayIndex {
            self.nextButtonOutlet.isEnabled = false
        }
    }
    
    @IBAction func previousButtonAction() {
        self.nextButtonOutlet.isEnabled = true
        self.currentDayIndex -= 1
        self.updateView(dayNo: currentDayIndex)
        if currentDayIndex == 0 {
            self.previousButtonOutlet.isEnabled = false
        }
    }
}
