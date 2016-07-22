//
//  main.swift
//  JSON Parser v 0.1a
//
//  Created by Michael Main on 4/17/15.
//  Copyright (c) 2015 Michael Main. All rights reserved.
//
//  Change log
//  Michael Main | 04/21/2015 | Initial classes done- need to implement non string values

import Foundation

// Borrowed from http://benscheirman.com/2014/06/regex-in-swift/
// TODO Replace this later
class Regex {
    var internalExpression: NSRegularExpression?
    
    init(_ pattern: String) {
        self.internalExpression = nil
        do {
            self.internalExpression = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression!.matchesInString(input, options: [], range:NSMakeRange(0, input.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)))
        return matches.count > 0
    }
}

// Needed to keep track of blob depth
struct Stack<T> {
    var items = [T]()
    mutating func push(item: T) {
        items.append(item)
    }
    mutating func pop() -> T {
        let item : T = items.removeLast()
        return item
    }
    func peek() -> T {
        return items.last!
    }
    func isEmpty() -> Bool {
        return items.count == 0
    }
    
    func displayStack() -> String {
        var s = ""
        var seperator = ""
        for item in items {
            s = "\(s)\(seperator)\(item)"
            seperator = ","
        }
        
        return s
    }
}

protocol NBObjectMapper {
    func serialize(object:Any) -> String
    func deserialize(str:String) -> Any
}

protocol NBMappable {
    func serialize() -> Dictionary<String, Any>
    func deserialize(map: Dictionary<String, Any>)
}

// A JSON parser that uses the default String type in Swift
class NBJSON {
    enum JsonType {
        case NONE
        case NULL
        case OBJECT
        case LIST
        case STRING
        case INT
        case FLOAT
        case BOOL
    }
    
    enum ParserState {
        case INIT
        case READING_KEY
        case SEARCHING_NEXT
        case SEARCHING_SEPERATOR
        case SEARCHING_VALUE
        case READING_STRING_VALUE
        case READING_NON_STRING_VALUE
        case READING_OBJECT_VALUE
        case READING_LIST_VALUE
    }
    
    class Marshaller {
        
    }
    
    class Demarshaller {
        
    }
    
    class NBOJSONbjectMapper : NBObjectMapper {
        func deserialize(str: String) -> Any {
            return Parser.deserialize(str)
        }
        
        func serialize(object: Any) -> String {
            return Parser.serialize(object)
        }
    }
    
    class Parser {
        class func serialize(object: Any) -> String {
            if (object is Dictionary<String, Any>) {
                return serialize(object as! Dictionary<String, Any>)
            } else if (object is Array<Any>) {
                return serialize(object as! Array<Any>)
            } else {
                return ""
            }
        }
        
        private class func serialize(dictionary : Dictionary<String, Any>) -> String {
            var jsonString : String;
            var seperator : String = ""
            
            jsonString = "{";
            for (key, value) in dictionary {
                if (value is Array<Any>) {
                    jsonString += "\(seperator)\"\(key)\":\(serialize(value as! Array<Any>))"
                } else if (value is Dictionary<String, Any>) {
                    jsonString += "\(seperator)\"\(key)\":\(serialize(value as! Dictionary<String, Any>))"
                } else if (value is String) {
                    jsonString += "\(seperator)\"\(key)\":\"\(value)\""
                } else if (value is Int || value is Float || value is Double) {
                    jsonString += "\(seperator)\"\(key)\":\(value)"
                } else if (value is Bool) {
                    let boolValue = (value as! Bool) ? "true" : "false"
                    jsonString += "\(seperator)\"\(key)\":\(boolValue)"
                }
                seperator = ","
            }
            jsonString += "}"
            
            return jsonString
        }
        
        private class func serialize(list : Array<Any>) -> String {
            var jsonString : String;
            var seperator : String = ""
            
            jsonString = "[";
            for value in list {
                if (value is Array<Any>) {
                    jsonString += "\(seperator)\(serialize(value as! Array<Any>))"
                } else if (value is Dictionary<String, Any>) {
                    jsonString += "\(seperator)\(serialize(value as! Dictionary<String, Any>))"
                } else if (value is String) {
                    jsonString += "\(seperator)\"\(value)\""
                } else if (value is Int || value is Float || value is Double) {
                    jsonString += "\(seperator)\(value)"
                } else if (value is Bool) {
                    let boolValue = (value as! Bool) ? "true" : "false"
                    jsonString += "\(seperator)\(boolValue)"
                }
                seperator = ","
            }
            jsonString += "]"
            
            return jsonString
        }
        
        class func serialize(object: NBMappable) -> String {
            return serialize(object.serialize())
        }
        
        class func serialize(list: Array<NBMappable>) -> String {
            var array : Array<Any> = Array<Any>()
            for mappable in list {
                array.append(mappable.serialize())
            }
            
            return serialize(array)
        }
        
        class func deserialize(jsonString : String) -> Any? {
            let jsonStringArray : Array<Character> = Array(jsonString.characters)
            var index : Int
            var expression : Array<Character>
            var type : JsonType
            
            (index, expression, type) = extractJsonExpression(jsonString: jsonStringArray)
            
            if (type == JsonType.OBJECT) {
                return parseJsonObject(expression)
            } else if (type == JsonType.LIST) {
                return parseJsonList(expression)
            }
            
            return nil
        }
        
        class func deserialize(jsonString: String, deserializeInto: NBMappable) -> NBMappable? {
            let object : Any = deserialize(jsonString)
            
            if (object is Dictionary<String, Any>) {
                deserializeInto.deserialize(object as! Dictionary<String, Any>)
                return deserializeInto
            } else {
                return nil
            }
        }
        
        private class func parseJsonList(jsonString : Array<Character>) -> Array<Any> {
            var type : JsonType
            var list  : Array<Any> = Array()
            var state : ParserState = ParserState.INIT
            var value : String = ""
            var index : Int
            var expression : Array<Character>
            
            for var i = 0; i < jsonString.count; i += 1 {
                var c = jsonString[i]
                
                switch (state) {
                case .INIT:
                    if (c == "\"") {
                        state = ParserState.READING_STRING_VALUE
                    } else if (c == "{") {
                        (index, expression, type) = extractJsonExpression(jsonString: jsonString, startIndex: i)
                        i = index
                        list.append(parseJsonObject(expression))
                        value = ""
                        state = ParserState.SEARCHING_NEXT
                    } else if (c == "[") {
                        (index, expression, type) = extractJsonExpression(jsonString: jsonString, startIndex: i)
                        i = index
                        list.append(parseJsonList(expression))
                        value = ""
                        state = ParserState.SEARCHING_NEXT
                    } else if (c != " " && c != "\t") {
                        value.append(c)
                        state = ParserState.READING_NON_STRING_VALUE
                    }
                    break
                case .READING_STRING_VALUE:
                    if (c == "\"") {
                        list.append(value)
                        value = ""
                        state = ParserState.SEARCHING_NEXT
                        continue
                    }
                    value.append(c)
                    break
                case .READING_NON_STRING_VALUE:
                    if (i == jsonString.count - 1) {
                        value.append(c)
                        c = ","
                    }
                    
                    if (c == ",") {
                        let type = determineType(String(value).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
                        switch (type) {
                        case .INT:
                            list.append((value as NSString).integerValue)
                            break
                        case .FLOAT:
                            list.append((value as NSString).doubleValue)
                            break
                        case .BOOL:
                            list.append((value as NSString).boolValue)
                            break
                        case .STRING:
                            list.append(value)
                            break
                        case .NULL:
                            list.append(value)
                            break
                        default:
                            return Array()
                        }
                        
                        value = ""
                        state = ParserState.INIT
                        continue
                    }
                    value.append(c)
                    break
                case .SEARCHING_NEXT:
                    if (c == "," ) {
                        state = ParserState.INIT
                    }
                    break
                default:
                    break
                }
            }
            
            return list
        }
        
        private class func parseJsonObject(jsonString : Array<Character>) -> Dictionary<String, Any> {
            var type : JsonType
            var object : Dictionary<String, Any> = Dictionary()
            var state : ParserState = ParserState.INIT
            var key : String = ""
            var value : String = ""
            var index : Int
            var expression : Array<Character>
            
            for var i = 0; i < jsonString.count; i += 1 {
                var c = jsonString[i]
                
                switch (state) {
                case .INIT:
                    if (c == "\"") {
                        state = ParserState.READING_KEY
                    }
                    break
                case .READING_KEY:
                    if (c == "\"") {
                        state = ParserState.SEARCHING_SEPERATOR
                        continue
                    }
                    key.append(c)
                    break
                case .SEARCHING_SEPERATOR:
                    if (c == ":") {
                        state = ParserState.SEARCHING_VALUE
                    }
                    break
                case .SEARCHING_NEXT:
                    if (c == ",") {
                        state = ParserState.INIT
                    }
                    break
                case .SEARCHING_VALUE:
                    if (c == "\"") {
                        state = ParserState.READING_STRING_VALUE
                    } else if (c == "{") {
                        (index, expression, type) = extractJsonExpression(jsonString: jsonString, startIndex: i)
                        i = index
                        let obj = parseJsonObject(expression)
                        object[key] = obj
                        key = ""
                        value = ""
                        state = ParserState.SEARCHING_NEXT
                    } else if (c == "[") {
                        (index, expression, type) = extractJsonExpression(jsonString: jsonString, startIndex: i)
                        i = index
                        let list = parseJsonList(expression)
                        object[key] = list
                        key = ""
                        value = ""
                        state = ParserState.SEARCHING_NEXT
                    } else if (c != " " && c != "\t") {
                        value.append(c)
                        state = ParserState.READING_NON_STRING_VALUE
                    }
                    break
                case .READING_STRING_VALUE:
                    if (c == "\"") {
                        object[key] = value
                        key = ""
                        value = ""
                        state = ParserState.SEARCHING_NEXT
                        continue
                    }
                    value.append(c)
                    break
                case .READING_NON_STRING_VALUE:
                    if (i == jsonString.count - 1) {
                        value.append(c)
                        c = ","
                    }
                    
                    if (c == ",") {
                        let type = determineType(String(value).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
                        switch (type) {
                        case .INT:
                            object[key] = (value as NSString).integerValue
                            break
                        case .FLOAT:
                            object[key] = (value as NSString).doubleValue
                            break
                        case .BOOL:
                            object[key] = (value as NSString).boolValue
                            break
                        case .STRING:
                            object[key] = value
                            break
                        case .NULL:
                            object[key] = nil
                            break
                        default:
                            return Dictionary()
                        }
                        
                        // Store the value if valid
                        key = ""
                        value = ""
                        state = ParserState.INIT
                        continue
                    }
                    value.append(c)
                    break
                default:
                    break;
                }
            }
            
            return object
        }
        
        private class func extractJsonExpression(jsonString jsonString : Array<Character>, startIndex index : Int = 0) -> (Int, Array<Character>, JsonType) {
            var typeStack = Stack<String>()
            var jsonSubString = Array<Character>()
            var objectStarted = false
            var type : JsonType = JsonType.NONE;
            
            for i in index ..< jsonString.count {
                let c = jsonString[i]
                
                if (objectStarted) {
                    jsonSubString.append(c)
                }
                
                if (c == "{") {
                    if (!objectStarted) {
                        type = JsonType.OBJECT
                    }
                    typeStack.push("{")
                    objectStarted = true
                } else if (c == "}" && !typeStack.isEmpty() && typeStack.peek() == "{") {
                    typeStack.pop()
                } else if (c == "[") {
                    if (!objectStarted) {
                        type = JsonType.LIST
                    }
                    typeStack.push("[")
                    objectStarted = true
                } else if (c == "]" && !typeStack.isEmpty() && typeStack.peek() == "[") {
                    typeStack.pop()
                } else if (c == "\"") {
                    if (typeStack.peek() == "\"") {
                        typeStack.pop()
                    } else {
                        if (!objectStarted) {
                            type = JsonType.STRING
                        }
                        typeStack.push("\"")
                        objectStarted = true
                    }
                }
                
                if (objectStarted && typeStack.isEmpty()) {
                    jsonSubString.removeLast()
                    return (i, jsonSubString, type)
                }
            }
            
            return (-1, Array(), JsonType.NONE)
        }
        
        private class func determineType(value: String) -> JsonType {
            let intRegex = "^[0-9-]+$"
            let floatRegex = "^[0-9-]+\\.+[0-9]+$"
            let boolRegex = "^(true|false)$"
            let nullRegex = "^null$"
            let stringRegex = "^\".*\"$"
            
            if (Regex(floatRegex).test(value)) {
                return JsonType.FLOAT
            } else if (Regex(intRegex).test(value)) {
                return JsonType.INT
            } else if (Regex(boolRegex).test(value)) {
                return JsonType.BOOL
            } else if (Regex(stringRegex).test(value)) {
                return JsonType.STRING
            } else if (Regex(nullRegex).test(value)) {
                return JsonType.NULL
            } else {
                return JsonType.NONE
            }
        }
    }
    
    class Utils {
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
                        if (!(currentNode is Dictionary<String, Any>)) {
                            return nil
                        }
                    
                    
                        let d = currentNode as! Dictionary<String, Any>
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
                    if (!(currentNode is Dictionary<String, Any>)) {
                        return nil
                    }
                    
                    let d = currentNode as! Dictionary<String, Any>
                    currentNode = d[pathComponent]
                }
            }
            
            return currentNode
        }
        
        class func printObject(object: Any, printTabs: Int = 0) {
            if (object is Dictionary<String, Any>) {
                printMap(object: object as! Dictionary<String, Any>, printTabs: printTabs)
            } else if (object is Array<Any>) {
                printList(object: object as! Array<Any>, printTabs: printTabs)
            }
        }
        
        private class func printMap(object object: Dictionary<String, Any>, printTabs: Int = 0) {
            for (key, value) in object {
                tabs(printTabs)
                print("\(key) => ", terminator:"")
                if (value is Array<Any>) {
                    print()
                    printList(object: value as! Array<Any>, printTabs: printTabs + 1)
                } else if (value is Dictionary<String, Any>) {
                    print()
                    printMap(object: value as! Dictionary<String, Any>, printTabs: printTabs + 1)
                } else {
                    print(value)
                }
            }
        }
        
        private class func printList(object object: Array<Any>, printTabs: Int = 0) {
            for (index, value) in object.enumerate() {
                tabs(printTabs)
                print("[\(index)] => ", terminator:"")
                if (value is Array<Any>) {
                    print()
                    printList(object: value as! Array<Any>, printTabs: printTabs + 1)
                } else if (value is Dictionary<String, Any>) {
                    print()
                    printMap(object: value as! Dictionary<String, Any>, printTabs: printTabs + 1)
                } else {
                    print(value)
                }
            }
        }
        
        private class func tabs(amount: Int) {
            for _ in 0 ..< amount {
                print("\t", terminator:"")
            }
        }
    }
}

