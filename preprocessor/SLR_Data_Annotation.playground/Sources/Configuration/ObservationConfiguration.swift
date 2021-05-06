//
//  ObservationConfiguration.swift
//  SLR_Data_Annotation
//
//  Created by Matyáš Boháček on 01/12/2020.
//  Copyright © 2020 Matyáš Boháček. All rights reserved.
//

import Foundation
import Vision


public class ObservationConfiguration {

    ///
    /// List of all the data annotations to be analyzed using Vision.
    ///
    public static let desiredDataAnnotations: [ObservationType] = [.bodyLandmarks, .handLandmarks]

    ///
    /// List of requested recognized body landmarks key in order to filter out any redundant.
    ///
    /// - Warning: If empty, all body landmarks are requested
    ///
    public static let requestedBodyLandmarks: [VNHumanBodyPoseObservation.JointName] = [
        .nose,
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
    public static let requestedHandLandmarks: [VNHumanHandPoseObservation.JointName] = []

}
