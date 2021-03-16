//
//  ObservationConfiguration.swift
//  SLR data annotation
//
//  Created by Matyáš Boháček on 01/12/2020.
//  Copyright © 2020 Matyáš Boháček. All rights reserved.
//

import Foundation
import Vision

struct ObservationConfiguration {
    enum ObservationType {
        case bodyLandmarks
        case handLandmarks
        case faceLandmarks
    }

    ///
    /// List of all the data annotations to be analyzed using Vision.
    ///
    static var desiredDataAnnotations: [ObservationType] {
        set {}
        get {
            var result = [ObservationType]()
            
            if UserDefaults.standard.bool(forKey: "analyzeHands") {
                result.append(.handLandmarks)
            }
            if UserDefaults.standard.bool(forKey: "analyzeBody") {
                result.append(.bodyLandmarks)
            }
            if UserDefaults.standard.bool(forKey: "analyzeFace") {
                result.append(.faceLandmarks)
            }
            
            return result
        }
    }

    ///
    /// List of requested recognized body landmarks key in order to filter out any redundant.
    ///
    /// - Warning: If empty, all body landmarks are requested
    ///
    static let requestedBodyLandmarks: [VNHumanBodyPoseObservation.JointName] = [
        .nose, .root, .neck,
        .rightEye, .leftEye,
        .rightEar, .leftEar,
        .rightShoulder, .leftShoulder,
        .rightElbow, .leftElbow,
        .rightWrist, .leftWrist
    ]

    ///
    /// List of requested recognized hand landmarks key in order to filter out any redundant.
    ///
    /// - Warning: If empty, all hand landmarks are requested
    ///
    static let requestedHandLandmarks: [VNHumanHandPoseObservation.JointName] = [
        .wrist, .thumbCMC,
        .thumbMP, .thumbIP,
        .thumbTip, .indexMCP,
        .indexPIP, .indexDIP,
        .indexTip, .middleMCP,
        .middlePIP, .middleDIP,
        .middleTip, .ringMCP,
        .ringPIP, .ringDIP,
        .ringTip, .littleMCP,
        .littlePIP, .littleDIP,
        .littleTip
    ]
}
