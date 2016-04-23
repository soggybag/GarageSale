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
import CoreLocation

class GarageSaleQueryTableViewController: PFQueryTableViewController,
    ProfileViewControllerDelegate,
    LoginSignUpViewControllerDelegate,
    CLLocationManagerDelegate {
    
     
    var shouldUpdateFromServer = true
    let dateFormatter = NSDateFormatter()
    let timeFormatter = NSDateFormatter()
    
    var profileButton: UIBarButtonItem!
    var loginButton: UIBarButtonItem!
    var addButton: UIBarButtonItem!
    
    // MARK: Set up bar buttons
    func setupBarButtons() {
        addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(GarageSaleQueryTableViewController.addBarButtonTapped(_:)))
        profileButton = UIBarButtonItem(title: "Profile", style: .Plain, target: self, action: #selector(GarageSaleQueryTableViewController.profileButtonTapped(_:)))
        loginButton = UIBarButtonItem(title: "Login", style: .Plain, target: self, action: #selector(GarageSaleQueryTableViewController.loginBarButtonTapped(_:)))
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
        dateFormatter.dateStyle = .ShortStyle
        timeFormatter.timeStyle = .ShortStyle
        
        setupBarButtons()
    }
    
    
    
    @IBAction func onTap(imageView: PFImageView) {
        
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
    
    func baseQuery() -> PFQuery {
        let query = PFQuery(className: Constants.ClassNames.GarageSale)
        // let geoPoint = PFGeoPoint(location: location)
        // query.whereKey(Constants.garageSale.geoLoc, nearGeoPoint: geoPoint, withinMiles: 50)
        // query.orderByAscending(key: String)
        return query
    }
    
    func baseQuery(location: CLLocation) -> PFQuery {
        let query = PFQuery(className: Constants.ClassNames.GarageSale)
        let geoPoint = PFGeoPoint(location: location)
        query.whereKey(Constants.garageSale.geoLoc, nearGeoPoint: geoPoint, withinMiles: 50)
        // query.orderByAscending(<#T##key: String##String#>)
        return query
    }
    
    override func queryForTable() -> PFQuery {
        return super.queryForTable().orderByAscending("startDate")
        // return self.baseQuery().fromLocalDatastore()
    }
    
    
    /*
    func refreshLocalDataStoreFromServer() {
        self.baseQuery().findObjectsInBackgroundWithBlock { (parseObjects:[PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("Refresh Found:\(parseObjects?.count)")
                PFObject.unpinAllInBackground(parseObjects, block: { (success: Bool, error: NSError?)-> Void in
                    if error == nil {
                        print("PF Table View query loaded stuff")
                        self.tableView.reloadData()
                        self.shouldUpdateFromServer = false
                        self.loadObjects()
                    } else {
                        print("Failed to pin objects \(error?.userInfo)")
                    }
                })
            } else {
                print("Error refreshing local objects \(error?.userInfo)")
            }
        }
    }
    */
    
    /*
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        
        print("Objects did load")
        if self.shouldUpdateFromServer {
            self.refreshLocalDataStoreFromServer()
        } else {
            self.shouldUpdateFromServer = true
        }
    }
     */
    
    
    
    // MARK: TableView
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cellIdentifier = "cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? PFTableViewCell
        
        if cell == nil {
            cell = PFTableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if let title = object?["title"] as? String {
            cell?.textLabel?.text = title
            // cell?.detailTextLabel?.text = "Hello"
        }
        
        if let startDate = object?["startDate"] as? NSDate {
            let startDateStr = dateFormatter.stringFromDate(startDate)
            let startTimeStr = timeFormatter.stringFromDate(startDate)
            if let endDate = object!["endDate"] as? NSDate {
                let endTimeStr = timeFormatter.stringFromDate(endDate)
                cell?.detailTextLabel?.text = "Date:\(startDateStr) Starts:\(startTimeStr) Ends:\(endTimeStr)"
            }
            
        }
        
        return cell
    }
    
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // performSegueWithIdentifier("toDetailSegue", sender: self)
    }
    
    
}