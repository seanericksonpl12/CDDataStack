//
//  File.swift
//  
//
//  Created by Sean Erickson on 2/15/24.
//

import Foundation

@available(iOS 16.4, *)
@propertyWrapper
public struct AutoSave<Value: Any> {
    public static subscript<T: CDAutoModel>(
        _enclosingInstance instance: T,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
    ) -> Value {
        get {
            instance[keyPath: storageKeyPath].storage
        }
        set {
            if !instance.fromInit && !equals(newValue, instance[keyPath: storageKeyPath].storage) {
                instance.saveChanges(keyPath: storageKeyPath, value: newValue)
            }
            instance[keyPath: storageKeyPath].storage = newValue
        }
    }
    
    @available(*, unavailable, message: "@AutoSave can only be applied to CDAutoModels.")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
    
    internal var storage: Value
    
    public init(wrappedValue: Value) {
        storage = wrappedValue
    }
    
    private static func equals(_ x: Any, _ y: Any) -> Bool {
        guard x is AnyHashable else { return false }
        guard y is AnyHashable else { return false }
        return (x as! AnyHashable) == (y as! AnyHashable)
    }
}
