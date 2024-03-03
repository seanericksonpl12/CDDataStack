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
open class CDAutoModel: NSObject {
    internal final var _shouldUpdate: Bool = false
    override public init() {
        super.init()
        if let caller = self as? NestedModel {
            self.declareNestedModel(caller: caller)
        } else {
            self.declareModel(caller: self)
        }
        self._shouldUpdate = true
    }
}

@available(iOS 16.4, *)
extension CDAutoModel {
    
    internal func saveChanges<T: CDAutoModel, Value: Any>(keyPath: ReferenceWritableKeyPath<T, AutoSave<Value>>, value: Value) {
        CDDataStack.saveEntity(name: String(describing: T.self), for: self, keyPath: keyPath, value: value)
    }
    
    internal func declareModel<T: CDAutoModel>(caller: T) {
        CDDataStack.declareEntity(for: caller)
    }
    
    internal func declareNestedModel<T: NestedModel>(caller: T) {
        CDDataStack.declareNestedEntity(for: caller)
    }
}

@available(iOS 16.4, *)
@objcMembers
public class NestedModel: CDAutoModel {}
