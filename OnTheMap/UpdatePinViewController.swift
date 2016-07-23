//
//  UpdatePinViewController.swift
//  OnTheMap
//
//  Created by Michael Main on 7/21/16.
//  Copyright © 2016 Michael Main. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class OTMapGeocoderViewController : UIViewController, UITextFieldDelegate {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var mediaUrlField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var updatePinButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var latitude : Double = 0
    var longitude : Double = 0
    var mapString : String = ""
    
    override func viewWillAppear(animated: Bool) {
        // Set media url field to field we downloaded already if the user existed already
        if (self.appDelegate.myStudentLocation != nil) {
            self.mediaUrlField.text = self.appDelegate.myStudentLocation.mediaUrl
        }
        
        // We will create an MKPointAnnotation for each dictionary in "locations". The
        // point annotations will be stored in this array, and then provided to the map view.
        var annotations = [MKPointAnnotation]()
            
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Here we create the annotation and set its coordiate
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        // Finally we place the annotation in an array of annotations.
        annotations.append(annotation)
        
        // Add annotation and then center on pin
        self.mapView.addAnnotations(annotations)
        self.mapView.setCenterCoordinate(coordinate, animated: true)
    }
    
    @IBAction func cancelClicked(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("OTMapNavigator") as! UINavigationController
            self.presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func updateButtonClicked(sender: AnyObject) {
        self.updatePinButton.enabled = false
        
        let parseClient = UdacityParseClient(
            appId: "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
            apiKey: "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY")

        var myStudentLocation = self.appDelegate.myStudentLocation

        if (myStudentLocation != nil) {
            let mediaUrl = self.mediaUrlField.text
            myStudentLocation.mapString = self.mapString
            myStudentLocation.mediaUrl = mediaUrl
            myStudentLocation.latitude = self.latitude
            myStudentLocation.longtitude = self.longitude

            parseClient.updateStudentLocation(
                self.appDelegate.myStudentLocation,
                onComplete: {(location: StudentLocation!) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("OTMapNavigator") as! UINavigationController
                        self.presentViewController(viewController, animated: true, completion: nil)
                    }
                },
                onError:  {(statusCode: Int, payload: Any!) -> Void in
                    var errorObject = payload as! Dictionary<String, AnyObject>
                    let error = errorObject["error"] as! String

                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "Pin Update Failure", message: error, preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alertController.addAction(OKAction)

                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        self.updatePinButton.enabled = false
                    }
                }
            )
        } else {
            var userData = self.appDelegate.myStudentData
            let uniqueKey = self.appDelegate.uniqueKey
            let mediaUrl = self.mediaUrlField.text
            let mapString = self.mapString
            myStudentLocation = StudentLocation()
            myStudentLocation.firstName = userData["firstName"]
            myStudentLocation.lastName = userData["lastName"]
            myStudentLocation.uniqueKey = uniqueKey
            myStudentLocation.mediaUrl = mediaUrl
            myStudentLocation.mapString = mapString
            myStudentLocation.latitude = self.latitude
            myStudentLocation.longtitude = self.longitude

            parseClient.createStudentLocation(
                myStudentLocation,
                onComplete: {(location: StudentLocation!) -> Void in
                    self.appDelegate.myStudentLocation = location
                    dispatch_async(dispatch_get_main_queue()) {
                        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("OTMapNavigator") as! UINavigationController
                        self.presentViewController(viewController, animated: true, completion: nil)
                    }
                },
                onError:  {(statusCode: Int, payload: Any!) -> Void in
                    var errorObject = payload as! Dictionary<String, AnyObject>
                    let error = errorObject["error"] as! String

                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "Pin Creation Failure", message: error, preferredStyle: .Alert)
                        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alertController.addAction(OKAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        self.updatePinButton.enabled = false
                    }
                })
        }

    }
}

class UpdatePinViewController : UIViewController {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var cityStateField: UITextField!
    @IBOutlet weak var updatePinButton: UIButton!
    
    var screenShifted = false
    var amountShifted : CGFloat = 0
    
    override func viewWillAppear(animated: Bool) {
        if (self.appDelegate.myStudentLocation != nil) {
            self.cityStateField.text = self.appDelegate.myStudentLocation.mapString
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // When the text field should return, resign the first responder
        textField.resignFirstResponder()
        return true;
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
            
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue()) {
                    let alertController = UIAlertController(title: "Geocoder Failure", message: error?.localizedDescription, preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(OKAction)

                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                let viewController = (self.storyboard?.instantiateViewControllerWithIdentifier("OTMapGeocoderViewController"))! as! OTMapGeocoderViewController
                viewController.latitude = (placemarks![0].location?.coordinate.latitude)!
                viewController.longitude = (placemarks![0].location?.coordinate.longitude)!
                viewController.mapString = self.cityStateField.text!
                self.presentViewController(viewController, animated: true, completion: nil)
            }
        }
    }
}