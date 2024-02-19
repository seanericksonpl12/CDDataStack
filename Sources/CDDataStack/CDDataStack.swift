// The Swift Programming Language
// https://docs.swift.org/swift-book
import CoreData

fileprivate struct DataStackConstants {
    static let folder = "CDDataStack/"
    static let databaseURL = folder.appending("generatedStack.xcdatamodeld")
}

class CDDataStack {
    internal var container: NSPersistentContainer!
    internal static let containerName = "CDContainedBaseModel"
    
    private static var privateShared: CDDataStack?
    public static var shared = CDDataStack()
    
    private init(inMemory: Bool = true) {
        guard let url = Bundle.module.url(forResource: CDDataStack.containerName, withExtension: "momd") else { fatalError("Could not get URL for model") }
        guard let model = NSManagedObjectModel(contentsOf: url) else { fatalError("Could not get model for: \(url)") }
        container = NSPersistentContainer(name: "CDBaseContainer", managedObjectModel: model)
        container.persistentStoreDescriptions.first?.type = inMemory ? NSInMemoryStoreType : NSSQLiteStoreType
        container.loadPersistentStores(completionHandler: { [self] (desc, err) in
            if let err = err {
                fatalError("Error loading TEMPORARY STORE: \(desc): \(err)")
            }
            debugPrint("Loaded \(container.persistentStoreDescriptions.first?.type) successfully")
            
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension CDDataStack {
    
    public static func setupHeadless(inMemory: Bool = false) {
        guard let url = Bundle.module.url(forResource: containerName, withExtension: "momd") else { fatalError("Could not get URL for model") }
        guard let model = NSManagedObjectModel(contentsOf: url) else { fatalError("Could not get model for: \(url)") }
        let container = NSPersistentContainer(name: "CDBaseContainer", managedObjectModel: model)
        container.persistentStoreDescriptions.first?.type = inMemory ? NSInMemoryStoreType : NSSQLiteStoreType
        container.loadPersistentStores(completionHandler: { (desc, err) in
            if let err = err {
                fatalError("Error loading TEMPORARY STORE: \(desc): \(err)")
            }
            debugPrint("Loaded \(container.persistentStoreDescriptions.first?.type) successfully")
            
        })
        
        privateShared = CDDataStack()
    }
    
    public static func setup() {
        guard let url = Bundle.module.url(forResource: containerName, withExtension: "momd") else { fatalError("Could not get URL for model") }
        guard let model = NSManagedObjectModel(contentsOf: url) else { fatalError("Could not get model for: \(url)") }
        let container = NSPersistentContainer(name: "CDBaseContainer", managedObjectModel: model)
        container.persistentStoreDescriptions.first?.configuration = "Local"
        container.persistentStoreDescriptions.first?.type = NSInMemoryStoreType
        container.loadPersistentStores(completionHandler: { (desc, err) in
            if let err = err {
                fatalError("Error loading TEMPORARY STORE: \(desc): \(err)")
            }
            debugPrint("Loaded TEMPORARY STORE successfully")
            
        })
        print(container)
        privateShared = CDDataStack()
    }
//    
//    public static func setup(with container: NSPersistentContainer) {
//        privateShared = CDDataStack(container: container)
//    }
}

public
enum CDModelConfiguration {
    case local
    case normal
}


