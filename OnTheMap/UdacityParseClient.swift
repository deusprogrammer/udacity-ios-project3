//
//  UdacityParseClient.swift
//  ParseClient
//
//  Created by Michael Main on 7/19/16.
//  Copyright © 2016 Michael Main. All rights reserved.
//

import Foundation

// A class for containing student locations
class StudentLocation : NBMappable {
    var uniqueKey : String!
    var objectId  : String!
    var firstName : String!
    var lastName : String!
    var mediaUrl : String!
    var mapString : String!
    var longtitude : Double!
    var latitude : Double!
    
    // Serialize this object into a Dictionary
    func serialize() -> Dictionary<String, Any> {
        return [
            "uniqueKey" : self.uniqueKey,
            "firstName" : self.firstName,
            "lastName"  : self.lastName,
            "mediaURL"  : self.mediaUrl,
            "mapString" : self.mapString,
            "latitude"  : self.latitude,
            "longitude" : self.longtitude
        ]
    }
    
    // Deserialize supplied map into this object
    func deserialize(map: Dictionary<String, Any>) {
        self.objectId   = map["objectId"]  as! String
        self.uniqueKey  = map["uniqueKey"] as! String
        self.firstName  = map["firstName"] as! String
        self.lastName   = map["lastName"]  as! String
        self.mediaUrl   = map["mediaURL"]  as! String
        self.mapString  = map["mapString"] as! String
        self.latitude   = map["latitude"]  as! Double
        self.longtitude = map["longitude"] as! Double
    }
}

class UdacityClient {
    init() {
        NBRestClient.setupDefaults()
    }
    
    func getUserData(
        userId: String,
        onComplete: ((payload: Any) -> Void)! = nil,
        onError: ((statusCode: Int, payload: Any) -> Void)! = nil) {
        
        let request = NBRestClient.get(
            hostname: "www.udacity.com",
            uri: "/api/users/\(userId)",
            ssl: true)
        
        request.setAcceptType(NBRestClient.NBMediaType.APPLICATION_JSON)
        
        request.sendAsync({(response: NBRestResponse!) -> Void in
            // If error is set, display it and fail
            if (response.error != nil) {
                print(response.error?.localizedDescription)
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: [
                            "errorMessage": response.error?.localizedDescription
                        ]
                    )
                }
                return
            }
            
            print("Status Code:  \(response.statusCode)")
            
            // If status code not 200, then fail
            if (response.statusCode != 200) {
                print("HTTP request failed")
                if (onError != nil) {
                    onError(
                        statusCode: response.statusCode,
                        payload: response.body
                    )
                }
                return
            }
            
            // Run call back if one was provided
            if (onComplete != nil) {
                onComplete(payload: response.body)
            }
        })
    }
    
    func login(
        username username: String,
        password: String,
        onComplete: ((payload: Any) -> Void)! = nil,
        onError: ((statusCode: Int, payload: Any) -> Void)! = nil) {
        
        let credentials : Dictionary<String, Any> = [
            "username": username,
            "password": password
        ]
        
        let request = NBRestClient.post(
            hostname: "www.udacity.com",
            uri: "/api/session",
            body: [
                "udacity": credentials
            ],
            ssl: true)
        
        request.setContentType(NBRestClient.NBMediaType.APPLICATION_JSON)
        request.setAcceptType(NBRestClient.NBMediaType.APPLICATION_JSON)
        
        request.sendAsync({(response: NBRestResponse!) -> Void in
            
            // If error is set, display it and fail
            if (response.error != nil) {
                print(response.error?.localizedDescription)
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: [
                            "errorMessage": response.error?.localizedDescription
                        ]
                    )
                }
                return
            }
            
            print("Status Code:  \(response.statusCode)")
            
            // If status code not 200, then fail
            if (response.statusCode != 200) {
                print("HTTP request failed")
                if (onError != nil) {
                    onError(
                        statusCode: response.statusCode,
                        payload: response.body
                    )
                }
                return
            }
            
            // Run call back if one was provided
            if (onComplete != nil) {
                onComplete(payload: response.body)
            }
        })
    }
}

// A client for manipulation of student location objects in Parse
class UdacityParseClient {
    var appId    : String
    var apiKey   : String
    var ssl      : Bool
    var hostname : String
    var port     : String
    
    init(
        hostname: String = "api.parse.com",
        ssl: Bool = true,
        port: String = "",
        appId: String!,
        apiKey: String!) {
        
        // Instantiate member fields
        self.appId = appId
        self.apiKey = apiKey
        self.hostname = hostname
        self.port = port
        self.ssl = ssl
        
        // Set object mappers to default
        NBRestClient.setupDefaults()
    }
    
    // Update a student object (must have an object id set)
    func updateStudentLocation(
        location: StudentLocation,
        onComplete : ((location : StudentLocation!) -> Void)! = nil,
        onError: ((statusCode: Int, payload: Any) -> Void)! = nil) -> Void {
        
        // If the object id is empty, fail
        if location.objectId == nil {
            print("Cannot update an StudentLocation without an object id")
            return
        }
        
        // Create put request
        let request = NBRestClient.put(
            hostname: self.hostname,
            port: self.port,
            uri: "/1/classes/StudentLocation/\(location.objectId)",
            headers: [
                "X-Parse-Application-Id": self.appId,
                "X-Parse-REST-API-Key": self.apiKey
            ],
            body: location.serialize(),
            ssl: self.ssl)
        
        // Set accept-type and content-type
        request.setAcceptType(NBRestClient.NBMediaType.APPLICATION_JSON)
        request.setContentType(NBRestClient.NBMediaType.APPLICATION_JSON)
        
        // Send request asynchronously
        request.sendAsync({(response: NBRestResponse!) -> Void in
            
            // If error is set, display it and fail
            if (response.error != nil) {
                print(response.error?.localizedDescription)
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: [
                            "errorMessage": response.error?.localizedDescription
                        ]
                    )
                }
                return
            }
            
            print("Status Code:  \(response.statusCode)")
            
            // If status code not 200, then fail
            if (response.statusCode != 200) {
                print("HTTP request failed")
                if (onError != nil) {
                    onError(
                        statusCode: response.statusCode,
                        payload: response.body
                    )
                }
                return
            }
            
            // Run call back if one was provided
            if (onComplete != nil) {
                onComplete(location: location)
            }
        })
    }
    
    // Create a student object
    func createStudentLocation(
        location: StudentLocation,
        onComplete : ((location : StudentLocation!) -> Void)! = nil,
        onError: ((statusCode: Int, payload: Any) -> Void)! = nil) -> Void {
        
        let request = NBRestClient.post(
            hostname: self.hostname,
            port: self.port,
            uri: "/1/classes/StudentLocation",
            headers: [
                "X-Parse-Application-Id": self.appId,
                "X-Parse-REST-API-Key": self.apiKey
            ],
            body: location.serialize(),
            ssl: self.ssl)
        
        request.setAcceptType(NBRestClient.NBMediaType.APPLICATION_JSON)
        request.setContentType(NBRestClient.NBMediaType.APPLICATION_JSON)
        
        // Send request asynchronously
        request.sendAsync({(response: NBRestResponse!) -> Void in
            
            // If error is set, display it and fail
            if (response.error != nil) {
                print(response.error?.localizedDescription)
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: [
                            "errorMessage": response.error?.localizedDescription
                        ]
                    )
                }
                return
            }
            
            print("Status Code:  \(response.statusCode)")
            
            // If status code not 201, then fail
            if (response.statusCode != 201) {
                print("HTTP request failed")
                if (onError != nil) {
                    onError(
                        statusCode: response.statusCode,
                        payload: response.body
                    )
                }
                return
            }
            
            // Parse result and update location object with object id
            var result = response.body as! Dictionary<String, Any>
            location.objectId = result["objectId"] as! String
            
            // Run call back if one was provided
            if (onComplete != nil) {
                onComplete(location: location)
            }
        })
    }
    
    func getStudentLocationById(
        uniqueKey: String,
        onComplete : ((location : StudentLocation!) -> Void)! = nil,
        onError: ((statusCode: Int, payload: Any) -> Void)! = nil
        ) {
        
        let whereQueryMap : Dictionary<String, Any> = [
            "uniqueKey": uniqueKey
        ]
        
        let whereQuery : String = NBJSON.Parser.serialize(whereQueryMap).stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        
        let request = NBRestClient.get(
            hostname: self.hostname,
            port: self.port,
            uri: "/1/classes/StudentLocation",
            query: [
                "where": whereQuery
            ],
            headers: [
                "X-Parse-Application-Id": self.appId,
                "X-Parse-REST-API-Key": self.apiKey
            ],
            ssl: self.ssl)
        
        request.setAcceptType(NBRestClient.NBMediaType.APPLICATION_JSON)
        
        // Send request asynchronously
        request.sendAsync({(response: NBRestResponse!) -> Void in
            
            // If error is set, display it and fail
            if (response.error != nil) {
                print(response.error?.localizedDescription)
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: [
                            "errorMessage": response.error?.localizedDescription
                        ]
                    )
                }
                return
            }
            
            print("Status Code:  \(response.statusCode)")
            
            // If status code not 201, then fail
            if (response.statusCode != 200) {
                print("HTTP request failed")
                if (onError != nil) {
                    onError(
                        statusCode: response.statusCode,
                        payload: response.body
                    )
                }
                return
            }
            
            // Acquire the results from the results key at the root of the returned object
            let results = NBJSON.Utils.search("/results", object: response.body) as! Array<Any>
            
            // On no results
            if (results.count <= 0) {
                if (onComplete != nil) {
                    onComplete(location: nil)
                }
                
                return
            }
            
            let location = StudentLocation()
            location.deserialize(results[0] as! Dictionary<String, Any>)
            
            // Run call back if one was provided
            if (onComplete != nil) {
                onComplete(location: location)
            }
        })

    }
    
    // Get all student locations one page at a time (calling eachPage with each page)
    func getAllStudentLocations(
        page: Int = 0,
        pageSize: Int = 100,
        previousLocations: Array<StudentLocation>! = Array<StudentLocation>(),
        eachPage : ((location : Array<StudentLocation>!) -> Void)! = nil,
        onComplete : ((locations: Array<StudentLocation>!) -> Void)! = nil,
        onError: ((statusCode: Int, page: Int, pageSize: Int, payload: Any) -> Void)! = nil) -> Void {
        
        let skip = page * pageSize
        let limit = pageSize
        let request = NBRestClient.get(
            hostname: self.hostname,
            port: self.port,
            uri: "/1/classes/StudentLocation",
            query: [
                "limit": limit,
                "skip": skip
            ],
            headers: [
                "X-Parse-Application-Id": self.appId,
                "X-Parse-REST-API-Key": self.apiKey
            ],
            ssl: self.ssl)
        
        request.setAcceptType(NBRestClient.NBMediaType.APPLICATION_JSON)
        
        request.sendAsync({(response: NBRestResponse!) -> Void in
            // If error is set, display it and fail
            if (response.error != nil) {
                print(response.error?.localizedDescription)
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        page: page,
                        pageSize: pageSize,
                        payload: [
                            "errorMessage": response.error?.localizedDescription
                        ]
                    )
                }
                return
            }
            
            print("Status Code:  \(response.statusCode)")
            
            // If status code not 200, then fail
            if (response.statusCode != 200) {
                print("HTTP request failed")
                if (onError != nil) {
                    onError(
                        statusCode: response.statusCode,
                        page: page,
                        pageSize: pageSize,
                        payload: response.body
                    )
                }
                return
            }
            
            // Acquire the results from the results key at the root of the returned object
            let results = NBJSON.Utils.search("/results", object: response.body) as! Array<Any>
            
            // If there are no results, then quit
            if (results.count <= 0) {
                if (onComplete != nil) {
                    onComplete(locations: previousLocations)
                }
                return
            }
            
            // Deserialize the payload into an array of StudentLocations
            var locations : Array<StudentLocation> = []
            for anyResult in results {
                let result = anyResult as! Dictionary<String, Any>
                if result.isEmpty {
                    continue
                }
                
                let studentLocation = StudentLocation()
                studentLocation.deserialize(result)
                
                locations.append(studentLocation)
            }
            
            var updatedLocations = Array<StudentLocation>()
            
            updatedLocations.appendContentsOf(previousLocations)
            updatedLocations.appendContentsOf(locations)
            
            // Run call back if one was provided
            if eachPage != nil {
                eachPage(location: locations)
            }
            
            // Recurse to the next page
            let nextPage = page + 1
            self.getAllStudentLocations(nextPage, previousLocations: updatedLocations, pageSize: pageSize, eachPage: eachPage, onComplete: onComplete, onError: onError)
        })
    }
}