// The Swift Programming Language
// https://docs.swift.org/swift-book
import CoreData

@propertyWrapper
struct Persistent<T: NSManagedObject> {
    var wrappedValue: CDDataModel<T>
}

public
class CDDataStack {
    var container: NSPersistentContainer!
    private static var privateShared: CDDataStack?
    public static var shared: CDDataStack? {
        if let pShared = privateShared {
            return pShared
        } else {
            return nil
        }
    }
    
    private init(container: NSPersistentContainer) {
        self.container = container
    }
}

extension CDDataStack {
    public static func setup(with container: NSPersistentContainer) {
        privateShared = CDDataStack(container: container)
    }
}

extension CDDataStack {
    
    func save() {
        
    }
    
    func delete<T: NSManagedObject>(object: T) {
        
    }
    
    func load<T: NSManagedObject>() -> T? {
        return nil
    }
}


