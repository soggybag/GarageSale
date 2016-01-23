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


class ProfileViewController: UIViewController {

    var delegate: ProfileViewControllerDelegate?
    
    // MARK: IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: PFImageView!
    
    
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
    
    
    func displayUserInfo() {
        if let user = PFUser.currentUser() {
            nameLabel.text = user[Constants.user.username] as? String
            profileImage.file = user[Constants.user.profileImage] as? PFFile
            // TODO: Show Spinner
            profileImage.loadInBackground({ (image: UIImage?, error: NSError?) -> Void in
                // TODO: Hide Spinner
            })
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    // MARK: View Lifecycle 

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        displayUserInfo()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
