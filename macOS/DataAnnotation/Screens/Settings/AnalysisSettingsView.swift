//
//  AnalysisSettingsView.swift
//  DataAnnotation
//
//  Created by Matyáš Boháček on 07.01.2021.
//

import SwiftUI

struct AnalysisSettingsView: View {
    @AppStorage("handPoseDetectionThreshold") private var handPoseDetectionThreshold = 0.1
    @AppStorage("bodyPoseDetectionThreshold") private var bodyPoseDetectionThreshold = 0.01

    var body: some View {
        Form {
            Slider(value: $handPoseDetectionThreshold, in: 0.01...0.3) {
                Text("Hand Pose Detection Threshold: \(handPoseDetectionThreshold, specifier: "%.3f")")
            }
            Slider(value: $bodyPoseDetectionThreshold, in: 0.01...0.3) {
                Text("Body Pose Detection Threshold: \(bodyPoseDetectionThreshold, specifier: "%.3f")")
            }
        }
        .padding()
    }
}
