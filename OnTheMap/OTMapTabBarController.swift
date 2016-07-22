//
//  OTMapTabViewController.swift
//  OnTheMap
//
//  Created by Michael Main on 7/21/16.
//  Copyright © 2016 Michael Main. All rights reserved.
//

import UIKit

class OTMapWebViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    var urlToLoad : NSURL!
    
    override func viewDidLoad() {
        webView.loadRequest(NSURLRequest(URL: urlToLoad))
    }
}

class OTMapTabBarController : UITabBarController {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewWillAppear(animated: Bool) {
        refreshLocations()
    }
    
    @IBAction func refreshClicked(sender: AnyObject) {
        refreshLocations()
    }
    
    @IBAction func addPinClicked(sender: AnyObject) {
        // Get the create meme view controller from story board
        let object:AnyObject = (self.storyboard?.instantiateViewControllerWithIdentifier("UpdatePinViewController"))!
        let viewController : UpdatePinViewController = object as! UpdatePinViewController
        
        // Setup view controller before opening
        viewController.hidesBottomBarWhenPushed = true
        
        // Push the view controller onto the navgation stack
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func refreshLocations() -> Void {
        // Notify on completion
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "trinary.locationsRefreshed", object: nil))
        self.appDelegate.studentLocations = Array<StudentLocation>()
        
        let parseClient = UdacityParseClient(
            appId: "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
            apiKey: "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY")
        
        parseClient.getAllStudentLocations(
            onComplete: {(locations: Array<StudentLocation>!) -> Void in
                self.appDelegate.studentLocations = locations.sort {(e1, e2) -> Bool in
                    return e1.lastName < e2.lastName
                }
                
                for location in locations {
                    if (location.uniqueKey == self.appDelegate.uniqueKey) {
                        self.appDelegate.myStudentLocation = location
                        break
                    }
                }
                
                // Notify on completion
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "trinary.locationsUpdated", object: nil))
        })

    }
}
