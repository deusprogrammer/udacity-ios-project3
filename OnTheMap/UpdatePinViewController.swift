//
//  UpdatePinViewController.swift
//  OnTheMap
//
//  Created by Michael Main on 7/21/16.
//  Copyright © 2016 Michael Main. All rights reserved.
//

import UIKit
import CoreLocation

class UpdatePinViewController : UIViewController, UITextFieldDelegate {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var cityStateField: UITextField!
    @IBOutlet weak var mediaUrlField: UITextField!
    @IBOutlet weak var updatePinButton: UIButton!
    
    var screenShifted = false
    var amountShifted : CGFloat = 0
    
    override func viewWillAppear(animated: Bool) {
        self.cityStateField.text = self.appDelegate.myStudentLocation.mapString
        self.mediaUrlField.text = self.appDelegate.myStudentLocation.mediaUrl
        self.cityStateField.delegate = self
        self.mediaUrlField.delegate = self
        
        // Subscribe to keyboard notifications
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.unsubscribeFromKeyboardNotifications()
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
        if (!screenShifted && mediaUrlField.isFirstResponder()) {
            print("KEYBOARD SHOW")
            screenShifted = true
            amountShifted = getKeyboardHeight(notification)
            self.view.frame.origin.y -= amountShifted
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (screenShifted && mediaUrlField.isFirstResponder()) {
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
    
    @IBAction func updateClicked(sender: AnyObject) {
        self.updatePinButton.enabled = false
        
        let addressString = cityStateField.text
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString!) {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            print("\(placemarks![0].location?.coordinate.latitude), \(placemarks![0].location?.coordinate.longitude)")
            
            let parseClient = UdacityParseClient(
                appId: "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
                apiKey: "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY")
            if (error != nil) {
                return
            }

            var myStudentLocation = self.appDelegate.myStudentLocation
            
            if (myStudentLocation != nil) {
                let mediaUrl = self.mediaUrlField.text
                let mapString = self.cityStateField.text
                myStudentLocation.mapString = mapString
                myStudentLocation.mediaUrl = mediaUrl
                myStudentLocation.latitude = placemarks![0].location?.coordinate.latitude
                myStudentLocation.longtitude = placemarks![0].location?.coordinate.longitude
                
                NBJSON.Utils.printObject(myStudentLocation.serialize())
                parseClient.updateStudentLocation(
                    self.appDelegate.myStudentLocation,
                    onComplete: {(location: StudentLocation!) -> Void in
                        dispatch_async(dispatch_get_main_queue()) {
                            self.updatePinButton.enabled = true
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    },
                    onError:  {(statusCode: Int, payload: Any!) -> Void in
                    }
                )
            } else {
                var userData = self.appDelegate.myStudentData
                let uniqueKey = self.appDelegate.uniqueKey
                let mediaUrl = self.mediaUrlField.text
                let mapString = self.cityStateField.text
                myStudentLocation = StudentLocation()
                myStudentLocation.firstName = userData["firstName"]
                myStudentLocation.lastName = userData["lastName"]
                myStudentLocation.uniqueKey = uniqueKey
                myStudentLocation.mediaUrl = mediaUrl
                myStudentLocation.mapString = mapString
                myStudentLocation.latitude = placemarks![0].location?.coordinate.latitude
                myStudentLocation.longtitude = placemarks![0].location?.coordinate.longitude
                
                NBJSON.Utils.printObject(myStudentLocation.serialize())
                parseClient.createStudentLocation(
                    myStudentLocation,
                    onComplete: {(location: StudentLocation!) -> Void in
                        dispatch_async(dispatch_get_main_queue()) {
                            self.updatePinButton.enabled = true
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    },
                    onError:  {(statusCode: Int, payload: Any!) -> Void in
                    })
            }
        }
    }
}