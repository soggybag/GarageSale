//
//  ViewController.swift
//  GarageSale
//
//  Created by mitchell hudson on 1/20/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//


// TODO: Custom Marker
// TODO: Add search radius to profile view as a param from UserProfile


// Import Libraries
import UIKit
import MapKit
import CoreLocation
import Parse

class ViewController: UIViewController,
    CLLocationManagerDelegate,
    ProfileViewControllerDelegate,
    LoginSignUpViewControllerDelegate {
    
    let milesRadius: Double = 50    // Set the default search radius to search
    var garageSaleMarkers = [PFObject]()    // store an array of Objects from Parse. Maybe this should be a set?
    var garageSaleMarkerIDs = [String]()    // hold marker ids for map view
    var locationManager: CLLocationManager!
    
    // Some user interface elements
    var profileButton: UIBarButtonItem!
    var loginButton: UIBarButtonItem!
    var addButton: UIBarButtonItem!
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    // Fetch Garage Sales in area 
    
    func fetchGarageSalesInLocation(location: CLLocation) {
        // Create a Query for Garage Sales. NOTE the class name comes from Constants!
        let query = PFQuery(className: Constants.ClassNames.GarageSale)
        let geoPoint = PFGeoPoint(location: location)
        // Need a PFGeoPoint as the center for the search.
        // Search for Garage Sales within a radius
        // query.whereKey(Constants.garageSale.geoLoc, nearGeoPoint: geoPoint, withinMiles: milesRadius)
        
        // Run the query and find some PFObjects
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if let garageSales = results {
                // Get annotations
                
                for garageSale in garageSales {
                    // Prevent duplicates. Would a Set work better here?
                    if !self.garageSaleMarkers.contains(garageSale) {
                        // Add a marker and give it some info.
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
    
    
    // MARK: Map View Delegate
    
    // Make annotationView
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        // Skip this to prevent using a custom marker at the user position.
        if (annotation is MKUserLocation) {
            return nil
        }
        
        // Set a reuse id for markers.
        let reuseId = "garagesalemarker"
        
        // Get an available Marker
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        // If there are no markers make a new one
        if anView == nil {
            // Create a custom marker image
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.image = UIImage(named: "Map-Marker")
            anView!.canShowCallout = true
            // Add a button to the callout
            let btn = UIButton(type: .DetailDisclosure)
            anView?.rightCalloutAccessoryView = btn
        } else {
            // Otherwise set the annotation on a recycled marker.
            anView?.annotation = annotation
        }
        
        return anView
    }
    
    // Handle a tapp on the (!) in the marker callout
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,calloutAccessoryControlTapped control: UIControl!) {
        
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
        addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ViewController.addBarButtonTapped(_:)))
        profileButton = UIBarButtonItem(title: "Profile", style: .Plain, target: self, action: #selector(ViewController.profileButtonTapped(_:)))
        loginButton = UIBarButtonItem(title: "Login", style: .Plain, target: self, action: #selector(ViewController.loginBarButtonTapped(_:)))
    }
    
    // Handle login button
    func loginBarButtonTapped(sender: UIBarButtonItem) {
        showLoginViewController()
    }
    
    // Handle + button
    func addBarButtonTapped(sender: UIBarButtonItem) {
        showAddGarageSaleViewController()
    }
    
    // Handle Profile button
    func profileButtonTapped(sender: UIBarButtonItem) {
        if let profileVC = storyboard?.instantiateViewControllerWithIdentifier(Constants.views.ProfileViewController) as? ProfileViewController {
            profileVC.delegate = self
            presentViewController(profileVC, animated: true, completion: { () -> Void in
                //
            })
        }
    }
    
    // Set up the bar buttons. Display the Login button when not logged in. 
    // The Profile and + buttons are displayed instead when logged in.
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
    
    
    // MARK: - Get the current location
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
    

    // MARK: Location Manager delegate 
    
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

