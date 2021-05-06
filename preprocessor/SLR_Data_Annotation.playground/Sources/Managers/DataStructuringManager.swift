//
//  DataStructuringManager.swift
//  SLR_Data_Annotation
//
//  Created by Matyáš Boháček on 01/12/2020.
//  Copyright © 2020 Matyáš Boháček. All rights reserved.
//

import Foundation
import Vision


public class DataStructuringManager {

    ///
    /// Converts the data from the hand landmarks observations to landmark keys, for further data
    /// structuring.
    ///
    /// - Parameters:
    ///   - recognizedLandmarks: Array of arrays of dictionaries with data from Vision analysis
    ///
    /// - Returns: Dictionary of Strings to arrays of Doubles for further processing
    ///
    public static func convertHandLandmarksToMLData(recognizedLandmarks: [[[VNHumanHandPoseObservation.JointName: VNPoint]]]) -> [String: [Double]] {
        // Prepare the dictionary for all of the possible landmarks keys to be added
        var converted = [String: [Double]]()
        for keyOrdered in ObservationTerminology.handLandmarksKeyOrder {
            converted[keyOrdered] = []
            converted[keyOrdered] = []
        }

        for (observationIndex, observation) in recognizedLandmarks.enumerated() {
            // Ensure that maximally two hand are analyzed
            var maxObservationIndex = 2
            if maxObservationIndex > observation.count {
                maxObservationIndex = observation.count
            }

            // Structure the data with the new keys
            for (handIndex, data) in observation[0..<maxObservationIndex].enumerated() {
                for (landmarkKey, value) in data {
                    converted[ObservationTerminology.handLandmarksKeysToLabels[landmarkKey]! + "\(handIndex)X"]?.append(Double(value.location.x))
                    converted[ObservationTerminology.handLandmarksKeysToLabels[landmarkKey]! + "\(handIndex)Y"]?.append(Double(value.location.y))
                }
            }

            // Fill in the values for all potential landmarks that were not captured
            for keyOrdered in ObservationTerminology.handLandmarksKeyOrder {
                if converted[keyOrdered]?.count != observationIndex + 1 {
                    converted[keyOrdered]?.append(0.0)
                }
            }
        }

        return converted
    }

    ///
    /// Converts the data from the body landmarks observations to landmark keys, for further data
    /// structuring.
    ///
    /// - Parameters:
    ///   - recognizedLandmarks: Array of arrays of dictionaries with data from Vision analysis
    ///
    /// - Returns: Dictionary of Strings to arrays of Doubles for further processing
    ///
    public static func convertBodyLandmarksToMLData(recognizedLandmarks: [[[VNHumanBodyPoseObservation.JointName: VNPoint]]]) -> [String: [Double]] {
        // Prepare the dictionary for all of the possible landmarks keys to be added
        var converted = [String: [Double]]()
        for keyOrdered in ObservationTerminology.bodyLandmarksKeyOrder {
            converted[keyOrdered] = []
        }

        for (observationIndex, observation) in recognizedLandmarks.enumerated() {
            if !observation.isEmpty {
                // Structure the data with the new keys
                for (landmarkKey, value) in observation[0] {
                    converted[ObservationTerminology.bodyLandmarksKeysToLabels[landmarkKey]! + "X"]?.append(Double(value.location.x))
                    converted[ObservationTerminology.bodyLandmarksKeysToLabels[landmarkKey]! + "Y"]?.append(Double(value.location.y))
                }
            }

            // Fill in the values for all potential landmarks that were not captured
            for keyOrdered in ObservationTerminology.bodyLandmarksKeyOrder {
                if converted[keyOrdered]?.count != observationIndex + 1 {
                    converted[keyOrdered]?.append(0.0)
                }
            }
        }

        return converted
    }

    ///
    /// Converts the data from the face landmarks observations to landmark keys, for further data
    ///  structuring.
    ///
    /// - Parameters:
    ///   - recognizedLandmarks: Array of arrays of dictionaries with data from Vision analysis
    ///
    /// - Returns: Dictionary of Strings to arrays of Doubles for further processing
    ///
    public static func convertFaceLandmarksToMLData(recognizedLandmarks: [[[CGPoint]]]) -> [String: [Double]] {
        // Prepare the dictionary for all of the possible landmarks keys to be added
        var converted = [String: [Double]]()
        for keyOrdered in ObservationTerminology.faceLandmarksKeyOrder {
            converted[keyOrdered] = []
        }

        for (observationIndex, observation) in recognizedLandmarks.enumerated() {
            if !observation.isEmpty {
                // Structure the data with the new keys
                for (landmarkIndex, landmark) in observation[0].enumerated() {
                    converted["landmark\(landmarkIndex)X"]?.append(Double(landmark.x))
                    converted["landmark\(landmarkIndex)Y"]?.append(Double(landmark.y))
                }
            }

            // Fill in the values for all potential landmarks that were not captured
            for keyOrdered in ObservationTerminology.faceLandmarksKeyOrder {
                if converted[keyOrdered]?.count != observationIndex + 1 {
                    converted[keyOrdered]?.append(0.0)
                }
            }
        }

        return converted
    }

}
