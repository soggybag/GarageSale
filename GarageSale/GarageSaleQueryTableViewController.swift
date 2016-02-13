//
//  GarageSaleQueryTableViewController.swift
//  GarageSale
//
//  Created by mitchell hudson on 1/20/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

import UIKit

import Parse
import ParseUI

class SimpleTableViewController: PFQueryTableViewController, ProfileViewControllerDelegate, LoginSignUpViewControllerDelegate {
    
    
    let dateFormatter = NSDateFormatter()
    
    var profileButton: UIBarButtonItem!
    var loginButton: UIBarButtonItem!
    var addButton: UIBarButtonItem!
    
    // MARK: Set up bar buttons
    func setupBarButtons() {
        addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addBarButtonTapped:")
        profileButton = UIBarButtonItem(title: "Profile", style: .Plain, target: self, action: "profileButtonTapped:")
        loginButton = UIBarButtonItem(title: "Login", style: .Plain, target: self, action: "loginBarButtonTapped:")
    }
    
    
    func loginBarButtonTapped(sender: UIBarButtonItem) {
        showLoginViewController()
    }
    
    func addBarButtonTapped(sender: UIBarButtonItem) {
        showAddGarageSaleViewController()
    }
    
    // Show Add new garage sale VC
    func showAddGarageSaleViewController() {
        // TODO: show Add GarageSale ViewController
        if let loginVC = storyboard?.instantiateViewControllerWithIdentifier(Constants.views.AddGarageSaleViewController) {
            presentViewController(loginVC, animated: true, completion: { () -> Void in
                //
            })
        }
    }
    
    func profileButtonTapped(sender: UIBarButtonItem) {
        if let profileVC = storyboard?.instantiateViewControllerWithIdentifier(Constants.views.ProfileViewController) as? ProfileViewController {
            profileVC.delegate = self
            presentViewController(profileVC, animated: true, completion: { () -> Void in
                //
            })
        }
    }
    
    // Show Login VC
    func showLoginViewController() {
        if let loginVC = storyboard?.instantiateViewControllerWithIdentifier(Constants.views.LoginViewController) as? LoginViewController {
            loginVC.delegate = self
            presentViewController(loginVC, animated: true, completion: { () -> Void in
                //
            })
        }
    }
    
    // Show Signup VC
    func showSignupViewController() {
        if let signupVC = storyboard?.instantiateViewControllerWithIdentifier(Constants.views.SignupViewController) as? SignupViewController {
            signupVC.delegate = self
            presentViewController(signupVC, animated: true, completion: { () -> Void in
                //
            })
        }
    }
    
    func configureBarButtons() {
        if let _ = PFUser.currentUser() {
            // Logged in show profile and + buttons
            navigationItem.rightBarButtonItems = [addButton, profileButton]
        } else {
            // Not logged in show log in button
            navigationItem.rightBarButtonItems = [loginButton]
        }
    }
    
    
    // ProfileViewControllerDelegate
    
    func done(sender: UIViewController) {
        sender.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logout(sender: UIViewController) {
        PFUser.logOut()
        setupBarButtons()
        sender.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // LoginSignUpViewControllerDelegate
    
    func didLogInSignUp(sender: UIViewController) {
        setupBarButtons()
        sender.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loginWantsToSignUp(sender: UIViewController) {
        sender.dismissViewControllerAnimated(true) { () -> Void in
            self.showSignupViewController()
        }
    }
    
    func signUpWantsToLogin(sender: UIViewController) {
        sender.dismissViewControllerAnimated(true) { () -> Void in
            self.showLoginViewController()
        }
    }
    
    
    // MARK: - View LifeCycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        configureBarButtons()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the date style
        dateFormatter.dateStyle = .FullStyle
        
        setupBarButtons()
    }
    
    
    // MARK: Init
    
    convenience init(className: String?) {
        self.init(style: .Plain, className: className)
        
        title = "Garage Sales"
        pullToRefreshEnabled = true
        paginationEnabled = false
    }
    
    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        parseClassName = "GarageSale"
        textKey = "title" // ??
    }
    
    
    
    
    // MARK:
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toDetailSegue" {
            let detailVC = segue.destinationViewController as! GarageSaleDetailViewController
            let indexPath = tableView.indexPathForSelectedRow
            let garageSale = objectAtIndexPath(indexPath)
            
            detailVC.garageSale = garageSale
        }
    }
    
    
    // MARK: Data
    
    override func queryForTable() -> PFQuery {
        
        return super.queryForTable().orderByAscending("startDate")
    }
    
    
    
    // MARK: TableView
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cellIdentifier = "cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? PFTableViewCell
        
        if cell == nil {
            cell = PFTableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if let title = object?["title"] as? String {
            cell?.textLabel?.text = title
        }
        
        if let startDate = object?["startDate"] as! NSDate? {
            cell?.detailTextLabel?.text = dateFormatter.stringFromDate(startDate)
            print(cell?.detailTextLabel?.text)
        }
        
        return cell
    }
    
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("toDetailSegue", sender: self)
    }
    
    
}