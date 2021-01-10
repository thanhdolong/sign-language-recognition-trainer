//
//  MachineLearningConfiguration.swift
//  SLR data annotation
//
//  Created by Thành Đỗ Long on 13.12.2020.
//

import Foundation

struct MachineLearningConfiguration {

    ///
    /// Threshold for the hand pose detection using the Vision framework.
    ///
    static var handPoseDetectionThreshold: Float = UserDefaults.standard.float(forKey: "handPoseDetectionThreshold")

    ///
    /// Threshold for the body pose detection using the Vision framework.
    ///
    static let bodyPoseDetectionThreshold: Float = UserDefaults.standard.float(forKey: "bodyPoseDetectionThreshold")
}
