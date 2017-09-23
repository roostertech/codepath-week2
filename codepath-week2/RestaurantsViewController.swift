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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        Business.searchWithTerm(term: "Thai", completion: { (resultBusinesses: [Business]?, error: Error?) -> Void in
            
            if resultBusinesses != nil {
                self.businesses = resultBusinesses!
            }
            //            if let businesses = businesses {
//                for business in businesses {
//                    print(business.name!)
//                    print(business.address!)
//                }
//            }
            
            self.restaurantsView.reloadData()
            
        }
        )
        
        
        restaurantsView.estimatedRowHeight = 140
        restaurantsView.rowHeight = UITableViewAutomaticDimension
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
 

}

extension RestaurantsViewController : FilterViewControllerDelegate {
    func filterViewController(filterViewController: FilterViewController, didUpDateFilters filters: [String : AnyObject]) {
        
        let categories = filters["categories"] as! [String]
        print(categories)
        
        Business.searchWithTerm(term: "Restaurants", sort: nil, categories: categories, deals: nil, completion: { (resultBusinesses: [Business]?, error: Error?) -> Void in
            
            if resultBusinesses != nil {
                self.businesses = resultBusinesses!
                self.restaurantsView.reloadData()
            }
        })
    }
}

extension RestaurantsViewController: UITableViewDataSource, UITableViewDelegate {
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
