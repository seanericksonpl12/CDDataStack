//
//  CDDataStack+EntityBuilding.swift
//
//
//  Created by Sean Erickson on 2/15/24.
//

import CoreData
import ObjC

extension CDDataStack {
    public static func buildModel() -> NSManagedObjectModel? {
        guard let url = Bundle.module.url(forResource: containerName, withExtension: "momd") else { fatalError("Could not get URL for model") }
        let newModel = NSManagedObjectModel(contentsOf: url)
        return newModel
    }
}

internal
extension CDDataStack {
    
    @available(iOS 16.4, *)
    static func saveEntity<T: CDAutoModel, Value: Any>(name: String,
                                                       for object: CDAutoModel,
                                                       keyPath: ReferenceWritableKeyPath<T, AutoSave<Value>>,
                                                       value: Value) {
        let request = try? shared.container.viewContext.fetch(NSFetchRequest(entityName: name)), arr = request as? [NSManagedObject]
        guard arr?.count == 1 else {
            print("Found more objects than expected!")
            return
        }
        guard let entity = arr?.first else {
            return
        }
        let keypath = String(describing: keyPath)
        let paths = keypath.split(separator: ".")
        entity.setValue(value, forKey: String(paths.last!))
        do {
            try shared.container.viewContext.save()
        } catch {
            print("ERROR SAVING")
        }
    }
}

internal
extension CDDataStack {
    @available(iOS 16.4, *)
    static func declareEntity<T: CDAutoModel>(for object: T, resettingOnInit: Bool = false) {
        // TODO: Check for existing data, migrate if need to add a new entity type (in the future), set existing objValues from existing data
        guard let url = Bundle.module.url(forResource: containerName, withExtension: "momd") else { fatalError("Could not get URL for model") }
        guard let model = NSManagedObjectModel(contentsOf: url) else { fatalError("Could not get model for: \(url)") }
        
        let name = String(describing: type(of: object))
        let entity = NSEntityDescription()
        entity.name = name
        let mirror = Mirror(reflecting: object)
        var keypaths = [String: Any]()
        var entities = [entity]
        for case let (label?, mirrorValue) in mirror.children {
            CDDataStack.setupAttributes(currentEntity: entity, entityList: &entities, label: label, value: mirrorValue, keyPaths: &keypaths)
        }
        
        model.entities = entities
        
        // Set up a new container whenever a new object is initialized because fuck you thats why
        let container = NSPersistentContainer(name: "CDBaseContainer", managedObjectModel: model)
        shared.container = container
        shared.container.viewContext.retainsRegisteredObjects = true
        shared.container.loadPersistentStores(completionHandler: { (desc, err) in
            if let err = err {
                fatalError("Error loading TEMPORARY STORE: \(desc): \(err)")
            }
        })
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        request.entity = entity
        request.fetchLimit = 1
        
        if let request = try? shared.container.viewContext.fetch(request) {
            if request.count == 0 {
                do {
                    let obj = NSManagedObject(entity: entity, insertInto: shared.container.viewContext)
                    obj.setValuesForKeys(keypaths)
                    try shared.container.viewContext.save()
                } catch {
                    print("FAILED TO SAVE")
                }
            } else if request.count == 1 {
                if let obj = (request as? [NSManagedObject])?.first {
                    // TODO: Set Swift Object values from obj
                    for (key, _) in keypaths {
                        do { try ObjC.catchNSException {
                            let value = obj.value(forKey: key)
                            object.setValue(value, forKey: key.asKey)
                        }} catch {
                            print("key setting failing.  Attempting again with unchanged key")
                            do { try ObjC.catchNSException {
                                let value = obj.value(forKey: key)
                                object.setValue(value, forKey: key)
                            }} catch {
                                continue
                            }
                        }
                    }
                }
            }
        }
    }
}

extension CDDataStack {
    
    @available(iOS 16.4, *)
    private static func setupAttributes(currentEntity: NSEntityDescription,
                                        entityList: inout [NSEntityDescription],
                                        label: String,
                                        value: Any,
                                        keyPaths: inout [String: Any],
                                        isPrimitive: Bool = true) {
        if isPrimitive {
            let attribute = NSAttributeDescription()
            attribute.name = label
            attribute.isOptional = false
            attribute.allowsExternalBinaryDataStorage = false
            if value.self is AutoSave<Any>.Type{
                print("ahdisdfd")
            }
            if let value = value as? AutoSave<String> {
                attribute.attributeType = .stringAttributeType
                attribute.type = .string
                attribute.defaultValue = value.storage as Any
                keyPaths[label] = value.storage
                // object.setValue(value.storage, forKey: key)
            } else if let value = value as? AutoSave<Int> {
                attribute.attributeType = .integer16AttributeType
                attribute.type = .integer16
                attribute.defaultValue = value.storage as Any
                keyPaths[label] = value.storage
                //  object.setValue(value.storage, forKey: key)
            } else if let value = value as? AutoSave<Bool> {
                attribute.attributeType = .booleanAttributeType
                attribute.type = .boolean
                attribute.defaultValue = value.storage as Any
                keyPaths[label] = value.storage
                //  object.setValue(value.storage, forKey: key)
            } else if let value = value as? AutoSave<Float> {
                attribute.attributeType = .floatAttributeType
                attribute.type = .float
                attribute.defaultValue = value.storage as Any
                keyPaths[label] = value.storage
                //  object.setValue(value.storage, forKey: key)
            } else if let value = value as? AutoSave<Double> {
                attribute.attributeType = .doubleAttributeType
                attribute.type = .double
                attribute.defaultValue = value.storage as Any
                keyPaths[label] = value.storage
                //  object.setValue(value.storage, forKey: key)
            } else if let value = value as? AutoSave<Date> {
                attribute.attributeType = .dateAttributeType
                attribute.type = .date
                attribute.defaultValue = value.storage as Any
                keyPaths[label] = value.storage
                //  object.setValue(value.storage, forKey: key)
            } else if let value = value as? AutoSave<Data> {
                attribute.attributeType = .binaryDataAttributeType
                attribute.type = .binaryData
                attribute.defaultValue = value.storage as Any
                keyPaths[label] = value.storage
                //  object.setValue(value.storage, forKey: key)
            } else if let value = value.self as? AutoSave<AutoStruct> {
                let mirror = Mirror(reflecting: value.storage)
                // make a new entity for the auto struct
                let name = String(describing: type(of: value.storage))
                let newEntity = NSEntityDescription()
                newEntity.name = name
                // make relationships
                let relationship = NSRelationshipDescription()
                let inverse = NSRelationshipDescription()
                relationship.name = "test_relationship"
                relationship.destinationEntity = newEntity
                relationship.minCount = 0
                relationship.maxCount = 1
                relationship.deleteRule = .nullifyDeleteRule
                relationship.inverseRelationship = inverse
                
                inverse.name = "test_inverse"
                inverse.destinationEntity = currentEntity
                inverse.minCount = 0
                inverse.maxCount = 1
                inverse.deleteRule = .nullifyDeleteRule
                inverse.inverseRelationship = relationship
                currentEntity.properties.append(relationship)
                newEntity.properties.append(inverse)
                
                entityList.append(newEntity)
                
                for case let (key?, value) in mirror.children {
                    CDDataStack.setupAttributes(currentEntity: newEntity, entityList: &entityList, label: key, value: value, keyPaths: &keyPaths, isPrimitive: false)
                }
                return
            } else {
                return
            }
            currentEntity.properties.append(attribute)
        } else {
            print(label)
            let attribute = NSAttributeDescription()
            attribute.name = label
            attribute.isOptional = false
            attribute.allowsExternalBinaryDataStorage = false
            if let value = value as? String {
                attribute.attributeType = .stringAttributeType
                attribute.type = .string
                attribute.defaultValue = value
            } else if let value = value as? Int {
                attribute.attributeType = .integer16AttributeType
                attribute.type = .integer16
                attribute.defaultValue = value
            } else if let value = value as? Bool {
                attribute.attributeType = .booleanAttributeType
                attribute.type = .boolean
                attribute.defaultValue = value
            } else if let value = value as? Float {
                attribute.attributeType = .floatAttributeType
                attribute.type = .float
                attribute.defaultValue = value
            } else if let value = value as? Double {
                attribute.attributeType = .doubleAttributeType
                attribute.type = .double
                attribute.defaultValue = value
            } else if let value = value as? Date {
                attribute.attributeType = .dateAttributeType
                attribute.type = .date
                attribute.defaultValue = value
            } else if let value = value as? Data {
                attribute.attributeType = .binaryDataAttributeType
                attribute.type = .binaryData
                attribute.defaultValue = value
            } else if let value = value.self as? AutoStruct {
                //CDDataStack.setupStruct(for: value)
                print("fuck its nested")
                return
            } else {
                return
            }
            currentEntity.properties.append(attribute)
        }
    }
}
