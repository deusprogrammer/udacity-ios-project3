//
//  OTMapTableViewController.swift
//  OnTheMap
//
//  Created by Michael Main on 7/21/16.
//  Copyright © 2016 Michael Main. All rights reserved.
//

import UIKit

class OTMapTableViewController: UITableViewController {
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OTMapTableViewController.updateContents), name: "trinary.locationsUpdated", object: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocationModel.studentLocations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell")!
        
        if (indexPath.row >= StudentLocationModel.studentLocations.count) {
            cell.textLabel?.text = "Empty"
            return cell
        }
        
        let location = StudentLocationModel.studentLocations[indexPath.row]
            
        cell.textLabel?.text = "\(location.lastName), \(location.firstName)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = StudentLocationModel.studentLocations[indexPath.row]
        
        if let url: NSURL = NSURL(string: location.mediaUrl) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func updateContents() {
        self.tableView.reloadData()
    }
}
