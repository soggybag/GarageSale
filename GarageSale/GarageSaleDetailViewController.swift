//
//  GarageSaleDetailViewController.swift
//  GarageSale
//
//  Created by mitchell hudson on 1/21/16.
//  Copyright © 2016 mitchell hudson. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class GarageSaleDetailViewController: UIViewController {

    
    var garageSale: PFObject?
    var dateTimeFormatter = NSDateFormatter()
    
    
    // MARK: IBOutlet
    
    
    @IBOutlet weak var imageView: PFImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var imageActivityView: UIActivityIndicatorView!
    
    
    
    
    // MARK: Display info
    
    func displayGarageSale() {
        guard let garageSale = garageSale else {
            return
        }
        
        imageView.file = garageSale[Constants.garageSale.image] as? PFFile
        // TODO: Show acticity spinner
        imageActivityView.hidden = false
        imageView.loadInBackground({ (image: UIImage?, error: NSError?) -> Void in
            // TODO: Hide Activity spinner
            print("image loaded")
            self.imageActivityView.hidden = true
        }) { (progress: Int32) -> Void in
            print("image loading: \(progress)")
        }
        
        titleLabel.text = garageSale[Constants.garageSale.title] as? String
        addressLabel.text = garageSale[Constants.garageSale.address] as? String
        if let startDate = garageSale[Constants.garageSale.startDate] as? NSDate {
            startLabel.text = dateTimeFormatter.stringFromDate(startDate)
        }
        
        if let endDate = garageSale[Constants.garageSale.endDate] as? NSDate {
            endLabel.text = dateTimeFormatter.stringFromDate(endDate)
        }
    }
    
    
    // MARK: View LifeCycle
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        displayGarageSale()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateTimeFormatter.dateFormat = Constants.date.startEndDateTimeFormat
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
