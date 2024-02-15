//
//  File.swift
//  
//
//  Created by Sean Erickson on 2/14/24.
//

import Foundation
import CoreData

public protocol PersistenceManager {
    
    var viewContext: NSManagedObjectContext { get }
    
    init(configuration: PersistenceConfiguration)
}

extension PersistenceManager {
    
    static func model(for name: String) -> NSManagedObjectModel {
        
        guard let url = Bundle.module.url(forResource: name, withExtension: "momd") else { fatalError("Could not get URL for model: \(name)") }

        guard let model = NSManagedObjectModel(contentsOf: url) else { fatalError("Could not get model for: \(url)") }

        return model
    }
}


public struct PersistenceConfiguration {
    
    public init(
        modelName: String,
        cloudIdentifier: String,
        configuration: String
    ) {

        self.modelName = modelName
        self.cloudIdentifier = cloudIdentifier
        self.configuration = configuration
    }
    
    public let modelName: String
    public let cloudIdentifier: String
    public let configuration: String
}


open class PersistentContainer: NSPersistentContainer {

    override open class func defaultDirectoryURL() -> URL {

        return super.defaultDirectoryURL()
            .appendingPathComponent("CoreDataModel")
            .appendingPathComponent("Local")
    }
}

@available(iOS 13.0, *)
open class PersistentCloudKitContainer: NSPersistentCloudKitContainer {
    
    override open class func defaultDirectoryURL() -> URL {
        
        return super.defaultDirectoryURL()
            .appendingPathComponent("CoreDataModel")
            .appendingPathComponent("Cloud")
    }
}

public class TemporaryPersistenceManager: PersistenceManager {
    
    public var viewContext: NSManagedObjectContext { container.viewContext }
    
    var container: PersistentContainer
    
    required public init(
        configuration: PersistenceConfiguration
    ) {
        
        let model = TemporaryPersistenceManager.model(for: configuration.modelName)

        self.container = .init(name: configuration.modelName,
                               managedObjectModel: model)

        self.container.persistentStoreDescriptions
            .first?
            .configuration = configuration.configuration
        
        self.container.persistentStoreDescriptions
            .first?
            .type = NSInMemoryStoreType
        
        self.container.loadPersistentStores(completionHandler: { (desc, err) in
            
            if let err = err {
                
                fatalError("Error loading TEMPORARY STORE: \(desc): \(err)")
            }
            
            debugPrint("Loaded TEMPORARY STORE successfully")
        })
    }
}
