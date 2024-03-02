// The Swift Programming Language
// https://docs.swift.org/swift-book
import CoreData

// TODO: Decide what the fuck to do with this.  Is it shared or not, how are we doin AutoModel vs DataModel
fileprivate struct DataStackConstants {
    static let folder = "CDDataStack/"
    static let databaseURL = folder.appending("generatedStack.xcdatamodeld")
}

class CDDataStack {
    internal var container: NSPersistentContainer?
    internal static let containerName = "CDContainedBaseModel"
    internal var weakReferences: NSHashTable<AnyObject> = NSHashTable<AnyObject>.weakObjects()
    
    private static var privateShared: CDDataStack?
    public static var shared = CDDataStack()
    
    private init() {
        print("shared initialized")
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
}

extension CDDataStack {
    
    static func newModelAddingEntity(_ entity: NSEntityDescription) -> NSManagedObjectModel {
//        guard let url = Bundle.module.url(forResource: containerName, withExtension: "momd") else { fatalError("Could not get URL for model") }
//        guard let model = NSManagedObjectModel(contentsOf: url) else { fatalError("Could not get model for: \(url)") }
        guard let model = shared.container?.managedObjectModel.copy() as? NSManagedObjectModel else {
            fatalError()
        }
        model.entities.append(entity)
        return model
    }
    
    static func reloadContainer(with model: NSManagedObjectModel) -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "CDBaseContainer", managedObjectModel: model)
        container.viewContext.retainsRegisteredObjects = true
        container.persistentStoreDescriptions.first?.type = memoryType
        container.loadPersistentStores { desc, error in
            print("STORE: \(desc)")
            if let error = error {
                fatalError("error loading persistance store: \(error)")
            }
        }
        return container
    }
}

extension CDDataStack {
    static var memoryType: String {
        // TODO: EDIT TO TEST IN MEMORY FOR LARGER TESTS
        #if DEBUG
        return NSSQLiteStoreType
        #else
        return NSSQLiteStoreType
        #endif
    }
}

// MARK: - TESTING
extension CDDataStack {
    static func printObjects() {
        print(shared.weakReferences.allObjects)
    }
}
