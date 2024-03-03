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
    
    static func declareNestedEntity<T: NestedModel>(for object: T) {
        let entityName = String(describing: type(of: object))
        let entity = NSEntityDescription()
        entity.name = entityName
        let mirror = Mirror(reflecting: object)
        var keypaths = [String: Any]()
        var entities = [entity]
        for case let (label?, mirrorValue) in mirror.children {
            setupAttributes(currentEntity: entity, entityList: &entities, label: label, value: mirrorValue, keyPaths: &keypaths)
        }
        shared.entitiesToDeclare.append((object, entity))
    }
    
    static func declareEntity<T: CDAutoModel>(for object: T, resettingOnInit: Bool = false, lastCall: Bool = true) {
        let entityName = String(describing: type(of: object))
        if shared.container != nil {
            if let entity = shared.container!.managedObjectModel.entities.first(where: { $0.name == entityName }){
                // setup obj for existing
                setupClassObject(object: object, entity: entity)
            } else {
                
                // MARK: - NOT CURRENTLY WORKING.  NEED TO MIGRATE MODEL?
                let entity = NSEntityDescription()
                entity.name = entityName
                let mirror = Mirror(reflecting: object)
                var keypaths = [String: Any]()
                var entities = [entity]
                for case let (label?, mirrorValue) in mirror.children {
                    setupAttributes(currentEntity: entity, entityList: &entities, label: label, value: mirrorValue, keyPaths: &keypaths)
                }
                // TODO: Create new merged model, preferrably without reloading persistant stores
                let model = newModelAddingEntity(entity)
                shared.container = reloadContainer(with: model)
                setupClassObject(object: object, entity: entity)
            }
        } else {
            // setup container
            guard let url = Bundle.module.url(forResource: containerName, withExtension: "momd") else { fatalError("Could not get URL for model") }
            guard let model = NSManagedObjectModel(contentsOf: url) else { fatalError("Could not get model for: \(url)") }
            let entity = NSEntityDescription()
            entity.name = entityName
            let mirror = Mirror(reflecting: object)
            var keypaths = [String: Any]()
            var entities = [entity]
            for case let (label?, mirrorValue) in mirror.children {
                setupAttributes(currentEntity: entity, entityList: &entities, label: label, value: mirrorValue, keyPaths: &keypaths)
            }
            entities.append(contentsOf: shared.entitiesToDeclare.map { $0.1 })
            model.entities = entities
            shared.container = reloadContainer(with: model)
            setupClassObject(object: object, entity: entity)
            for (object, entity) in shared.entitiesToDeclare {
                setupClassObject(object: object, entity: entity)
            }
            shared.entitiesToDeclare = []
        }
    }
}
