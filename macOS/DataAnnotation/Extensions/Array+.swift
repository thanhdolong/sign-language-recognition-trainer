//
//  Array+.swift
//  DataAnnotation
//
//  Created by Thành Đỗ Long on 24.12.2020.
//

import Foundation

extension Array {
    var elementBeforeLast: Element? {
        return dropLast().last
    }
}
