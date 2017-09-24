//
//  RestaurantsViewController.swift
//  codepath-week2
//
//  Created by Phuong Nguyen on 9/20/17.
//  Copyright © 2017 Roostertech. All rights reserved.
//

import UIKit
import MBProgressHUD

class RestaurantsViewController: UIViewController {

    @IBOutlet weak var restaurantsView: UITableView!
    
    var businesses: [Business] = [Business]()
    let defaultSearch = "Restaurant"
    var searchBar : UISearchBar!
    var isMoreDataLoading = false
    var filters: [String : AnyObject] =  [String : AnyObject]()
    
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
        search(filters: filters, offset: nil)
    }
    func search(filters: [String : AnyObject], offset: Int?) -> Void {
        MBProgressHUD.showAdded(to: self.view, animated: true)

        self.filters = filters
        Business.searchWithTerm(term : searchBar.text ?? defaultSearch, sort: filters["sortMode"] as? YelpSortMode,
                                categories: filters["categories"] as? [String],
                                deals: filters["deal"] as? Bool,
                                distanceInMeters: filters["distance"] as? Int,
                                offset: offset,
                                completion: { (resultBusinesses: [Business]?, error: Error?) -> Void in
                                    
                                    MBProgressHUD.hide(for: self.view, animated: true)
                                    self.isMoreDataLoading = false
                                    if resultBusinesses != nil {
                                        print("Search returned \(resultBusinesses!.count)")
                                        if offset != nil {
                                            self.businesses.append(contentsOf: resultBusinesses!)
                                            print("Total \(self.businesses.count)")
                                        } else {
                                            self.businesses = resultBusinesses!
                                        }
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

// MARK:- ScrollView
extension RestaurantsViewController : UIScrollViewDelegate {

    func loadMoreData() {
  
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = restaurantsView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - restaurantsView.bounds.size.height
            
            print("Height \(scrollViewContentHeight) threshold \(scrollOffsetThreshold) \(restaurantsView.contentSize.height) \(restaurantsView.bounds.size.height)")
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && restaurantsView.isDragging) {
                
                // If we have less than 20 to start out with, no need to load more
                if self.businesses.count < 20 {
                    return
                }
                
                isMoreDataLoading = true
                search(filters: self.filters, offset: self.businesses.count)
            }
        }
    }
}


