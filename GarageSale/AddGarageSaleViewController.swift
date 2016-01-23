//
//  AddGarageSaleViewController.swift
//  GarageSale
//
//  Created by mitchell hudson on 1/20/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//


// 

import UIKit
import CoreLocation
import Parse
import ImageIO


class AddGarageSaleViewController:
    UIViewController,
    UITextFieldDelegate,
    UITextViewDelegate,
    CLLocationManagerDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    
    
    var date: NSDate?
    var endDate: NSDate?
    var geolocation: CLLocation?
    var currentDateText: UITextField?
    var locationManager: CLLocationManager!
    
    
    // MARK: IBOutlets
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var dateText: UITextField!
    @IBOutlet weak var addressText: UITextField!
    @IBOutlet weak var notesText: UITextView!
    @IBOutlet weak var endDateText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    
    // MARK: IBActions
    
    @IBAction func getCurrentLocationButtonTapped(sender: UIButton) {
        getLocation()
    }
    
    @IBAction func postButtonTapped(sender: UIButton) {
        // TODO: Handle Post Garage Sale
        print("Posting Garage Sale...")
        postNewGarageSale()
    }
    
    @IBAction func dateTextDidBeginEditing(sender: UITextField) {
        currentDateText = sender
    }
    
    @IBAction func addImageButtonTpped(sender: UIButton) {
        let photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        presentViewController(photoPicker, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    
    // MARK: Image Picker Delegate 
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        // 
        print("Did finish picking image")
        picker.dismissViewControllerAnimated(true, completion: nil)
        imageView.image = image
    }
    
    
    
    
    
    
    // Post New GarageSale 
    
    func postNewGarageSale() {
        // TODO: Validate form
        // TODO: Send new GarageSale to Parse. 
        let garageSale = PFObject(className: "GarageSale")
        // TODO: Check current user
        if let user = PFUser.currentUser() {
            garageSale["user"] = user
            if let address = addressText.text {
                garageSale["address"] = address
            }
            if let location = geolocation {
                garageSale["geoLoc"] = PFGeoPoint(location: location)
            }
            if let startDate = date {
                garageSale["startDate"] = startDate
            }
            if let endDate = endDate {
                garageSale["endDate"] = endDate
            }
            if let title = titleText.text {
                garageSale["title"] = title
            }
            
            if let image = getResizedJPEG() {
                let garageSaleImage = PFFile(data: image)
                garageSale["image"] = garageSaleImage
            }
            
            showProgress() // Show the progress thing
            
            garageSale.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                self.hideProgress() // Hide the progress thing
                if success {
                    print("GarageSale Saved successfully")
                    self.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    print("Error Saving GarageSale: \(error?.localizedDescription)")
                    // TODO: Deal with an error...
                }
            }
        }
    }
    
    func getResizedJPEG() -> NSData? {
        if let image = imageView.image {
            let size = CGSize(width: 640, height: 640)
            let hasAlpha = false
            let scale: CGFloat = 0.0
            
            UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
            image.drawInRect(CGRect(origin: CGPointZero, size: size))
            
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return UIImageJPEGRepresentation(scaledImage, 0.8)
        }
        return nil
    }
    
    
    func showProgress() {
        EZLoadingActivity.show("Saving Garage Sale", disableUI: true)
    }
    
    func hideProgress() {
        EZLoadingActivity.hide()
    }
    
    
    
    
    // MARK: Location 
    
    func getLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        geolocation = locations[0]
        
        CLGeocoder().reverseGeocodeLocation(manager.location!) { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            if error != nil {
                print("Reverse geocoder error: \(error?.localizedDescription)")
                return
            }
            
            if placemarks?.count > 0 {
                let pm = placemarks![0]
                self.displayLocation(pm)
            } else {
                print("Problem reverse geocoder found no placemarks?")
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Manager failed: \(error) \(error.localizedDescription)")
    }
    
    func displayLocation(placemark: CLPlacemark) {
        locationManager.stopUpdatingLocation()
        let locality = placemark.locality
        let postalcode = placemark.postalCode
        let administrativeArea = placemark.administrativeArea
        let country = placemark.country
        print("\(locality) \(postalcode) \(administrativeArea) \(country)")
    }
    
    
    
    
    
    // MARK: - Text Field 
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    
    
    func makeDatePickerWithDoneButton() {
        let inputView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 240))
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 40, width: 0, height: 0))
        datePicker.datePickerMode = .DateAndTime
        inputView.addSubview(datePicker)
        datePicker.addTarget(self, action: "datePickerPickedDate:", forControlEvents: .ValueChanged)
        let doneButton = UIButton(frame: CGRect(x: (view.frame.width/2)-(100/2), y: 0, width: 100, height: 40))
        doneButton.setTitle("Done", forState: .Normal)
        doneButton.addTarget(self, action: "inputViewDone:", forControlEvents: .TouchUpInside)
        
        datePickerPickedDate(datePicker)
        dateText.inputView = inputView
        endDateText.inputView = inputView
    }
    
    
    func datePickerPickedDate(sender: UIDatePicker) {
        // TODO: Handle Date
        let formatter = NSDateFormatter()
        formatter.dateStyle = .FullStyle
        date = sender.date
        if currentDateText != nil {
            currentDateText!.text = formatter.stringFromDate(date!)
        }
    }
    
    func inputViewDone(sender: UIButton) {
        // TODO: Handle Done Button
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        view.endEditing(true)
    }
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateText.delegate = self
        titleText.delegate = self
        addressText.delegate = self
        notesText.delegate = self
        endDateText.delegate = self
        
        makeDatePickerWithDoneButton()
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



extension AddGarageSaleViewController {
    
}



