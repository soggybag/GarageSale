//
//  UserProfile.swift
//  GarageSale
//
//  Created by mitchell hudson on 1/23/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//


/** 
    A singleton to handle user profile info. 
    There is only one user, there should only be one UserProfile.
*/

import UIKit
import Parse


// TODO: This class should create and save a user profile
// TODO: Add something to add a profile for User objects that lack one. 
// ? Maybe just delete old users without a profile.

class UserProfile {
    // Make this a singleton
    static let sharedInstance = UserProfile()
    
    private init() {}
    
    // Some Vars to store user data. 
    
    var username: String?
    var profileImage: PFFile?
    var userProfile: PFObject?
    
    
    // MARK: Load profile
    
    func loadProfile() {
        print("Loading profile")
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
                            print("Profile image found...")
                            self.profileImage = profileImage
                        }
                    } else {
                        print("* NO profile found")
                        self.createProfile()
                    }
                } else {
                    print("Error: \(error?.userInfo)")
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
    
    
    // Save Profile Image 
    
    func setImageData(data: NSData) {
        print("Upload profile image")
        if let userProfile = userProfile {
            let newProfileImage = PFFile(data: data)
            
            EZLoadingActivity.show("Saving Profile Image", disableUI: true)
            
            newProfileImage?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                print("Profile image uploaded")
                EZLoadingActivity.hide()
                // Update User profile
                userProfile[Constants.profile.profileImage] = newProfileImage
                print("Saving User Profile")
                userProfile.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                    // TODO: Check for errors here.
                    print("User profile updated")
                    if let error = error {
                        print("Error: \(error.userInfo)")
                    }
                })

            })
            
        }
    }
}







