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
       // if shared?.container.managedObjectModel.entitiesByName[name] != nil {
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
        print(model.entities)
        let name = String(describing: type(of: object))
        let entity = NSEntityDescription()
        entity.name = name
        let mirror = Mirror(reflecting: object)
        var keypaths = [String: Any]()
        for case let (label?, mirrorValue) in mirror.children {
            var key = label
            if key.starts(with: "_") {
                key.removeFirst()
            }
            let attribute = NSAttributeDescription()
            attribute.name = label
            attribute.isOptional = false
            attribute.allowsExternalBinaryDataStorage = false
            if let value = mirrorValue as? AutoSave<String> {
                attribute.attributeType = .stringAttributeType
                attribute.type = .string
                attribute.defaultValue = value.storage as Any
                keypaths[label] = value.storage
                object.setValue(value.storage, forKey: key)
            } else if let value = mirrorValue as? AutoSave<Int> {
                attribute.attributeType = .integer16AttributeType
                attribute.type = .integer16
                attribute.defaultValue = value.storage as Any
                keypaths[label] = value.storage
                object.setValue(value.storage, forKey: key)
            } else if let value = mirrorValue as? AutoSave<Bool> {
                attribute.attributeType = .booleanAttributeType
                attribute.type = .boolean
                attribute.defaultValue = value.storage as Any
                keypaths[label] = value.storage
                object.setValue(value.storage, forKey: key)
            }
            entity.properties.append(attribute)
        }
        
        model.entities = [entity]
        
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
                            // TODO: set values individually
                            print(error)
                            continue
                        }
                    }
                }
            }
        }
    }
}
