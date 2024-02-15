//
//  File.swift
//
//
//  Created by Sean Erickson on 2/14/24.
//

import CoreData
import ObjC

@objcMembers
public class CDDataModel<Model: NSManagedObject>: NSObject {
    typealias CDModel = Model
    required override init() {}
}


extension CDDataModel {
    
    @discardableResult
    final public func save(context: NSManagedObjectContext) -> Model? {
        let desc = Model.entity()
        let model = Model(entity: desc, insertInto: context)
        let mirror = Mirror(reflecting: self)
        mirror.children.forEach { child in
            if let key = child.label {
                CDDataModel<Model>.setObjectValue(object: model, value: child.value, forKey: key)
            }
        }
        do {
            try context.save()
        } catch {
            return nil
        }
        return model
    }
}

extension CDDataModel {
    
    @available(iOS 15.0, *)
    static func load(context: NSManagedObjectContext) -> [CDDataModel<Model>]? {
        do {
            guard let entityName = Model.entity().name else { return nil }
            let request = try context.fetch(NSFetchRequest(entityName: entityName))
            guard let entities = request as? [CDModel] else {
                print("Fetch failure")
                return nil
            }
            var newObjects: [Self] = []
            for entity in entities {
                let object = Self.init()
                let attributeArr = entity.entity.attributesByName.compactMap {
                    if let value = entity.value(forKey: $0.key) { return ($0.key, value) }
                    return nil
                }
                do {
                    try ObjC.catchNSException {
                        object.setValuesForKeys(Dictionary(uniqueKeysWithValues: attributeArr))
                    }
                } catch {
                    print(error)
                    continue
                }
                
                newObjects.append(object)
            }
            return newObjects
        } catch {
            print(error)
            return nil
        }
    }
}

extension CDDataModel {
    
    @discardableResult
    internal static func setObjectValue(object: NSManagedObject, value: Any, forKey key: String) -> Bool {
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
}
