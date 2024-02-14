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

class CDObjectBuilder {
    
    static let restrictedKeys = [
        ""
    ]
    
    private var mirror: Mirror
    
    init(object: Any) {
        self.mirror = Mirror(reflecting: object)
        let obj = NSManagedObject()
    }
    
    func setValues(for object: NSManagedObject) {
        mirror.children.forEach { child in
            switch cdType(of: child) {
            case .int, .double, .float, .bool:
                if let label = child.label {
                    object.setValue(child.value, forKey: label)
                }
            case .string:
                <#code#>
            case .cdmodel:
                <#code#>
            case .none:
                <#code#>
            }
        }
    }
    
    func setObjectValue(object: NSManagedObject, value: Any, forKey key: String) -> Bool {
        do {
            try ObjC.catchNSException {
                object.setValue(value, forKey: key)
            }
        } catch {
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
    
    func cdType(of obj: Any) -> CDType {
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
        case is any CDDataModel:
            return .cdmodel
        default:
            return .none
        }
    }
    
    private func isRestricted(key: String) -> Bool {
        
        return false
    }
}
