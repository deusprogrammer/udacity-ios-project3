//
//  UdacityParseClient.swift
//  ParseClient
//
//  Created by Michael Main on 7/19/16.
//  Copyright © 2016 Michael Main. All rights reserved.
//

import Foundation

// A class for containing student locations
struct StudentLocation {
    var uniqueKey : String!
    var objectId  : String!
    var firstName : String!
    var lastName : String!
    var mediaUrl : String!
    var mapString : String!
    var longtitude : Double!
    var latitude : Double!
    var updatedAt : String!
    
    init(map: Dictionary<String, AnyObject!>) {
        if (map["objectId"] != nil) {
            self.objectId   = map["objectId"]  as! String
        }
        
        self.uniqueKey  = map["uniqueKey"] as! String
        self.firstName  = map["firstName"] as! String
        self.lastName   = map["lastName"]  as! String
        self.mediaUrl   = map["mediaURL"]  as! String
        self.mapString  = map["mapString"] as! String
        self.latitude   = map["latitude"]  as! Double
        self.longtitude = map["longitude"] as! Double
        
        if (map["updatedAt"] != nil) {
            self.updatedAt  = map["updatedAt"] as! String
        }
    }
    
    // Serialize this object into a Dictionary
    func serialize() -> Dictionary<String, AnyObject!> {
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
}

class StudentLocationModel {
    static var studentLocations : Array<StudentLocation> = []
    static var uniqueKey: String! = nil
    static var myStudentLocation : StudentLocation! = nil
    static var myStudentData : Dictionary<String, String!>! = [:]
}

class UdacityClient {
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
                let errorMap = [
                    "error": (response.error?.localizedDescription)!
                    ] as Dictionary<String, AnyObject>
                
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: errorMap
                    )
                }
                return
            }
            
            // Deserialize json
            var data : AnyObject! = nil
            do {
                try data = NSJSONSerialization.JSONObjectWithData(response.body.subdataWithRange(NSRange(location: 4, length: response.body.length - 4)), options: .AllowFragments)
            } catch {
                let errorMap = [
                    "error": (response.error?.localizedDescription)!
                    ] as Dictionary<String, AnyObject>
                
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: errorMap
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
                        payload: data
                    )
                }
                return
            }
            
            // Run call back if one was provided
            if (onComplete != nil) {
                onComplete(payload: data)
            }
        })
    }
    
    func logout(
        onComplete onComplete: ((payload: Any) -> Void)! = nil,
        onError: ((statusCode: Int, payload: Any) -> Void)! = nil) {
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        let request = NBRestClient.delete(
            hostname: "www.udacity.com",
            uri: "/api/session",
            ssl: true)
        
        if let xsrfCookie = xsrfCookie {
            request.addHeader("X-XSRF-TOKEN", value: xsrfCookie.value)
        }
        
        request.setAcceptType(NBRestClient.NBMediaType.APPLICATION_JSON)
        
        request.sendAsync({(response: NBRestResponse!) -> Void in
            // If error is set, display it and fail
            if (response.error != nil) {
                print(response.error?.localizedDescription)
                let errorMap = [
                    "error": (response.error?.localizedDescription)!
                    ] as Dictionary<String, AnyObject>
                
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: errorMap
                    )
                }
                return
            }
            
            // Deserialize json
            var data : AnyObject! = nil
            do {
                try data = NSJSONSerialization.JSONObjectWithData(response.body.subdataWithRange(NSRange(location: 4, length: response.body.length - 4)), options: .AllowFragments)
            } catch {
                let errorMap = [
                    "error": (response.error?.localizedDescription)!
                    ] as Dictionary<String, AnyObject>
                
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: errorMap
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
                        payload: data
                    )
                }
                return
            }
            
            // Run call back if one was provided
            if (onComplete != nil) {
                onComplete(payload: data)
            }

        })
    }
    
    func login(
        username username: String,
        password: String,
        onComplete: ((payload: Any) -> Void)! = nil,
        onError: ((statusCode: Int, payload: Any) -> Void)! = nil) {
        
        let request = NBRestClient.post(
            hostname: "www.udacity.com",
            uri: "/api/session",
            body: JSONHelper.serialize([
                "udacity": [
                    "username": username,
                    "password": password
                    ]
                ]),
            ssl: true)
        
        request.setContentType(NBRestClient.NBMediaType.APPLICATION_JSON)
        request.setAcceptType(NBRestClient.NBMediaType.APPLICATION_JSON)
        
        request.sendAsync({(response: NBRestResponse!) -> Void in
            
            // If error is set, display it and fail
            if (response.error != nil) {
                print(response.error?.localizedDescription)
                let errorMap = [
                    "error": (response.error?.localizedDescription)!
                ] as Dictionary<String, AnyObject>
                
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: errorMap
                    )
                }
                return
            }
            
            // Deserialize json
            var data : AnyObject! = nil
            do {
                try data = NSJSONSerialization.JSONObjectWithData(response.body.subdataWithRange(NSRange(location: 4, length: response.body.length - 4)), options: .AllowFragments)
            } catch {
                let errorMap = [
                    "error": (response.error?.localizedDescription)!
                    ] as Dictionary<String, AnyObject>
                
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: errorMap
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
                        payload: data
                    )
                }
                return
            }
            
            // Run call back if one was provided
            if (onComplete != nil) {
                onComplete(payload: data)
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
            body: JSONHelper.serialize(location.serialize()),
            ssl: self.ssl)
        
        // Set accept-type and content-type
        request.setAcceptType(NBRestClient.NBMediaType.APPLICATION_JSON)
        request.setContentType(NBRestClient.NBMediaType.APPLICATION_JSON)
        
        // Send request asynchronously
        request.sendAsync({(response: NBRestResponse!) -> Void in
            
            // If error is set, display it and fail
            if (response.error != nil) {
                print(response.error?.localizedDescription)
                let errorMap = [
                    "error": (response.error?.localizedDescription)!
                    ] as Dictionary<String, AnyObject>
                
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: errorMap
                    )
                }
                return
            }
            
            // Deserialize json
            var data : AnyObject! = nil
            do {
                try data = NSJSONSerialization.JSONObjectWithData(response.body, options: .AllowFragments)
            } catch {
                let errorMap = [
                    "error": (response.error?.localizedDescription)!
                    ] as Dictionary<String, AnyObject>
                
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: errorMap
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
                        payload: data
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
            body: JSONHelper.serialize(location.serialize()),
            ssl: self.ssl)
        
        request.setAcceptType(NBRestClient.NBMediaType.APPLICATION_JSON)
        request.setContentType(NBRestClient.NBMediaType.APPLICATION_JSON)
        
        // Send request asynchronously
        request.sendAsync({(response: NBRestResponse!) -> Void in
            
            // If error is set, display it and fail
            if (response.error != nil) {
                print(response.error?.localizedDescription)
                let errorMap = [
                    "error": (response.error?.localizedDescription)!
                    ] as Dictionary<String, AnyObject>
                
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: errorMap
                    )
                }
                return
            }
            
            // Deserialize json
            var data : AnyObject! = nil
            do {
                try data = NSJSONSerialization.JSONObjectWithData(response.body, options: .AllowFragments)
            } catch {
                let errorMap = [
                    "error": (response.error?.localizedDescription)!
                    ] as Dictionary<String, AnyObject>
                
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: errorMap
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
                        payload: data
                    )
                }
                return
            }
            
            var newLocation = StudentLocation(map: location.serialize())
            
            // Parse result and update location object with object id
            var result = data as! Dictionary<String, AnyObject>
            newLocation.objectId = result["objectId"] as! String
            
            // Run call back if one was provided
            if (onComplete != nil) {
                onComplete(location: newLocation)
            }
        })
    }
    
    func getStudentLocationById(
        uniqueKey: String,
        onComplete : ((location : StudentLocation!) -> Void)! = nil,
        onError: ((statusCode: Int, payload: Any) -> Void)! = nil
        ) {
        
        let whereQueryMap = [
            "uniqueKey": uniqueKey
        ]
        
        let whereQuery : String = JSONHelper.serialize(whereQueryMap).stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        
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
                let errorMap = [
                    "error": (response.error?.localizedDescription)!
                ] as Dictionary<String, AnyObject>
                
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: errorMap
                    )
                }
                return
            }
            
            // Deserialize json
            var data : AnyObject! = nil
            do {
                try data = NSJSONSerialization.JSONObjectWithData(response.body, options: .AllowFragments)
            } catch {
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: [
                            "error": response.error?.localizedDescription
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
                        payload: data
                    )
                }
                return
            }
            
            // Acquire the results from the results key at the root of the returned object
            let results = JSONHelper.search("/results", object: data) as! Array<AnyObject>
            
            // On no results
            if (results.count <= 0) {
                if (onComplete != nil) {
                    onComplete(location: nil)
                }
                
                return
            }
            
            let location = StudentLocation(map: results[0] as! Dictionary<String, AnyObject>)
            
            // Run call back if one was provided
            if (onComplete != nil) {
                onComplete(location: location)
            }
        })

    }
    
    // Get all student locations one page at a time (calling eachPage with each page)
    func getStudentLocations(
        page page: Int = 0,
        pageSize: Int = 100,
        onComplete : ((locations: Array<StudentLocation>!) -> Void)! = nil,
        onError: ((statusCode: Int, payload: Any) -> Void)! = nil) -> Void {
        
        let skip = page * pageSize
        let limit = pageSize
        let request = NBRestClient.get(
            hostname: self.hostname,
            port: self.port,
            uri: "/1/classes/StudentLocation",
            query: [
                "limit": limit,
                "skip": skip,
                "order": "-updatedAt"
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
                let errorMap = [
                    "error": (response.error?.localizedDescription)!
                    ] as Dictionary<String, AnyObject>
                
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: errorMap
                    )
                }
                return
            }
            
            // Deserialize json
            var data : AnyObject! = nil
            do {
                try data = NSJSONSerialization.JSONObjectWithData(response.body, options: .AllowFragments)
            } catch {
                let errorMap = [
                    "error": (response.error?.localizedDescription)!
                    ] as Dictionary<String, AnyObject>
                
                if (onError != nil) {
                    onError(
                        statusCode: 0,
                        payload: errorMap
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
                        payload: data
                    )
                }
                return
            }
            
            // Acquire the results from the results key at the root of the returned object
            let results = JSONHelper.search("/results", object: data) as! Array<AnyObject>
            
            // Deserialize the payload into an array of StudentLocations
            var locations : Array<StudentLocation> = []
            for anyResult in results {
                let result = anyResult as! Dictionary<String, AnyObject>
                if result.isEmpty {
                    continue
                }
                
                locations.append(StudentLocation(map: result))
            }
            
            // Run call back if one was provided
            if onComplete != nil {
                onComplete(locations: locations)
            }
        })
    }

}