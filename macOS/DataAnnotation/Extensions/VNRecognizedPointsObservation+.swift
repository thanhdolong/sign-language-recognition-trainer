//
//  VNRecognizedPointsObservation+.swift
//  SLR data annotation
//
//  Created by Thành Đỗ Long on 13.12.2020.
//

import Vision

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
