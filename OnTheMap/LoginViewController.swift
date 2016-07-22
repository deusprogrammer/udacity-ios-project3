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
        
        // Subscribe to keyboard notifications
        //self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        //self.unsubscribeFromKeyboardNotifications()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // When the text field should return, resign the first responder
        textField.resignFirstResponder()
        return true;
    }
    
    func subscribeToKeyboardNotifications() {
        // Add keyboard show and hide observers
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(LoginViewController.keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(LoginViewController.keyboardWillHide(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        // Remove keyboard show and hide observers
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: UIKeyboardWillShowNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(
            self,
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if (!screenShifted && passwordField.isFirstResponder()) {
            print("KEYBOARD SHOW")
            screenShifted = true
            amountShifted = getKeyboardHeight(notification)
            self.view.frame.origin.y -= amountShifted
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (screenShifted) {
            print("KEYBOARD HIDE")
            screenShifted = false
            self.view.frame.origin.y += amountShifted
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        // Get keyboard height
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
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

