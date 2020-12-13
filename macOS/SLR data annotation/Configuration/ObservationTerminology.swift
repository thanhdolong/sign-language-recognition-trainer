//
//  ObservationTerminology.swift
//  SLR data annotation
//
//  Created by Thành Đỗ Long on 13.12.2020.
//

import Vision

public struct ObservationTerminology {
    ///
    /// Dictionary for conversion bewteen the `VNHumanBodyPoseObservation.JointName` and custom methodology
    /// `String` identifiers for the body landmarks.
    ///
    public static let bodyLandmarksKeysToLabels: [VNHumanBodyPoseObservation.JointName: String] = [
        .nose : "nose",
        .rightEye : "rightEye",
        .leftEye: "leftEye",
        .rightEar: "rightEar",
        .leftEar: "leftEar",
        .rightShoulder: "rightShoulder",
        .leftShoulder: "leftShoulder",
        .rightElbow: "rightElbow",
        .leftElbow: "leftElbow",
        .rightWrist: "rightWrist",
        .leftWrist: "leftWrist"
    ]

    ///
    /// Dictionary for conversion bewteen the `VNHumanHandPoseObservation.JointName` and custom methodology
    /// `String` identifiers for the hand landmarks.
    ///
    public static let handLandmarksKeysToLabels: [VNHumanHandPoseObservation.JointName: String] = [
        .wrist: "wrist",
        .indexTip: "indexTip",
        .indexDIP: "indexDIP",
        .indexPIP: "indexPIP",
        .indexMCP: "indexMCP",
        .middleTip: "middleTip",
        .middleDIP: "middleDIP",
        .middlePIP: "middlePIP",
        .middleMCP: "middleMCP",
        .ringTip: "ringTip",
        .ringDIP: "ringDIP",
        .ringPIP: "ringPIP",
        .ringMCP: "ringMCP",
        .littleTip: "littleTip",
        .littleDIP: "littleDIP",
        .littlePIP: "littlePIP",
        .littleMCP: "littleMCP",
        .thumbTip: "thumbTip",
        .thumbIP: "thumbIP",
        .thumbMP: "thumbMP",
        .thumbCMC: "thumbCMC"
    ]
}
