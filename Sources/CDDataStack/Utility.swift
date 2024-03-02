//
//  File.swift
//  
//
//  Created by Sean Erickson on 3/2/24.
//

import Foundation
import CoreData

@available(iOS 16.4, *)
extension CDDataStack {
    
    /// Setup An object, assuming all keypaths and properties have already been set for the entity description
    static func setupClassObject(object: NSObject, entity: NSEntityDescription) {
        guard let name = entity.name else {
            print("Invalid Entity!")
            return
        }
        if shared.weakReferences.member(object) == nil {
            shared.weakReferences.add(object)
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        request.entity = entity
        request.fetchLimit = 1
        
        if let request = try? shared.container?.viewContext.fetch(request) {
            if request.count == 0 {
                // Object does not exist in CD, set values for Entity
                let obj = NSManagedObject(entity: entity, insertInto: shared.container?.viewContext)
                let keyedValues = Array<String>(entity.propertiesByName.keys)
                for key in keyedValues {
                    if let value = object.safeValue(forKey: key.asKey) {
                        obj.safeSetValue(value, forKey: key)
                    }
                }
                do {
                    try shared.container?.viewContext.save()
                } catch {
                    print("failed to save new entity")
                }
            } else if request.count == 1 {
                // Object exists in CD, set values for class
                if let obj = (request as? [NSManagedObject])?.first {
                    // TODO: Set Swift Object values from obj assuming entity is setup
                    let keyedValues = Array<String>(entity.propertiesByName.keys)
                    for key in keyedValues {
                        object.safeSetValue(obj.value(forKey: key), forKey: key.asKey)
                    }
                    for (key, relationship) in entity.relationshipsByName {
                        guard let entityToFetch = relationship.destinationEntity, let entityName = entityToFetch.name else {
                            continue
                        }
                        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                        request.entity = entityToFetch
                        request.fetchLimit = 1
                        if let request = try? shared.container?.viewContext.fetch(request) {
                            if request.count == 1 {
                                print("es")
                            }
                        }
                    }
                }
            } else {
                fatalError("Unexpected amount of entities!")
            }
        }
    }
    
    static func setupAttributes(currentEntity: NSEntityDescription,
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
            if let value = value as? AutoSave<String> {
                attribute.attributeType = .stringAttributeType
                attribute.type = .string
                attribute.defaultValue = value.storage as Any
                keyPaths[label] = value.storage
            } else if let value = value as? AutoSave<Int> {
                attribute.attributeType = .integer16AttributeType
                attribute.type = .integer16
                attribute.defaultValue = value.storage as Any
                keyPaths[label] = value.storage
            } else if let value = value as? AutoSave<Bool> {
                attribute.attributeType = .booleanAttributeType
                attribute.type = .boolean
                attribute.defaultValue = value.storage as Any
                keyPaths[label] = value.storage
            } else if let value = value as? AutoSave<Float> {
                attribute.attributeType = .floatAttributeType
                attribute.type = .float
                attribute.defaultValue = value.storage as Any
                keyPaths[label] = value.storage
            } else if let value = value as? AutoSave<Double> {
                attribute.attributeType = .doubleAttributeType
                attribute.type = .double
                attribute.defaultValue = value.storage as Any
                keyPaths[label] = value.storage
            } else if let value = value as? AutoSave<Date> {
                attribute.attributeType = .dateAttributeType
                attribute.type = .date
                attribute.defaultValue = value.storage as Any
                keyPaths[label] = value.storage
            } else if let value = value as? AutoSave<Data> {
                attribute.attributeType = .binaryDataAttributeType
                attribute.type = .binaryData
                attribute.defaultValue = value.storage as Any
                keyPaths[label] = value.storage
                // todo: Add array support
            } else if let value = value as? (any AutoSaveProtocol) {
                // Handle unknown object
                // TODO: - Array and dictionary Management, need to separate
                if let storage = value.storage as? NestedModel {
                    let mirror = Mirror(reflecting: storage)
                    // make a new entity for the auto struct
                    let newEntity = setupRelationship(for: storage, currentEntity: currentEntity, label: label)
                    entityList.append(newEntity)
                    for case let (key?, value) in mirror.children {
                        CDDataStack.setupAttributes(currentEntity: newEntity, entityList: &entityList, label: key, value: value, keyPaths: &keyPaths, isPrimitive: false)
                    }
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
            } else if let value = value as? (any AutoSaveProtocol) {
                //CDDataStack.setupStruct(for: value)
                print("fuck its nested")
                return
            } else {
                return
            }
            currentEntity.properties.append(attribute)
        }
    }
    
    static func setupRelationship<T: Any>(for object: T, currentEntity: NSEntityDescription, label: String) -> NSEntityDescription {
        let name = String(describing: type(of: object))
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
        
        return newEntity
    }
}
