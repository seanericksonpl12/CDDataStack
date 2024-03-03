//
//  UserModel.swift
//  CDDataStackDemo
//
//  Created by Sean Erickson on 3/3/24.
//

import Foundation
import CDDataStack
import SwiftUI

@Observable class ViewModel {
    
    var position: CGPoint = CGPoint(x: UserModel.shared.x, y: UserModel.shared.y) {
        didSet {
            UserModel.shared.x = Int(position.x)
            UserModel.shared.y = Int(position.y)
        }
    }
}

class UserModel: CDAutoModel {
    
    static var shared: UserModel = UserModel()
    
    @AutoSave var x: Int = 0
    @AutoSave var y: Int = 0
}
