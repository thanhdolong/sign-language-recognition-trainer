//
//  DataStructuringManager.swift
//  SLR data annotation
//
//  Created by Matyáš Boháček on 01/12/2020.
//  Copyright © 2020 Matyáš Boháček. All rights reserved.
//

import Foundation
import CreateML
import Vision

class DataStructuringManager {

    ///
    /// Representations of the possible errors occuring in this context
    ///
    enum OutputProcessingError: Error {
        case invalidData
        case structuringData
    }
    
    enum Hand: String {
        case left, right
    }

    lazy var queue = OperationQueue()

    ///
    /// Converts the data from the hand landmarks observations to landmark keys, for further data
    /// structuring.
    ///
    /// - Parameters:
    ///   - recognizedLandmarks: Array of arrays of dictionaries with data from Vision analysis
    ///
    /// - Returns: Dictionary of Strings to arrays of Doubles for further processing
    ///
    func convertHandLandmarksToMLData(recognizedLandmarks: KeyHandLandmarks, rightWrist: [Double]? = nil, leftWrist: [Double]? = nil) -> [String: [Double]] {
        // Prepare the dictionary for all of the possible landmarks keys to be added
        var converted = [String: [Double]]()
        var determinedHand: Hand?
        
        for (observationIndex, observation) in recognizedLandmarks.enumerated() {
            // Ensure that maximally two hand are analyzed
            var maxObservationIndex = 2

            if maxObservationIndex > observation.count {
                maxObservationIndex = observation.count
            }

            // Structure the data with the new keys
            observation.enumerated().forEach { (handIndex, data) in
                guard let rightWrist = rightWrist, let leftWrist = leftWrist, let wrist = data[.wrist]?.location.x else {
                    return
                }
                
                let distanceFromRight = abs(Double(wrist) - rightWrist[handIndex])
                let distanceFromLeft = abs(Double(wrist) - leftWrist[handIndex])
                determinedHand = distanceFromLeft < distanceFromRight ? .left : .right
                
                for (landmarkKey, value) in data {
                    converted.add(Double(value.location.x),
                                  toArrayOn: "\(landmarkKey.stringValue())_\(determinedHand?.rawValue ?? String(handIndex))_X")
                    converted.add(Double(value.location.y),
                                  toArrayOn: "\(landmarkKey.stringValue())_\(determinedHand?.rawValue ?? String(handIndex))_Y")
                }
            }

            // Fill in the values for all potential landmarks that were not captured
            for landmarkKey in ObservationConfiguration.requestedHandLandmarks
            where converted["\(landmarkKey.stringValue())_\(Hand.left.rawValue)_X"]?.count != observationIndex + 1  {
                converted.add(0,
                              toArrayOn: "\(landmarkKey.stringValue())_\(Hand.left.rawValue)_X")
                converted.add(0,
                              toArrayOn: "\(landmarkKey.stringValue())_\(Hand.left.rawValue)_Y")
            }
            
            for landmarkKey in ObservationConfiguration.requestedHandLandmarks
            where converted["\(landmarkKey.stringValue())_\(Hand.right.rawValue)_X"]?.count != observationIndex + 1  {
                converted.add(0,
                              toArrayOn: "\(landmarkKey.stringValue())_\(Hand.right.rawValue)_X")
                converted.add(0,
                              toArrayOn: "\(landmarkKey.stringValue())_\(Hand.right.rawValue)_Y")
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
    func convertBodyLandmarksToMLData(recognizedLandmarks: KeyBodyLandmarks) -> [String: [Double]] {
        // Prepare the dictionary for all of the possible landmarks keys to be added
        var converted = [String: [Double]]()

        for (observationIndex, observation) in recognizedLandmarks.enumerated() {
            if !observation.isEmpty {
                // Structure the data with the new keys
                for (landmarkKey, value) in observation[0] {
                    converted.add(Double(value.location.x), toArrayOn: "\(landmarkKey.stringValue())_X")
                    converted.add(Double(value.location.y), toArrayOn: "\(landmarkKey.stringValue())_Y")
                }
                
                // Fill in the values for all potential landmarks that were not captured
                for landmarkKey in ObservationConfiguration.requestedBodyLandmarks where converted["\(landmarkKey.stringValue())_X"]?.count != observationIndex + 1 {
                    converted.add(0, toArrayOn: "\(landmarkKey.stringValue())_X")
                    converted.add(0, toArrayOn: "\(landmarkKey.stringValue())_Y")
                }
            } else {
                for landmarkKey in ObservationConfiguration.requestedBodyLandmarks {
                    converted.add(0, toArrayOn: "\(landmarkKey.stringValue())_X")
                    converted.add(0, toArrayOn: "\(landmarkKey.stringValue())_Y")
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
    func convertFaceLandmarksToMLData(recognizedLandmarks: KeyFaceLandmarks) -> [String: [Double]] {
        // Prepare the dictionary for all of the possible landmarks keys to be added
        var converted = [String: [Double]]()

        for (observationIndex, observation) in recognizedLandmarks.enumerated() {
            if let observation = observation.first {
                // Structure the data with the new keys
                for (landmarkIndex, landmark) in observation.enumerated() {
                    converted.add(Double(landmark.x), toArrayOn: "\(landmarkIndex)_X")
                    converted.add(Double(landmark.y), toArrayOn: "\(landmarkIndex)_Y")
                }
            }

            // Fill in the values for all potential landmarks that were not captured
            converted.forEach { key, _ in
                if converted[key]?.count != observationIndex + 1 {
                    converted[key]?.append(0.0)
                }
            }
        }

        return converted
    }

    ///
    /// Combine the data from multiple VisionAnalysisManagers into a MLDataTable.
    ///
    /// - Parameters:
    ///   - labels: Array of String labels of the individuals signs
    ///   - visionAnalyses: Array of the processed and annotated VisionAnalysisManagers
    ///
    /// - Returns: Newly constructed MLDataTable
    ///
    func combineData(labels: [String], results: [VisionAnalysisResult]) throws -> MLDataTable {
        // Ensure that the data is equally long
        guard labels.count == results.count else {
            throw OutputProcessingError.invalidData
        }

        // Prepare the structured data in the MLDataTable-processable format
        var convertedToMLData = [String: MLDataValueConvertible]()
        convertedToMLData["labels"] = labels

        // Stack the data from individual analyses to arrays
        var stackedData = [String: [[Double]]]()
        var videoMetadata = ["width": [Double](), "height": [Double](), "fps": [Double]()]

        for analysis in results {
            // Append data for body landmarks
            if ObservationConfiguration.desiredDataAnnotations.contains(.bodyLandmarks) {
                for (key, value) in
                    convertBodyLandmarksToMLData(recognizedLandmarks: analysis.keyLandmarks.body) {
                    stackedData.add(value, toArrayOn: key)
                }
            }
            
            // Append data for hand landmarks
            if ObservationConfiguration.desiredDataAnnotations.contains(.handLandmarks) {
                convertHandLandmarksToMLData(recognizedLandmarks: analysis.keyLandmarks.hand,
                                             rightWrist: stackedData["rightWrist_X"]?.last,
                                             leftWrist: stackedData["leftWrist_X"]?.last).forEach { key, value in
                    stackedData.add(value, toArrayOn: key)
                }
            }

            // Append data for face landmarks
            if ObservationConfiguration.desiredDataAnnotations.contains(.faceLandmarks) {
                convertFaceLandmarksToMLData(recognizedLandmarks: analysis.keyLandmarks.face).forEach { key, value in
                    stackedData.add(value, toArrayOn: key)
                }
            }

            // Add video size information to the dataset
            videoMetadata["width"]?.append(Double(analysis.videoSize.width))
            videoMetadata["height"]?.append(Double(analysis.videoSize.height))
            videoMetadata["fps"]?.append(Double(analysis.fps))
        }

        for (key, value) in stackedData {
            convertedToMLData[key] = value
        }
        
        convertedToMLData["video_size_width"] = videoMetadata["width"]
        convertedToMLData["video_size_height"] = videoMetadata["height"]
        convertedToMLData["video_fps"] = videoMetadata["fps"]

        do {
            // Create a MLDataTable on top of the structured data
            return try MLDataTable(dictionary: convertedToMLData)
        } catch {
            throw OutputProcessingError.structuringData
        }
    }
}
