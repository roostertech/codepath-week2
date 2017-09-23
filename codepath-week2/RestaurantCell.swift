//
//  RestaurantCell.swift
//  codepath-week2
//
//  Created by Phuong Nguyen on 9/20/17.
//  Copyright © 2017 Roostertech. All rights reserved.
//

import UIKit
import AFNetworking

class RestaurantCell: UITableViewCell {

    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var restaurantDistance: UILabel!
    @IBOutlet weak var reviewCount: UILabel!
    @IBOutlet weak var restaurantAddress: UILabel!
    @IBOutlet weak var restaurantCategory: UILabel!
    @IBOutlet weak var starRating: UIImageView!
    @IBOutlet weak var restaurantImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepare (with business: Business) {
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
        
        if let profilePic = business.imageURL {
            restaurantImage.setImageWith(profilePic)
            restaurantImage.layer.cornerRadius = 5
            restaurantImage.layer.masksToBounds = true;
        }
        
        if let reviews = business.reviewCount {
            reviewCount.text = String(describing: reviews) + " Reviews"
        }
    }

}
