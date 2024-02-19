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
    private var viewContext: NSManagedObjectContext? { CDDataStack.shared.container.viewContext }
    required override init() {}
}


extension CDDataModel {
    
    @discardableResult
    final public func save() -> Model? {
        guard let context = self.viewContext else {
            print("view context not setup.")
            return nil
        }
        return self.save(context: context)
    }
    
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

// MARK - Add Custom Entity to CDDataStack model
extension CDDataModel {
    func addToModel(model: NSManagedObjectModel) -> NSManagedObjectModel {
        let modelCopy = model
        let entity = NSEntityDescription()
        let mirror = Mirror(reflecting: self)
        for case let (label?, value) in mirror.children {
            let attribute = NSAttributeDescription()
            attribute.name = label
            
            attribute.defaultValue = value
            attribute.isOptional = false
            attribute.allowsExternalBinaryDataStorage = false
            switch value {
            case is String:
                attribute.attributeType = .stringAttributeType
                if #available(iOS 15.0, *) {
                    attribute.type = .string
                }
            case is Int:
                attribute.attributeType = .integer16AttributeType
                if #available(iOS 15.0, *) {
                    attribute.type = .integer16
                }
            case is Bool:
                attribute.attributeType = .booleanAttributeType
                if #available(iOS 15.0, *) {
                    attribute.type = .boolean
                }
            default:
                break
            }
            entity.name = "MyEntity"
            entity.properties.append(attribute)
        }
        model.entities = [entity]
        return model
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
