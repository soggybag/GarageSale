//
//  ViewController.swift
//  GarageSale
//
//  Created by mitchell hudson on 1/20/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse

class ViewController: UIViewController, CLLocationManagerDelegate, ProfileViewControllerDelegate {

    
    var locationManager: CLLocationManager!
    var profileButton: UIBarButtonItem!
    var loginButton: UIBarButtonItem!
    var addButton: UIBarButtonItem!
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    
    func fetchGarageSalesInLocation(location: CLLocation) {
        let query = PFQuery(className: Constants.ClassNames.GarageSale)
        let geoPoint = PFGeoPoint(location: location)
        query.whereKey(Constants.garageSale.geoLoc, nearGeoPoint: geoPoint, withinMiles: 10)
        
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            print("Found GarageSales")
            if let garageSales = results {
                for garageSale in garageSales {
                    // TODO: Place Markers for each GarageSale found in results
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
    
    // Make annotationView
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        let identifier = "GarageSaleAnnotaion"
        if annotation.isKindOfClass(GarageSaleMarker.self) {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                
                let btn = UIButton(type: .DetailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
            } else {
                annotationView!.annotation = annotation
            }
            
            return annotationView
        }
        
        return nil
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
        if let loginVC = storyboard?.instantiateViewControllerWithIdentifier(Constants.views.LoginViewController) {
            presentViewController(loginVC, animated: true, completion: { () -> Void in
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
        // TODO: Show profile view
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
        
        print("Map View will appear")
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

