//
//  RestaurantsViewController.swift
//  codepath-week2
//
//  Created by Phuong Nguyen on 9/20/17.
//  Copyright © 2017 Roostertech. All rights reserved.
//

import UIKit
import MBProgressHUD
import MapKit
import CoreLocation
import AFNetworking

class RestaurantsViewController: UIViewController {

    @IBOutlet weak var restaurantsView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapButton: UIBarButtonItem!

    var businesses: [Business] = [Business]()
    var businessesIndex: [String: Business] = [String: Business]()
    let defaultSearch = "Restaurant"
    var searchBar : UISearchBar!
    var isMoreDataLoading = false
    var filters: [String : AnyObject] =  [String : AnyObject]()
    var displayMap = false
    
    
    @IBAction func switchMapList(_ sender: Any) {
        displayMap = !displayMap
        setupMapOrList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        

        searchBar = UISearchBar()
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar

        
        restaurantsView.estimatedRowHeight = 140
        restaurantsView.rowHeight = UITableViewAutomaticDimension

        centerMap()
        setupMapOrList()
        
        search(filters: [String : AnyObject]())
    }
    
    func setupMapOrList() {
        if self.displayMap {
            mapView.isHidden = false
            restaurantsView.isHidden = true
            self.mapButton.image = #imageLiteral(resourceName: "list")
        } else {
            mapView.isHidden = true
            restaurantsView.isHidden = false
            self.mapButton.image = #imageLiteral(resourceName: "map")

        }
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
        if segue.destination is UINavigationController {
            let navController = segue.destination as! UINavigationController
            
            let filterViewController = navController.topViewController as! FilterViewController
            filterViewController.delegate = self
            filterViewController.parepare(filters: filters)
        } else if segue.destination is DetailViewController {
            let detailController = segue.destination as! DetailViewController
            
            if let cell = sender as? UITableViewCell {
                let indexPath = restaurantsView.indexPath(for: cell)
                detailController.prepare(business: businesses[indexPath!.row])
            }


            
        }
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
                                        self.businessesIndex.removeAll()
                                        for business in self.businesses {
                                            self.businessesIndex[business.name!] = business
                                        }
                                        self.restaurantsView.reloadData()
                                        self.reloadMap()
                                    }
        })
    }
}

// MARK:- SearchBar
extension RestaurantsViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search \(String(describing: searchBar.text))")
        search(filters: filters)
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

// MARK:- MapView
extension RestaurantsViewController : MKMapViewDelegate {
    
    // add an annotation with an address: String
    func addAnnotationAtAddress(address: String, title: String) {
        let semaphore = DispatchSemaphore(value: 1)
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count != 0 {
                    let coordinate = placemarks.first!.location!
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate.coordinate
                    annotation.title = title
                    self.mapView.addAnnotation(annotation)
                }
            } else {
                print("Could not decode \(address)")
            }
            
            semaphore.signal()
        }
        semaphore.wait()
    }
    
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D, title: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }

    
    func reloadMap() {
        mapView.removeAnnotations(mapView.annotations)
        for business: Business in businesses {
            if business.longitude == nil || business.latitude == nil {
                print("No coor for \(business.name!)")
                continue
            }
            addAnnotationAtCoordinate(coordinate:
                CLLocationCoordinate2D(latitude: business.latitude!, longitude: business.longitude!), title: business.name!)
        }

        mapView.showAnnotations(mapView.annotations, animated: true)
    }
 
    func centerMap() {
        let rgn = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(37.7833, -122.4067), 2000, 2000);
        mapView.setRegion(rgn, animated: false)
        mapView.isZoomEnabled = true
        mapView.showsCompass = true
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "MyCustomAnnotation"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
//        let business = self.businessesIndex[annotation.title!!]
        // TODO better image view
        annotationView?.image = #imageLiteral(resourceName: "map")
        
        
        return annotationView
    }
}
