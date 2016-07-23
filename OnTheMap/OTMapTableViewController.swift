//
//  OTMapTableViewController.swift
//  OnTheMap
//
//  Created by Michael Main on 7/21/16.
//  Copyright © 2016 Michael Main. All rights reserved.
//

import UIKit

class OTMapTableViewController: UITableViewController {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OTMapTableViewController.updateContents), name: "trinary.locationsUpdated", object: nil)
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appDelegate.studentLocations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableViewCell")!
        let location = self.appDelegate.studentLocations[indexPath.row]
        
        cell.textLabel?.text = "\(location.lastName), \(location.firstName)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = self.appDelegate.studentLocations[indexPath.row]
        
        if let url: NSURL = NSURL(string: location.mediaUrl) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func updateContents() {
        self.tableView.reloadData()
    }
}
