//
//  File.swift
//  
//
//  Created by Sean Erickson on 2/24/24.
//

import Foundation
import ObjC
import CoreData

extension NSObject {
    /// Try to set a value for given key, returning true if succeeded and false if not
    @objc
    @discardableResult
    func safeSetValue(_ value: Any?, forKey key: String) -> Bool {
        do {
            try ObjC.catchNSException {
                self.setValue(value, forKey: key)
            }
        } catch {
            print("error: \(error)")
            return false
        }
        return true
    }
    
    @objc
    @discardableResult
    func safeValue(forKey key: String) -> Any? {
        do {
            var value: Any?
            try ObjC.catchNSException { value = self.value(forKey: key) }
            return value
        } catch {
            print("error: \(error)")
            return nil
        }
    }
}
