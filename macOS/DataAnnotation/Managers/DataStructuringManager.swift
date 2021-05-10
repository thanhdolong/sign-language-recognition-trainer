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
import CoreLocation

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
    func convertHandLandmarksToMLData(recognizedLandmarks: KeyHandLandmarks,
                                      rightWrist: (x: [Double]?, y: [Double]?)? = nil,
                                      leftWrist:  (x: [Double]?, y: [Double]?)? = nil) -> [String: [Double]] {
        // Prepare the dictionary for all of the possible landmarks keys to be added
        var converted = [String: [Double]]()
        
        recognizedLandmarks.enumerated().forEach { (recognizedLandmarksIndex, observation) in
            // Structure the data with the new keys
            var maxObservation = 2
            if maxObservation > observation.count {
                maxObservation = observation.count
            }
            
            for (handIndex, data) in observation[0..<maxObservation].enumerated() {
                guard let rightWristX = rightWrist?.x,
                      let rightWristY = rightWrist?.y,
                      let leftWristX = leftWrist?.x,
                      let leftWristY = leftWrist?.y else {
                    fatalError("Cannot continue")
                }
                
                let determinedHand: Hand
                let rightWrist = CLLocation(latitude: rightWristX[recognizedLandmarksIndex], longitude: rightWristY[recognizedLandmarksIndex])
                let leftWrist = CLLocation(latitude: leftWristX[recognizedLandmarksIndex], longitude: leftWristY[recognizedLandmarksIndex])
                
                if handIndex == 0, let wrist = data[.wrist] {
                    let wristLocation = CLLocation(latitude: Double(wrist.x), longitude: Double(wrist.y))
                    determinedHand = rightWrist.distance(from: wristLocation) < leftWrist.distance(from: wristLocation) ? .right : .left
                } else if let wrist = observation[0][.wrist] {
                    let wristLocation = CLLocation(latitude: Double(wrist.x), longitude: Double(wrist.y))
                    determinedHand = rightWrist.distance(from: wristLocation) < leftWrist.distance(from: wristLocation) ? .left : .right
                } else {
                    fatalError("Cannot continue")
                }
                
                for (landmarkKey, value) in data {
                    converted.add(Double(value.location.x),
                                  toArrayOn: "\(landmarkKey.stringValue())_\(determinedHand.rawValue)_X")
                    converted.add(Double(value.location.y),
                                  toArrayOn: "\(landmarkKey.stringValue())_\(determinedHand.rawValue)_Y")
                }
            }
            
            // Fill in the values for all potential landmarks that were not captured
            for landmarkKey in ObservationConfiguration.requestedHandLandmarks
            where converted["\(landmarkKey.stringValue())_\(Hand.left.rawValue)_Y"]?.count != recognizedLandmarksIndex + 1  {
                converted.add(0, toArrayOn: "\(landmarkKey.stringValue())_\(Hand.left.rawValue)_X")
                converted.add(0, toArrayOn: "\(landmarkKey.stringValue())_\(Hand.left.rawValue)_Y")
            }
            
            for landmarkKey in ObservationConfiguration.requestedHandLandmarks
            where converted["\(landmarkKey.stringValue())_\(Hand.right.rawValue)_Y"]?.count != recognizedLandmarksIndex + 1  {
                converted.add(0, toArrayOn: "\(landmarkKey.stringValue())_\(Hand.right.rawValue)_X")
                converted.add(0, toArrayOn: "\(landmarkKey.stringValue())_\(Hand.right.rawValue)_Y")
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

        for (index, analysis) in results.enumerated() {
            // Append data for body landmarks
            if ObservationConfiguration.desiredDataAnnotations.contains(.bodyLandmarks) {
                for (key, value) in convertBodyLandmarksToMLData(recognizedLandmarks: analysis.keyLandmarks.body) {
                    stackedData.add(value, toArrayOn: key)
                }
            }

            // Append data for hand landmarks
            if ObservationConfiguration.desiredDataAnnotations.contains(.handLandmarks) {
                convertHandLandmarksToMLData(recognizedLandmarks: analysis.keyLandmarks.hand,
                                             rightWrist: (stackedData["rightWrist_X"]?[index], stackedData["rightWrist_Y"]?[index]),
                                             leftWrist: (stackedData["leftWrist_X"]?[index], stackedData["leftWrist_Y"]?[index])).forEach { key, value in
                    stackedData.add(value, toArrayOn: key)
                }
            }

            // Append data for face landmarks
            if ObservationConfiguration.desiredDataAnnotations.contains(.faceLandmarks) {
                for (key, value) in convertFaceLandmarksToMLData(recognizedLandmarks: analysis.keyLandmarks.face) {
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
