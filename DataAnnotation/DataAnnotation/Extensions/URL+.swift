//
//  URL+.swift
//  DataAnnotation
//
//  Created by Thành Đỗ Long on 25.12.2020.
//

import Foundation

extension URL {
    var isDirectory: Bool {
        let values = try? resourceValues(forKeys: [.isDirectoryKey])
        return values?.isDirectory ?? false
    }
}
