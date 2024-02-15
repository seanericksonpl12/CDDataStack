import XCTest
import CoreData
import SwiftData
@testable import CDDataStack

//final class TestEntity: NSManagedObject {
//    @NSManaged var testName: String?
//    @NSManaged var testNum: Int16
//}

struct MyAttribute {
    var someName: String
    var someInt: Int
}


class TestModel {
    var testName: String = "Testing.."
    var testNum: Int16 = 12
    var otherName: String = "will this exist???"
}

final class CDDataStackTests: XCTestCase {
    
    var container: NSPersistentContainer!
    
    override func setUp() {
        let persistence = TemporaryPersistenceManager(configuration: PersistenceConfiguration(modelName: "TestModel", cloudIdentifier: "", configuration: "Local"))
        self.container = persistence.container
        CDDataStack.setup(with: persistence.container)
    }
    
    @available(iOS 15.4, *)
    func testModelSetup() throws {
        let model1 = TestModel()
        let model2 = TestModel()
        model2.testName = "Different name"
        model1.save(context: container.viewContext)
        model2.save(context: container.viewContext)
//        let request = try container.viewContext.fetch(NSFetchRequest(entityName: "TestEntity"))
//        if let arr = request as? [TestEntity] {
//            print("entity arr: \(arr)")
//        }
        guard let arr = TestModel.load(context: container.viewContext) as? [TestModel] else {
            return
        }
        for obj in arr {
            print(obj.testName)
            print(obj.testNum)
        }
    }
}
