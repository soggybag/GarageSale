//
//  Constants.swift
//  GarageSale
//
//  Created by mitchell hudson on 1/22/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

import UIKit

struct Constants {
    struct Segues {
        static let mapToDetailsSegue = "mapToDetailsSegue"
    }
    
    struct ClassNames {
        static let GarageSale = "GarageSale"
        static let Profile = "Profile"
    }
    
    
    struct garageSale {
        static let title = "title"
        static let geoLoc = "geoLoc"
        static let startDate = "startDate"
        static let endDate = "endDate"
        static let user = "user"
        static let address = "address"
        static let image = "image"
    }
    
    struct user {
        static let profileImage = "profileImage"
        static let username = "username"
    }
    
    struct profile {
        static let username = "username"
        static let profileImage = "profileImage"
        static let user = "user"
    }
    
    struct map {
        static let initialSpan = 0.03
    }
    
    struct views {
        static let ProfileViewController = "ProfileViewController"
        static let LoginViewController = "LoginViewController"
        static let AddGarageSaleViewController = "AddGarageSaleViewController"
        static let SignupViewController = "SignupViewController"
    }
    
    struct date {
        static let startEndDateTimeFormat = "EEEE, MMMM d h:mm a"
    }
    
}
