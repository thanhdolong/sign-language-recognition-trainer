//
//  FilePanel+.swift
//  SLR data annotation
//
//  Created by Thành Đỗ Long on 12.12.2020.
//

import Cocoa
import Vision

extension NSOpenPanel {
    static func openVideo(completion: @escaping (_ result: Result<URL, Error>) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedFileTypes = Constant.allowedFileTypes
        panel.canChooseFiles = true
        panel.begin { (result) in
            guard result == .OK, let url = panel.urls.first else {
                return completion(.failure(
                    NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get file location"])
                ))
            }

            completion(.success(url))
        }
    }
}

extension NSSavePanel {
}
