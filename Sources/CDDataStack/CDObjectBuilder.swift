//
//  File.swift
//  
//
//  Created by Sean Erickson on 2/14/24.
//

import Foundation
import CoreData
import ObjC

enum CDType {
    case int
    case string
    case bool
    case double
    case float
    case cdmodel
    case none
}

final class CDObjectBuilder {
    
    static let restrictedKeys = [
        ""
    ]
    
    static func setValues(for object: NSManagedObject) {
        let mirror = Mirror(reflecting: object)
        mirror.children.forEach { child in
            if let key = child.label {
                setObjectValue(object: object, value: child.value, forKey: key)
            }
        }
    }
    
    @discardableResult
    private static func setObjectValue(object: NSManagedObject, value: Any, forKey key: String) -> Bool {
        do {
            try ObjC.catchNSException {
                object.setValue(value, forKey: key)
            }
        } catch {
            print("found error: \(error)")
            do {
                let newKey = "cdStackLabel_" + key
                try ObjC.catchNSException {
                    object.setValue(value, forKey: newKey)
                }
            } catch {
                return false
            }
        }
        
        return true
    }
    
    private static func cdType(of obj: Any) -> CDType {
        switch obj {
        case is String:
            return .string
        case is Int:
            return .int
        case is Bool:
            return .bool
        case is Double:
            return .double
        case is Float:
            return .float
        case is CDDataModel<NSManagedObject>:
            return .cdmodel
        default:
            return .none
        }
    }
    
    private func isRestricted(key: String) -> Bool {
        
        return false
    }
}

extension CDObjectBuilder {
    
    @discardableResult
    public static func build<T: NSManagedObject>(from object: CDDataModel<T>, context: NSManagedObjectContext) -> T? {
        let desc = T.entity()
        let model = NSManagedObject(entity: desc, insertInto: context)
        let mirror = Mirror(reflecting: object)
        mirror.children.forEach { child in
            if let key = child.label {
                setObjectValue(object: model, value: child.value, forKey: key)
            }
        }
        
        do {
            try context.save()
        } catch {
            return nil
        }
        return model as? T
    }
    
//    @available(iOS 15.0, *)
//    public static func load<T: CDDataModel<NSManagedObject>>(entityName: String, context: NSManagedObjectContext) -> [T]? {
//        do {
//            let request = try context.fetch(NSFetchRequest(entityName: entityName))
//            guard let entities = request as? [T.] else {
//                print("Fetch failure")
//                return nil
//            }
//            var newObjects: [T] = []
//            for entity in entities {
//                let mirror = Mirror(reflecting: entity)
//                var keyDict = [String: Any]()
//                for case let (label?, value) in mirror.children { keyDict[label] = value }
//                let object = T.init()
//                try ObjC.catchNSException {
//                    object.setValuesForKeys(keyDict)
//                }
//                newObjects.append(object)
//            }
//
//            return newObjects
//        } catch {
//            return nil
//        }
//    }
}
