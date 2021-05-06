//
//  ObservationConfiguration.swift
//  SLR data annotation
//
//  Created by Matyáš Boháček on 01/12/2020.
//  Copyright © 2020 Matyáš Boháček. All rights reserved.
//

import Foundation
import Vision

enum ObservationType: String, CaseIterable {
    case bodyLandmarks
    case handLandmarks
    case faceLandmarks
}

struct ObservationConfiguration {
    ///
    /// List of all the data annotations to be analyzed using Vision.
    ///
    static var desiredDataAnnotations: [ObservationType] {
        get {
            var result = [ObservationType]()
            
            ObservationType.allCases.forEach { observationType in
                if UserDefaults.standard.bool(forKey: observationType.rawValue) {
                    result.append(observationType)
                }
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
