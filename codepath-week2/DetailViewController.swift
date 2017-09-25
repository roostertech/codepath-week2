//
//  DetailViewController.swift
//  codepath-week2
//
//  Created by Phuong Nguyen on 9/24/17.
//  Copyright © 2017 Roostertech. All rights reserved.
//

import UIKit
import MapKit
import AFNetworking
class DetailViewController: UIViewController {
    
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var restaurantDistance: UILabel!
    @IBOutlet weak var restaurantAddress: UILabel!
    
    @IBOutlet weak var starRating: UIImageView!
    
    @IBOutlet weak var reviewCount: UILabel!
    @IBOutlet weak var retaurantCategories: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var restaurantImage: UIImageView!
    
    var business: Business!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let name = business.name {
            restaurantName.text = name
        }
        
        if let distance = business.distance {
            restaurantDistance.text = distance
        }
        
        
        if let address = business.address {
            restaurantAddress.text = address
        }
        
        if let starUrl = business.ratingImageURL {
            starRating.setImageWith(starUrl)
        }
        
        if let category = business.categories {
            retaurantCategories.text = category
        }
        
        if let profilePic = business.imageURL {
            restaurantImage.setImageWith(profilePic)
        }
        
        if let reviews = business.reviewCount {
            reviewCount.text = String(describing: reviews) + " Reviews"
        }
        
        if business.longitude != nil && business.latitude != nil {
            let rgn = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(business.latitude!, business.longitude!), 2000, 2000);
            mapView.setRegion(rgn, animated: false)
            
            addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2DMake(business.latitude!, business.longitude!))
        } else {
            mapView.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "An annotation!"
        mapView.addAnnotation(annotation)
    }
    
    func prepare(business: Business) {
        self.business = business
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
