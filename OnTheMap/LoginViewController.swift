//
//  ViewController.swift
//  OnTheMap
//
//  Created by Michael Main on 7/21/16.
//  Copyright © 2016 Michael Main. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func loginClicked(sender: AnyObject) {
        loginButton.enabled = false
        
        let udacityClient = UdacityClient()
        
        udacityClient.login(
            username: emailAddressField.text!,
            password: passwordField.text!,
            onComplete: {(payload: Any) -> Void in
                // Pull out the unique key
                self.appDelegate.uniqueKey = NBJSON.Utils.search("/account/key", object: payload) as! String
                
                udacityClient.getUserData(
                    self.appDelegate.uniqueKey,
                    onComplete: {(payload: Any) -> Void in
                        var userData = NBJSON.Utils.search("/user", object: payload) as! Dictionary<String, Any>
                        
                        self.appDelegate.myStudentData["firstName"] = userData["first_name"] as? String
                        self.appDelegate.myStudentData["lastName"] = userData["last_name"] as? String
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("OTMapNavigator") as! UINavigationController
                            self.presentViewController(viewController, animated: true) {
                                self.loginButton.enabled = true
                            }
                        }
                    },
                    onError: {(statusCode: Int, payload: Any) -> Void in
                    }
                )
            },
            onError: {(statusCode: Int, payload: Any) -> Void in
                NBJSON.Utils.printObject(payload)
                
                var errorObject = payload as! Dictionary<String, Any>
                let error = errorObject["error"] as! String
                
                dispatch_async(dispatch_get_main_queue()) {
                    let alertController = UIAlertController(title: "Login Failure", message: error, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(OKAction)
                    
                    self.presentViewController(alertController, animated: true) {
                        self.loginButton.enabled = true
                        self.emailAddressField.text = ""
                        self.passwordField.text = ""
                    }
                }
            })
    }
}

