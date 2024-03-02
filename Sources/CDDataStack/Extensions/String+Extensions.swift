//
//  String+Extensions.swift
//
//
//  Created by Sean Erickson on 2/19/24.
//

import Foundation
import ObjC

extension String {
    var asKey: String {
        var str = self
        if str.first == "_" {
            if str.removeFirst() == "_" {
                return str
            }
        }
        return self
    }
}

