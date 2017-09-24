//
//  RestaurantsViewController.swift
//  codepath-week2
//
//  Created by Phuong Nguyen on 9/20/17.
//  Copyright © 2017 Roostertech. All rights reserved.
//

import UIKit

class RestaurantsViewController: UIViewController {

    @IBOutlet weak var restaurantsView: UITableView!
    
    var businesses: [Business] = [Business]()
    let defaultSearch = "Restaurant"
    var searchBar : UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        

        searchBar = UISearchBar()
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar

        
        restaurantsView.estimatedRowHeight = 140
        restaurantsView.rowHeight = UITableViewAutomaticDimension
        
        search(filters: [String : AnyObject]())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let navController = segue.destination as! UINavigationController
        let filterViewController = navController.topViewController as! FilterViewController
        filterViewController.delegate = self
    }
    
    
    func search(filters: [String : AnyObject]) -> Void {
        Business.searchWithTerm(term : searchBar.text ?? defaultSearch, sort: filters["sortMode"] as? YelpSortMode,
                                categories: filters["categories"] as? [String],
                                deals: filters["deal"] as? Bool,
                                distanceInMeters: filters["distance"] as? Int,
                                completion: { (resultBusinesses: [Business]?, error: Error?) -> Void in
                                    
                                    if resultBusinesses != nil {
                                        print("Search returned \(resultBusinesses!.count)")
                                        self.businesses = resultBusinesses!
                                        self.restaurantsView.reloadData()
                                    }
        })
    }
    
}

// MARK:- SearchBar
extension RestaurantsViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search \(String(describing: searchBar.text))")
        search(filters: [String : AnyObject]())
    }
}

// MARK:- FilterView
extension RestaurantsViewController : FilterViewControllerDelegate {
    func filterViewController(filterViewController: FilterViewController, didUpDateFilters filters: [String : AnyObject]) {
        search(filters: filters)
    }
}

// MARK:- TableView
extension RestaurantsViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath) as! RestaurantCell
        
        let business : Business = businesses[indexPath.row]
        cell.prepare(with: business)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businesses.count
    }
}


