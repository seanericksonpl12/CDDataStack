//
//  File.swift
//  
//
//  Created by Sean Erickson on 2/25/24.
//

import Foundation

class WrappedValue {
    @objc var data: Any
    
    init(data: Any) {
        self.data = data as Any
    }
    
    init(data: Data) throws {
        self.data = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed, .mutableContainers])
    }
    
    func encode() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self.data, options: .fragmentsAllowed)
    }
}
    
       

