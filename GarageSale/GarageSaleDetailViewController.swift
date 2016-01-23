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
    
    
    
    // MARK: IBOutlet
    
    
    @IBOutlet weak var imageView: PFImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    
    // MARK: Display info
    
    func displayGarageSale() {
        guard let garageSale = garageSale else {
            return
        }
        
        imageView.file = garageSale["image"] as? PFFile
        imageView.loadInBackground({ (image: UIImage?, error: NSError?) -> Void in
            print("image loaded")
        }) { (progress: Int32) -> Void in
            print("image loading: \(progress)")
        }
        titleLabel.text = garageSale["title"] as? String
        addressLabel.text = garageSale["address"] as? String
        // dateLabel.text = garageSale["date"]
        // startLabel.text = garageSale["startDate"]
        // endLabel.text = garageSale["endDate"]
    }
    
    
    // MARK: View LifeCycle
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        displayGarageSale()
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
