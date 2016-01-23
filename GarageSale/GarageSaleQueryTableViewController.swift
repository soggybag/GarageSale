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

class SimpleTableViewController: PFQueryTableViewController {
    
    
    let dateFormatter = NSDateFormatter()
    
    
    
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the date style
        dateFormatter.dateStyle = .FullStyle
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