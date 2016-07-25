//
//  OTMapTabViewController.swift
//  OnTheMap
//
//  Created by Michael Main on 7/21/16.
//  Copyright © 2016 Michael Main. All rights reserved.
//

import UIKit

class OTMapTabBarController : UITabBarController {    
    override func viewWillAppear(animated: Bool) {
        refreshLocations()
    }
    
    @IBAction func logoutClicked(sender: AnyObject) {
        let udacityClient = UdacityClient()
        udacityClient.logout(
            onComplete: {(payload: Any) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                    self.presentViewController(viewController, animated: true, completion: nil)
                }
            },
            onError: {(statusCode: Int, payload: Any) -> Void in
                var errorObject = payload as! Dictionary<String, AnyObject>
                let error = errorObject["error"] as! String
                
                dispatch_async(dispatch_get_main_queue()) {
                    let alertController = UIAlertController(title: "Logout Failure", message: error, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(OKAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            })
    }
    
    @IBAction func unwindToMap(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func addPinClicked(sender: AnyObject) {
//        // Get the create meme view controller from story board
//        let object:AnyObject = (self.storyboard?.instantiateViewControllerWithIdentifier("UpdatePinViewController"))!
//        let viewController : UpdatePinViewController = object as! UpdatePinViewController
//        
//        // Setup view controller before opening
//        viewController.hidesBottomBarWhenPushed = true
//        
//        self.showViewController(viewController, sender: self)
    }
    
    func refreshLocations() -> Void {
        // Notify on completion
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "trinary.locationsRefreshed", object: nil))
        StudentLocationModel.studentLocations = Array<StudentLocation>()
        
        let parseClient = UdacityParseClient(
            appId: "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
            apiKey: "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY")
        
        parseClient.getStudentLocationById(
            StudentLocationModel.uniqueKey,
            onComplete: {(location: StudentLocation!) -> Void in
                StudentLocationModel.myStudentLocation = location
                
                parseClient.getStudentLocations(
                    page: 0,
                    pageSize: 100,
                    onComplete: {(locations: Array<StudentLocation>!) -> Void in
                        StudentLocationModel.studentLocations = locations
                        
                        // Notify on completion
                        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "trinary.locationsUpdated", object: nil))
                    },
                    onError: {(statusCode: Int, payload: Any) -> Void in
                        var errorObject = payload as! Dictionary<String, AnyObject>
                        let error = errorObject["error"] as! String
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            let alertController = UIAlertController(title: "Network Failure", message: error, preferredStyle: .Alert)
                            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            alertController.addAction(OKAction)
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
                )
            },
            onError: {(statusCode: Int, payload: Any) -> Void in
                var errorObject = payload as! Dictionary<String, AnyObject>
                let error = errorObject["error"] as! String
                
                dispatch_async(dispatch_get_main_queue()) {
                    let alertController = UIAlertController(title: "Network Failure", message: error, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(OKAction)
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            })
    }
}
