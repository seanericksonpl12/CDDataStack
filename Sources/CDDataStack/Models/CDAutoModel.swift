//
//  File.swift
//
//
//  Created by Sean Erickson on 2/15/24.
//

import Foundation
import CoreData
import ObjC

@available(iOS 16.4, *)
@objcMembers
public class CDAutoModel: NSObject {
    internal final var shouldUpdate: Bool = false
    override init() {
        super.init()
        self.declareModel(caller: self)
        self.shouldUpdate = true
    }
    
    deinit {
        print("Object deinitialized \(self)")
    }
}

@available(iOS 16.4, *)
extension CDAutoModel {
    
    internal func saveChanges<T: CDAutoModel, Value: Any>(keyPath: ReferenceWritableKeyPath<T, AutoSave<Value>>, value: Value) {
        print("saving changes from \(keyPath) for value \(value)")
        CDDataStack.saveEntity(name: String(describing: T.self), for: self, keyPath: keyPath, value: value)
    }
    
    internal func declareModel<T: CDAutoModel>(caller: T) {
        CDDataStack.declareEntity(for: caller)
    }
}

@objcMembers
public class NestedModel: NSObject {
}
