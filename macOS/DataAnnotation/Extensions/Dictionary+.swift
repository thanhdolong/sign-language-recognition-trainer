//
//  Dictionary+.swift
//  SLR data annotation
//
//  Created by Thành Đỗ Long on 13.12.2020.
//

import Foundation

extension Dictionary {
    mutating func add<Element>(_ element: Element, toArrayOn key: Key) where Value == [Element] {
        self[key] == nil ? self[key] = [element] : self[key]?.append(element)
    }
}
