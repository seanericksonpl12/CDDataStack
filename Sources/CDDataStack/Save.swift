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
    
    static func saveEntity<T: CDAutoModel, Value: Any>(name: String,
                                                       for object: CDAutoModel,
                                                       keyPath: ReferenceWritableKeyPath<T, AutoSave<Value>>,
                                                       value: Value) {
        let request = try? shared.container?.viewContext.fetch(NSFetchRequest(entityName: name)), arr = request as? [NSManagedObject]
        guard arr?.count == 1 else {
            fatalError("Found multiple entities, only one per type currently supported.")
        }
        guard let entity = arr?.first else {
            return
        }
        // TODO: - Make safer keypath setting here, this is bad
        let keypath = String(describing: keyPath)
        let paths = keypath.split(separator: ".")
        guard let last = paths.last else { return }
        
        entity.safeSetValue(value, forKey: String(last))
        updateReferences(of: object, key: String(last), value: value)
        do {
            try shared.container?.viewContext.save()
        } catch {
            print("ERROR SAVING")
        }
    }
    
    private static func updateReferences<T: CDAutoModel, Value: Any>(of object: T, key: String, value: Value) {
        print("Current References: \(shared.weakReferences.allObjects)")
        for savedObject in shared.weakReferences.allObjects {
            if savedObject === object {
                print("continuing")
                continue
            }
            if type(of: savedObject) === type(of: object) {
                // Try to update this object
                if let autoModel = savedObject as? T {
                    let shouldUpdate = autoModel.shouldUpdate
                    autoModel.shouldUpdate = false
                    autoModel.safeSetValue(value, forKey: key.asKey)
                    autoModel.shouldUpdate = shouldUpdate
                }
            }
        }
        
    }
}
