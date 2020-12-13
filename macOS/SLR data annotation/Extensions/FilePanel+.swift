//
//  FilePanel+.swift
//  SLR data annotation
//
//  Created by Thành Đỗ Long on 12.12.2020.
//

import Cocoa
import Vision

extension NSOpenPanel {
    static func openVideo(completion: @escaping (_ result: Result<URL, Error>) -> ()) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedFileTypes = ["mp4"]
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

extension VNHumanBodyPoseObservation.JointName {
    func stringValue() -> String {
        guard let label = ObservationTerminology.bodyLandmarksKeysToLabels[self] else { fatalError("Cannot converse landamard") }
        return label
    }
}

extension VNHumanHandPoseObservation.JointName {
    func stringValue() -> String {
        guard let label = ObservationTerminology.handLandmarksKeysToLabels[self] else { fatalError("Cannot converse landamard") }
        return label
    }
}

extension Dictionary {
    mutating func add<T>(_ element: T, toArrayOn key: Key) where Value == [T] {
        self[key] == nil ? self[key] = [element] : self[key]?.append(element)
    }
}
