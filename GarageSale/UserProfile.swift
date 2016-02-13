//
//  UserProfile.swift
//  GarageSale
//
//  Created by mitchell hudson on 1/23/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

import UIKit
import Parse


// TODO: This class should create and save a user profile
// TODO: Add something to add a profile for User objects that lack one

class UserProfile {
    // Make this a singleton
    static let sharedInstance = UserProfile()
    
    private init() {
        
    }
    
    
    var username: String?
    var profileImage: PFFile?
    var userProfile: PFObject?
    
    
    // Load profile
    func loadProfile() {
        if let user = PFUser.currentUser() {
            // User is logged in
            let query = PFQuery(className: Constants.ClassNames.Profile)
            query.whereKey("user", equalTo: user)
            query.findObjectsInBackgroundWithBlock({ (results: [PFObject]?, error: NSError?) -> Void in
                print("Loaded User profile")
                
                if let results = results {
                    if results.count > 0 {
                        print("* User profile found")
                        let profile = results[0]
                        self.userProfile = profile
                        if let username = profile[Constants.profile.username] as? String {
                            self.username = username
                        }
                        if let profileImage = profile[Constants.profile.profileImage] as? PFFile {
                            self.profileImage = profileImage
                        }
                    } else {
                        print("* NO profile found")
                        self.createProfile()
                    }
                }
            })
        } else {
            // User is not logged in
            username = nil
            profileImage = nil
        }
    }
    
    
    func createProfile() {
        print("Create a new user profile")
        if let user = PFUser.currentUser() {
            let profile = PFObject(className: Constants.ClassNames.Profile)
            profile[Constants.profile.username] = user[Constants.user.username] as! String
            profile[Constants.profile.user] = user
            print("Saving profile")
            profile.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                print("Profile Saved \(success)")
            })
        }
    }
    
    
    func setImageData(data: NSData) {
        if let userProfile = userProfile {
            let newProfileImage = PFFile(data: data)
            // Update User profile
            userProfile[Constants.profile.profileImage] = newProfileImage
            // Update profileImage
            profileImage = newProfileImage
            print("Saving User Profile")
            EZLoadingActivity.show("Saving Profile Image", disableUI: true)
            userProfile.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                print("User profile updated")
                EZLoadingActivity.hide()
            })
        }
    }
}







