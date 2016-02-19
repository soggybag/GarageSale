//
//  ProfileViewController.swift
//  GarageSale
//
//  Created by mitchell hudson on 1/21/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

import UIKit
import Parse
import ParseUI


// User Profile 
// Displayed as a modal view

// TODO: Check for errors when uploading profile image. Display Activity view.
// TODO: Close profile view after Save.

// TODO: Resize Profile image to 640x640
// TODO: Confirm Email
// TODO: Use Done button as Save when setting profile image
// TODO: Show Spinner while loading profile image


class ProfileViewController: UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    //
    var delegate: ProfileViewControllerDelegate?
    
    // MARK: IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var profileImageSpinner: UIActivityIndicatorView!
    @IBOutlet weak var addProfileImageButton: UIButton!
    
    
    
    // MARK: IBActions
    
    @IBAction func logoutButtonTapped(sender: UIButton) {
        if let delegate = delegate {
            delegate.logout(self)
        }
    }
    
    @IBAction func doneButtonTapped(sender: UIButton) {
        if let delegate = delegate {
            delegate.done(self)
        }
    }
    
    @IBAction func addProfileImageButtonTapped(sender: UIButton) {
        addProfileImage()
    }
    
    @IBAction func saveButtonTapped(sender: UIButton) {
        saveProfileImage()
    }
    
    
    // MARK: Profile Image Update
    
    func saveProfileImage() {
        // TODO: Save changes to profile
        // TODO: Upload profile image
        if let image = profileImageView.image {
            print("Get profile image")
            let size = CGSize(width: 640, height: 640)
            let hasAlpha = false
            let scale: CGFloat = 0
            UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
            image.drawInRect(CGRect(origin: CGPointZero, size: size))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let jpeg = UIImageJPEGRepresentation(scaledImage, 0.8) {
                print("Made Jpeg from profile image")
                UserProfile.sharedInstance.setImageData(jpeg)
            }
        }

    }
    
    func addProfileImage() {
        let photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        presentViewController(photoPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        print("Adding profile image")
        profileImageView.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func displayUserInfo() {
        if let _ = PFUser.currentUser() {
            if let username = UserProfile.sharedInstance.username {
                nameLabel.text = username
            }
            
            if let profileImage = UserProfile.sharedInstance.profileImage {
                // Load the profile image
                profileImageView.file = profileImage
                profileImageSpinner.startAnimating()
                print("Profile image spinner start ")
                profileImageView.loadInBackground({ (image: UIImage?, error: NSError?) -> Void in
                    self.profileImageSpinner.stopAnimating()
                    self.profileImageView.contentMode = .ScaleAspectFill
                })
            } else {
                // No profile image show
                profileImageView.backgroundColor = UIColor.redColor()
                addProfileImageButton.hidden = false
            }
        } else {
            // No user logged in dismiss this view
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    // MARK: View Lifecycle 

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // addProfileImageButton.hidden = true
        print("Profile view will appear")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .ScaleAspectFill
        displayUserInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
