//
//  AddGarageSaleViewController.swift
//  GarageSale
//
//  Created by mitchell hudson on 1/20/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//


/**
    AddGarageSaleViewController - A view to handle adding new Garage Sales. 
    This view posts a new garage sale to parse.
*/

// TODO: Show progress while fetching geo loc
// TODO: Format date as a range
// TODO: Add category to garage sale
/*
    * Categories:
    * Clothing
    * Toys
    * Furniture
    * Tools
*/

/*

let formatter = NSDateIntervalFormatter()
formatter.dateStyle = .NoStyle
formatter.timeStyle = .ShortStyle

let fromDate = NSDate()
let toDate = fromDate.dateByAddingTimeInterval(10000)

let string = formatter.stringFromDate(fromDate, toDate: toDate)
// 5:49 - 8:36 PM

*/

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
    
    /**
        Form Data 
        
        - date: The date and time the garage sale will occur
        - endDate: The date and time the garage sale will end
        - geolocation: The geolocation of the garage sale
        - currentDateText: Displays the starting date time of the garage sale. 
        - locationManager: An instance of CLLocationManager
    */
    
    private var date: NSDate?
    private var endDate: NSDate?
    private let dateTimeFormatter = NSDateFormatter()
    private let datePicker = UIDatePicker()
    private let datePickerLabel = UILabel()
    
    private var geolocation: CLLocation?
    private var currentDateText: UITextField?
    private var locationManager: CLLocationManager!
    
    private var activeText: UITextField?
    
    
    // MARK: IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var dateText: UITextField!
    @IBOutlet weak var addressText: UITextField!
    @IBOutlet weak var notesText: UITextView!
    @IBOutlet weak var endDateText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    
    
    // MARK: IBActions
    
    @IBAction func getCurrentLocationButtonTapped(sender: UIButton) {
        getLocation()
    }
    
    @IBAction func postButtonTapped(sender: UIButton) {
        print("Posting Garage Sale...")
        postNewGarageSale()
    }
    
    @IBAction func dateTextDidBeginEditing(sender: UITextField) {
        currentDateText = sender
    }
    
    @IBAction func addImageButtonTpped(sender: UIButton) {
        let photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        
        let alert = UIAlertController(title: "Add an image to your posting", message: "Choose an image from your library, or take a photo with the camera.", preferredStyle: .ActionSheet)
        let photoLib = UIAlertAction(title: "Photo Library", style: .Default) { (alert: UIAlertAction) -> Void in
            photoPicker.allowsEditing = true
            photoPicker.sourceType = .PhotoLibrary
            photoPicker.modalPresentationStyle = .FullScreen
            self.presentViewController(photoPicker, animated: true, completion: nil)
        }
        
        let camera = UIAlertAction(title: "Take a Photo", style: .Default) { (alert: UIAlertAction) -> Void in
            photoPicker.allowsEditing = true
            photoPicker.sourceType = .Camera
            photoPicker.modalPresentationStyle = .FullScreen
            self.presentViewController(photoPicker, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction) -> Void in
            //
        }
        
        alert.addAction(photoLib)
        alert.addAction(cancel)
        if UIImagePickerController.isSourceTypeAvailable(.Camera) == true {
            alert.addAction(camera)
        }
        
        presentViewController(alert, animated: true, completion: nil)
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
        addImageButton.setTitle("", forState: .Normal)
    }
    
    
    
    // Post New GarageSale 
    
    func postNewGarageSale() {
        // TODO: Validate form
        // Title? 
        // Address? 
        // Start Date?
        // End Date?
        // Description is not required
        // Image is not required
        
        
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
        if locations.count > 0 {
            geolocation = locations[0]
            locationButton.setTitle("✓", forState: .Normal)
        }
        
        
        CLGeocoder().reverseGeocodeLocation(manager.location!) { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            print("Reverse Geolocation...")
            if error != nil {
                print("Reverse geocoder error: \(error?.localizedDescription)")
                return
            }
            
            if placemarks?.count > 0 {
                print("\(placemarks?.count) placemarks")
                for pm in placemarks! {
                    print(pm)
                }
                
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
    
    
    
    
    
    // MARK: - Text Field Delegate methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == dateText {
            datePickerLabel.text = "Start Date"
        } else {
            datePickerLabel.text = "End Date"
        }
        activeText = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeText = nil
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == dateText {
            datePicker.minimumDate = NSDate()
        } else if textField == endDateText {
            datePicker.minimumDate = date
        }
        
        return true
    }
    
    func keyboardDidShow(notification: NSNotification) {
        if let activeText = self.activeText, keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            var aRect = self.view.frame
            aRect.size.height -= keyboardSize.size.height
            if !CGRectContainsPoint(aRect, activeText.frame.origin) {
                self.scrollView.scrollRectToVisible(activeText.frame, animated: true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    
    
    // MARK: - Handle Date Picker 
    
    func makeDatePickerWithDoneButton() {
        
        // TODO: Add a label showing "start time" or "end time"
        // TODO: Move done button to the right side
        // Label on the left of the of the input view
        
        let inputView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 240))
        datePicker.frame = CGRect(x: 0, y: 40, width: view.frame.width, height: 200)
        datePicker.datePickerMode = .DateAndTime
        datePicker.minuteInterval = 15
        
        inputView.addSubview(datePicker)
        
        datePicker.addTarget(self, action: #selector(AddGarageSaleViewController.datePickerPickedDate(_:)), forControlEvents: .ValueChanged)
        
        let doneButton = UIButton(frame: CGRect(x: view.frame.width - 100, y: 0, width: 100, height: 40))
        doneButton.setTitle("Done", forState: .Normal)
        doneButton.addTarget(self, action: #selector(AddGarageSaleViewController.inputViewDone(_:)), forControlEvents: .TouchUpInside)
        doneButton.backgroundColor = UIColor.redColor()
        inputView.addSubview(doneButton)
        
        datePickerLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width - 100, height: 40)
        datePickerLabel.font = UIFont.systemFontOfSize(18)
        datePickerLabel.text = "Hello"
        datePickerLabel.textColor = UIColor.blackColor()
        inputView.addSubview(datePickerLabel)
        
        datePickerPickedDate(datePicker)
        dateText.inputView = inputView
        endDateText.inputView = inputView
    }
    
    
    func datePickerPickedDate(sender: UIDatePicker) {
        // TODO: Handle Date
        date = sender.date
        if let textField = currentDateText {
            // currentDateText!.text = dateTimeFormatter.stringFromDate(date!)
            displayDate(date!, textField: currentDateText!)
            if textField == dateText {
                if let dateOrder = date?.compare(endDate!) {
                    if dateOrder == NSComparisonResult.OrderedDescending {
                        endDate = date
                        displayDate(endDate!, textField: endDateText)
                    }
                }
            }
        }
    }
    
    func inputViewDone(sender: UIButton) {
        // TODO: Handle Done Button
        view.endEditing(true)
    }
    
    func displayDate(date: NSDate, textField: UITextField) {
        // TODO: Rewrite as calculated properties for date and endDate
        textField.text = dateTimeFormatter.stringFromDate(date)
    }
    
    
    // Configuer the Date formatter
    func configureDateFormatter() {
        dateTimeFormatter.dateFormat = Constants.date.startEndDateTimeFormat
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        view.endEditing(true)
    }
    
    // TODO: Calculate start and end dates
    // Start date predicts next Sat 10 AM - This could be set in user profile
    // End
    
    
    
    // MARK: - View Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        date = NSDate()
        endDate = NSDate()
        
        displayDate(date!, textField: dateText)
        displayDate(endDate!, textField: endDateText)
        
        
        // TODO: Resolve location vs address...
        getLocation()
        // For now the location is entered when the view appears
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureDateFormatter()
        
        dateText.delegate = self
        titleText.delegate = self
        addressText.delegate = self
        notesText.delegate = self
        endDateText.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddGarageSaleViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
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



