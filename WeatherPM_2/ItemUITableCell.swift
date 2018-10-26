//
//  ItemUITableCell.swift
//  WeatherPM_2
//
//  Created by macuser on 27/10/2018.
//  Copyright © 2018 pawmat. All rights reserved.
//

import UIKit
class ItemUITableCell : UITableViewCell{
    
    var name : String!
    var temperature : Double!
    var conditionsImage : UIImage!
    
    @IBOutlet weak var tempOutlet : UILabel!
    @IBOutlet weak var locationOutlet: UILabel!
    @IBOutlet weak var imageOutlet: UIImageView!
}
