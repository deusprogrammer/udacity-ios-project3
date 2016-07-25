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
                StudentLocationModel.uniqueKey = JSONHelper.search("/account/key", object: payload) as! String
                
                udacityClient.getUserData(
                    StudentLocationModel.uniqueKey,
                    onComplete: {(payload: Any) -> Void in
                        
                        var userData = JSONHelper.search("/user", object: payload) as! Dictionary<String, AnyObject>
                        
                        StudentLocationModel.myStudentData["firstName"] = userData["first_name"] as? String
                        StudentLocationModel.myStudentData["lastName"] = userData["last_name"] as? String
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("OTMapNavigator") as! UINavigationController
                            self.presentViewController(viewController, animated: true) {
                                self.loginButton.enabled = true
                            }
                        }
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

