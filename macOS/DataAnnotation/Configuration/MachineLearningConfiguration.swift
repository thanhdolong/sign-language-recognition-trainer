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
    static let handPoseDetectionThreshold: Float = 0.1

    ///
    /// Threshold for the body pose detection using the Vision framework.
    ///
    static let bodyPoseDetectionThreshold: Float = 0.01
}
