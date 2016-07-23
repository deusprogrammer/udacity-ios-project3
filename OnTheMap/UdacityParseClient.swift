//
//  UdacityParseClient.swift
//  ParseClient
//
//  Created by Michael Main on 7/19/16.
//  Copyright © 2016 Michael Main. All rights reserved.
//

import Foundation

class JSONHelper {
    class func serialize(obj: AnyObject) -> String! {
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(obj, options: .PrettyPrinted)
            return NSString(data: jsonData, encoding: NSUTF8StringEncoding) as String!
        } catch {
            return nil
        }
    }
    
    class func search(path: String, object: Any) -> Any! {
        let pathComponents : Array<String> = path.componentsSeparatedByString("/")
        var currentNode : Any = object
        
        for pathComponent in pathComponents {
            if (pathComponent.isEmpty) {
                continue
            }
            
            let indexStart = pathComponent.characters.indexOf("[")
            let indexEnd   = pathComponent.characters.indexOf("]")
            
            if (indexStart != nil && indexEnd != nil) {
                let pathComponentName = pathComponent.substringToIndex(indexStart!)
                let pathComponentIndex = pathComponent.substringWithRange((indexStart!.advancedBy(1)..<indexEnd!))
                
                if (!pathComponentName.isEmpty) {
                    // Go to dictionary entry
                    if (!(currentNode is Dictionary<String, AnyObject>)) {
                        return nil
                    }
                    
                    
                    let d = currentNode as! Dictionary<String, AnyObject>
                    currentNode = d[pathComponentName]
                }
                
                
                // Go to array element
                if (!(currentNode is Array<Any>)) {
                    return nil
                }
                
                let a = currentNode as! Array<Any>
                currentNode = a[(pathComponentIndex as NSString).integerValue]
            } else {
                // Go to dictionary entry
                if (!(currentNode is Dictionary<String, AnyObject>)) {
                    return nil
                }
                
                let d = currentNode as! Dictionary<String, AnyObject>
                currentNode = d[pathComponent]
            }
        }
        
        return currentNode
    }
}

// A class for containing student locations
class StudentLocation {
    var uniqueKey : String!
    var objectId  : String!
    var firstName : String!
    var lastName : String!
    var mediaUrl : String!
    var mapString : String!
    var longtitude : Double!
    var latitude : Double!
    var updatedAt : String!
    
    // Serialize this object into a Dictionary
    func serialize() -> Dictionary<String, AnyObject> {
        return [
            "uniqueKey" : self.uniqueKey,
            "firstName" : self.firstName,
            "lastName"  : self.lastName,
            "mediaURL"  : self.mediaUrl,
            "mapString" : self.mapString,
            "latitude"  : self.latitude,
            "longitude" : self.longtitude,
            "updatedAt" : self.updatedAt
        ]
    }
    
    // Deserialize supplied map into this object
    func deserialize(map: Dictionary<String, AnyObject>) {
        self.objectId   = map["objectId"]  as! String
        self.uniqueKey  = map["uniqueKey"] as! String
        self.firstName  = map["firstName"] as! String
        self.lastName   = map["lastName"]  as! String
        self.mediaUrl   = map["mediaURL"]  as! String
        self.mapString  = map["mapString"] as! String
        self.latitude   = map["latitude"]  as! Double
        self.longtitude = map["longitude"] as! Double
        self.updatedAt  = map["updatedAt"] as! String
    }
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
            
            // Deserialize json
            var data : AnyObject! = nil
            do {
                try data = NSJSONSerialization.JSONObjectWithData(response.body.subdataWithRange(NSRange(location: 4, length: response.body.length - 4)), options: .AllowFragments)
            } catch {
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
            
            // Deserialize json
            var data : AnyObject! = nil
            do {
                try data = NSJSONSerialization.JSONObjectWithData(response.body.subdataWithRange(NSRange(location: 4, length: response.body.length - 4)), options: .AllowFragments)
            } catch {
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
            
            // Deserialize json
            var data : AnyObject! = nil
            do {
                try data = NSJSONSerialization.JSONObjectWithData(response.body.subdataWithRange(NSRange(location: 4, length: response.body.length - 4)), options: .AllowFragments)
            } catch {
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
            
            // Deserialize json
            var data : AnyObject! = nil
            do {
                try data = NSJSONSerialization.JSONObjectWithData(response.body, options: .AllowFragments)
            } catch {
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
            
            // Deserialize json
            var data : AnyObject! = nil
            do {
                try data = NSJSONSerialization.JSONObjectWithData(response.body, options: .AllowFragments)
            } catch {
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
                        payload: data
                    )
                }
                return
            }
            
            // Parse result and update location object with object id
            var result = data as! Dictionary<String, AnyObject>
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
            
            // Deserialize json
            var data : AnyObject! = nil
            do {
                try data = NSJSONSerialization.JSONObjectWithData(response.body, options: .AllowFragments)
            } catch {
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
            
            let location = StudentLocation()
            location.deserialize(results[0] as! Dictionary<String, AnyObject>)
            
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
            
            // Deserialize json
            var data : AnyObject! = nil
            do {
                try data = NSJSONSerialization.JSONObjectWithData(response.body, options: .AllowFragments)
            } catch {
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
                        payload: data
                    )
                }
                return
            }
            
            // Acquire the results from the results key at the root of the returned object
            let results = JSONHelper.search("/results", object: data) as! Array<AnyObject>
            
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
                let result = anyResult as! Dictionary<String, AnyObject>
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