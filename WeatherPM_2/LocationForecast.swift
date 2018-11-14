//
//  LocationForecast.swift
//  WeatherPM_2
//
//  Created by macuser on 26/10/2018.
//  Copyright © 2018 pawmat. All rights reserved.
//

import Foundation

class LocationForecast{
    var name : String!
    var id : Int!
    var lat : Double!
    var lon : Double!
    var forecasts = [DayConditions]()
}
