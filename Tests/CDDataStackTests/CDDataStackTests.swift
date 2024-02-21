import XCTest
import CoreData
import SwiftData
@testable import CDDataStack

//final class TestEntity: NSManagedObject {
//    @NSManaged var testName: String?
//    @NSManaged var testNum: Int16
//}

@available(iOS 16.4, *)
@objcMembers
class AutoSaveTest: CDAutoModel {
    @AutoSave var myString: String = ""
    @AutoSave var myInt: Int = 10
    @AutoSave var myStruct = TestingStruct()
    var unrelatedString: String = "unrelated"
}

struct TestingStruct: AutoStruct {
    var nestedString: String = "something"
    var nestedInt: Int = 20
}

@available(iOS 16.4, *)
class TestModel: CDDataModel<TestEntity> {
    var testName: String = "Testing.."
    var testNum: Int16 = 12
    var otherName: String = "will this exist???"
}


@available(iOS 16.4, *)
final class CDDataStackTests: XCTestCase {
    
    var container: NSPersistentContainer!
    
    override func setUp() {
        
    }

    func testModelSetup() throws {
        let persistence = TemporaryPersistenceManager(configuration: PersistenceConfiguration(modelName: "TestModel", cloudIdentifier: "", configuration: "Local"))
        self.container = persistence.container
      //  CDDataStack.setup(with: persistence.container)
        
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
    
    func testContainedDataModel() {
        CDDataStack.setupHeadless(inMemory: true)
    }
    
    @available(iOS 16.4, *)
    func testPropertyWrapper() {

        let test = AutoSaveTest()
        print(test.myStruct.type())
        //test.myString = "testing..."
    }
}
