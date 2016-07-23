//
//  ViewController.swift
//  OnTheMap
//
//  Created by Michael Main on 7/21/16.
//  Copyright © 2016 Michael Main. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var screenShifted = false
    var amountShifted : CGFloat = 0

    override func viewWillAppear(animated: Bool) {
        emailAddressField.delegate = self
        passwordField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // When the text field should return, resign the first responder
        textField.resignFirstResponder()
        return true;
    }

    @IBAction func loginClicked(sender: AnyObject) {
        loginButton.enabled = false
        
        let udacityClient = UdacityClient()
        
        udacityClient.login(
            username: emailAddressField.text!,
            password: passwordField.text!,
            onComplete: {(payload: Any) -> Void in
                
                // Pull out the unique key
                self.appDelegate.uniqueKey = JSONHelper.search("/account/key", object: payload) as! String
                
                udacityClient.getUserData(
                    self.appDelegate.uniqueKey,
                    onComplete: {(payload: Any) -> Void in
                        
                        var userData = JSONHelper.search("/user", object: payload) as! Dictionary<String, AnyObject>
                        
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
                var errorObject = payload as! Dictionary<String, AnyObject>
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

