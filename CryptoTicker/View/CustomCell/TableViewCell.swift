//
//  TableViewCell.swift
//  CryptoTicker
//
//  Created by Adrian Smith on 1/7/18.
//  Copyright © 2018 Adrian Smith. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TableViewCell: UITableViewCell {
	//Declare Global Variables
	
	//Setup IBOutlets
    @IBOutlet var rankLabel: UILabel!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var percentChangeLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
}
