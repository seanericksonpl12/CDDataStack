// The Swift Programming Language
// https://docs.swift.org/swift-book
import CoreData

public protocol CDDataModel {
    associatedtype CDModel: NSManagedObject
    func saveChanges(stack: CDDataStack)
}

public
extension CDDataModel {
    func saveChanges(stack: CDDataStack) {
        guard let stack = CDDataStack.shared else {
            print("Error: Could not load CDDataStack")
            return
        }
        let model = CDModel(context: stack.container.viewContext)
        stack.save()
    }
    
    func buildModel() -> CDModel? {
        guard let stack = CDDataStack.shared else {
            print("Error: Could not load CDDataStack")
            return nil
        }
        let model = CDModel(context: stack.container.viewContext)
        let mirror = CDObjectBuilder(object: self)
        mirror.setValues(for: model)
        print(model)
        return model
    }
}

extension CDDataModel {
    public func testCDObjbuilder() {
        
    }
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
    public func setup(with container: NSPersistentContainer) {
        CDDataStack.privateShared = CDDataStack(container: container)
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


