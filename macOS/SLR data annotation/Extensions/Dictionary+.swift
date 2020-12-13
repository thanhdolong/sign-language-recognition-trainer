//
//  Dictionary+.swift
//  SLR data annotation
//
//  Created by Thành Đỗ Long on 13.12.2020.
//

import Foundation

extension Dictionary {
    mutating func add<T>(_ element: T, toArrayOn key: Key) where Value == [T] {
        self[key] == nil ? self[key] = [element] : self[key]?.append(element)
    }
}
