//
//  ViewController.swift
//  CryptoTicker
//
//  Created by Adrian Smith on 1/7/18.
//  Copyright © 2018 Adrian Smith. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	//Set up IBOutlets
	@IBOutlet weak var mainTableView: UITableView!
    //Declare Global Variables
	
	let searchController = UISearchController(searchResultsController: nil)
	
	var cryptos: [Crypto] = [] {
		didSet {
			mainTableView.reloadData()
		}
	}
	
	var filteredCrypto = [Crypto]()
	
	var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//Setup Search Bar
		let searchController = UISearchController(searchResultsController: nil)
		
		searchController.searchResultsUpdater = self
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search Cryptocurrencies"
		navigationItem.searchController = searchController
		definesPresentationContext = true
		
		mainTableView.refreshControl = self.refreshControl
		self.refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
		self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
		
		
	
		
        
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		
		//Register Custom Cell
		mainTableView.register(UINib(nibName: "TableViewCell", bundle: nil ), forCellReuseIdentifier: "TableViewCell")
		
		loadData()
		
		mainTableView.delegate = self
		mainTableView.dataSource = self
		
	}
	
	
	//////////////////////////////////////////////
	
	//MARK: - Get Data via Alamofire
	@objc func loadData() {
		Alamofire.request("https://api.coinmarketcap.com/v1/ticker/?limit=500").responseJSON(completionHandler: {
			response in
			if let value = response.result.value {
				let json = JSON(value)
				
				for item in json.array! {
					let name = item["name"].stringValue
					let percentChange = item["percent_change_24h"].floatValue
					let rank = item["rank"].stringValue
					let price = item["price_usd"].stringValue
					
					let crypto = Crypto(name: name, price: price, percentChange: percentChange, rank: rank)
					self.cryptos.append(crypto)
				}
				
				DispatchQueue.main.async {
					self.refreshControl.endRefreshing()
					self.mainTableView.reloadData()
				}
			}
		})
	}
	
	//////////////////////////////////////////////
	
	//MARK: - Search Bar Functions
	
	func searchBarIsEmpty() -> Bool {
		//Returns true if text is empty or nil
		return searchController.searchBar.text?.isEmpty ?? true
	}
	
	func filteredContentForSearchText(_ searchText: String, scope: String = "All") {
		filteredCrypto = cryptos.filter({( crypto: Crypto) -> Bool in
			let searchName = crypto.name.lowercased().contains(searchText.lowercased())
			return searchName
		})
		
		mainTableView.reloadData()
	}
	
	func isFiltering() -> Bool {
		return searchController.isActive && !searchBarIsEmpty()
	}
	
    
    //////////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods

	//Determine what cell looks like
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Declare cell constant
		guard let cell = mainTableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell else { fatalError()}
		let crypto: Crypto
		
		if isFiltering(){
			crypto = filteredCrypto[indexPath.row]
		} else {
			crypto = cryptos[indexPath.row]
		}
		
		let color = determinePercentLabelColor(value: crypto.percentChange)
		
		let priceString = "\(String(format: "$%.04f", Double(crypto.price)!))"
		let percentChangeString = "\(crypto.percentChange)%"
		
        //Set properties of cell
		cell.currencyNameLabel.text = crypto.name
		cell.rankLabel.text = crypto.rank
		cell.priceLabel.text = priceString
		cell.percentChangeLabel.text = percentChangeString
		cell.percentChangeLabel.textColor = color		
        
        return cell
        
    }
    // Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if isFiltering() {
			return filteredCrypto.count
			
			
		}
        return cryptos.count
	}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print("Selected Row: \(indexPath.row)")
        self.performSegue(withIdentifier: "cryptoDetails", sender: self)
		
    }
	
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		searchController.searchBar.endEditing(true)
	}
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchController.searchBar.endEditing(true)
	}
	
	func determinePercentLabelColor(value: Float) -> UIColor{
		var color : UIColor = UIColor.gray
		
		if value > 0 {
			color = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
			
		} else if value < 0 {
			color = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
			
		}
		
		return color
	}

	@objc func refresh(sender: Any) {
		self.cryptos.removeAll()
		self.loadData()
	}

}

extension ViewController: UISearchResultsUpdating {
	//MARK: - UISearchResultsUpdating delegate
	func updateSearchResults(for searchController: UISearchController) {
		
		filteredContentForSearchText(searchController.searchBar.text!)
	}
}





