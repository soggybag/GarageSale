//
//  ViewController.swift
//  GarageSale
//
//  Created by mitchell hudson on 1/20/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//


// TODO: Custom Marker


import UIKit
import MapKit
import CoreLocation
import Parse

class ViewController: UIViewController, CLLocationManagerDelegate, ProfileViewControllerDelegate, LoginSignUpViewControllerDelegate {
    
    let milesRadius: Double = 50
    
    var garageSaleMarkers = [PFObject]()
    var garageSaleMarkerIDs = [String]()
    
    var locationManager: CLLocationManager!
    var profileButton: UIBarButtonItem!
    var loginButton: UIBarButtonItem!
    var addButton: UIBarButtonItem!
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    func fetchGarageSalesInLocation(location: CLLocation) {
        let query = PFQuery(className: Constants.ClassNames.GarageSale)
        let geoPoint = PFGeoPoint(location: location)
        query.whereKey(Constants.garageSale.geoLoc, nearGeoPoint: geoPoint, withinMiles: milesRadius)
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if let garageSales = results {
                // Get annotations
                
                for garageSale in garageSales {
                    // TODO: PREVENT DUPLICATE MARKERS!
                    // get annotations 
                    // contains
                    
                    if !self.garageSaleMarkers.contains(garageSale) {
                        self.garageSaleMarkers.append(garageSale)
                        if let title = garageSale[Constants.garageSale.title] as? String {
                            if let geoLoc = garageSale[Constants.garageSale.geoLoc] as? PFGeoPoint {
                                let location = CLLocationCoordinate2D(latitude: geoLoc.latitude, longitude: geoLoc.longitude)
                                let marker = GarageSaleMarker(title: title, coordinate: location, info: "Info string", garageSale: garageSale)
                                self.mapView.addAnnotation(marker)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    // Make annotationView
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        let reuseId = "garagesalemarker"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            // Create a custom marker image
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.image = UIImage(named: "Map-Marker")
            anView!.canShowCallout = true
            // Add a button to the callout
            let btn = UIButton(type: .DetailDisclosure)
            anView?.rightCalloutAccessoryView = btn
        } else {
            anView?.annotation = annotation
        }
        
        return anView
    }
    
    func mapView(mapView: MKMapView!,
        annotationView view: MKAnnotationView!,
        calloutAccessoryControlTapped control: UIControl!) {
        
            let garageSaleMarker = view.annotation as! GarageSaleMarker
            let garageSale = garageSaleMarker.garageSale
            
            // Segue to Details view
            performSegueWithIdentifier(Constants.Segues.mapToDetailsSegue, sender: garageSale)
    }
    
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.Segues.mapToDetailsSegue {
            let detailsVC = segue.destinationViewController as! GarageSaleDetailViewController
            detailsVC.garageSale = sender as? PFObject
        }
    }
    
    
    // MARK: - Show Login View Controller 
    
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
    
    
    // Show Add new garage sale VC
    func showAddGarageSaleViewController() {
        // TODO: show Add GarageSale ViewController
        if let loginVC = storyboard?.instantiateViewControllerWithIdentifier(Constants.views.AddGarageSaleViewController) {
            presentViewController(loginVC, animated: true, completion: { () -> Void in
                //
            })
        }
    }
    
    
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
    
    func profileButtonTapped(sender: UIBarButtonItem) {
        if let profileVC = storyboard?.instantiateViewControllerWithIdentifier(Constants.views.ProfileViewController) as? ProfileViewController {
            profileVC.delegate = self
            presentViewController(profileVC, animated: true, completion: { () -> Void in
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
    
    
    // MARK: - Location
    // Show Garage Sales
    
    func showGarageSales() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location Found!")
        if let location = locations.last {
            let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: Constants.map.initialSpan, longitudeDelta: Constants.map.initialSpan))
            self.mapView.setRegion(region, animated: true)
            locationManager.stopUpdatingLocation()
            fetchGarageSalesInLocation(location)
        }
    }
    
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureBarButtons()
        showGarageSales()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBarButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

