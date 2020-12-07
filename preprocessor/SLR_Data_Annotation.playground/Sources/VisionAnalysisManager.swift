//
//  VisionAnalysisManager.swift
//  SLR_Data_Annotation
//
//  Created by Matyáš Boháček on 01/12/2020.
//  Copyright © 2020 Matyáš Boháček. All rights reserved.
//

import Foundation
import Cocoa
import Vision


public class VisionAnalysisManager {
    
    // MARK: Properties
    var videoUrl: URL
    var fps: Int = 4
    
    private var framesAnnotated = [[String: Bool]]()
    public var frames = [CGImage]()
    
    public var videoSize = CGSize()
    
    private var keyBodyLandmarks = [[[VNRecognizedPointKey: VNPoint]]]()
    private var keyHandLandmarks = [[[VNRecognizedPointKey: VNPoint]]]()
    private var keyFaceLandmarks = [[[CGPoint]]]()
    
    
    // MARK: Methods
    
    ///
    /// Initiates the VisionAnalysisManager which is responsible for the Vision analysis and annotation of any
    /// given video.
    ///
    /// - Parameters:
    ///   - videoUrl: URL of the video to be annotated
    ///   - fps: Frames per second to be annotated
    ///
    public init?(videoUrl: URL, fps: Int) {
        self.videoUrl = videoUrl
        self.fps = fps
    }
    
    ///
    /// Starts the asynchronous process of annotation with the data associated to this VisionAnalysisManager.
    ///
    public func annotate() {
        // Generate the individual frames from the vido
        self.frames = VideoProcessingManager.getAllFrames(videoUrl: self.videoUrl, fps: self.fps)
        self.framesAnnotated = Array.init(repeating: ["body": false, "hands": false, "face": false], count: self.frames.count)
        
        // Calculate the size of the video
        self.videoSize = VideoProcessingManager.getVideoSize(videoUrl: self.videoUrl)
        
        for frame in frames {
            // Create a VNImageRequestHandler for each of the desired frames
            let handler = VNImageRequestHandler(cgImage: frame, options: [:])
            
            // Process the Vision data for all of the
            invokeBodyPoseDetection(handler: handler)
            invokeHandPoseDetection(handler: handler)
            invokeFaceLandmarksDetection(handler: handler)
        }
    }
    
    ///
    /// Returns all of the data analyzed and structured within this from this VisionAnalysisManager.
    ///
    /// - Returns: Tuple of arrays of arrays of individual dictionaries. The data is structured in the order:
    ///     body, hands, face.
    ///
    /// - Warning: If the data annotations still are not finished, empty arrays will be returned. Check
    ///     `VisionAnalysisManager.isAnnotated()` to find out the current status.
    ///
    public func getData() -> ([[[VNRecognizedPointKey: VNPoint]]], [[[VNRecognizedPointKey: VNPoint]]], [[[CGPoint]]]) {
        if self.isAnnotated() {
            return (self.keyBodyLandmarks, self.keyHandLandmarks, self.keyFaceLandmarks)
        } else {
            return ([], [], [])
        }
    }
    
    ///
    /// Determines whether the data associated with this VisionAnalysisManager is already processed and
    /// annotated.
    ///
    /// - Returns: Bool representation whether is the data already annotated
    ///
    public func isAnnotated() -> Bool {
        for frameStatus in self.framesAnnotated {
            for (_, value) in frameStatus {
                if value == false {
                    return false
                }
            }
        }
        
        return true
    }

    
    // MARK: Body landmarks detection

    ///
    /// Runs a ML model for detecting body pose within the scene using the Vision framework. The analysis
    /// is performed in the background thread.
    ///
    /// - Parameters:
    ///   - handler: VNImageRequestHandler to be used to analyse the body pose
    ///
    func invokeBodyPoseDetection(handler: VNImageRequestHandler) {
        // Run the ML processes on the background thread to prevent lag
        DispatchQueue.global(qos: .background).sync {
            do {
                // Setup the request
                let bodyDetectionRequest = VNDetectHumanBodyPoseRequest(completionHandler: retrieveBodyPoseDetectionResults)

                // Perform the request
                try handler.perform([bodyDetectionRequest])
            } catch {
                print("! \(error)")
            }
        }
    }

    /// Retrieves results from ML analysis of body pose detection, including the relevant joints and their
    /// probabilities.
    ///
    /// - Parameters:
    ///   - request: Initial request updated with the results
    ///   - error: Possible error occuring during the analysis
    ///
    func retrieveBodyPoseDetectionResults(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedPointsObservation] else { return }

        // Process each observation to find the recognized body landmarks
        var result = [[VNRecognizedPointKey: VNPoint]]()
        observations.forEach { result.append(processBodyPoseObservation($0)) }
        
        self.keyBodyLandmarks.append(result)
        self.framesAnnotated[self.keyBodyLandmarks.count - 1]["body"] = true
    }

    func processBodyPoseObservation(_ observation: VNRecognizedPointsObservation) -> [VNRecognizedPointKey: VNPoint] {
        // Retrieve all points
        guard let recognizedPoints = try? observation.recognizedPoints(forGroupKey: .all) else {
            return [:]
        }
        
        var keyBodyLandmarks = [VNRecognizedPointKey: VNPoint]()

        // Process all of the recognized landmarks
        for (key, point) in recognizedPoints {
            if point.confidence > MachineLearningConfiguration.bodyPoseDetectionThreshold {
                // Keep the point for further analysis if relevant
                if (!ObservationConfiguration.requestedBodyLandmarks.isEmpty && ObservationConfiguration.requestedBodyLandmarks.contains(key)) || ObservationConfiguration.requestedBodyLandmarks.isEmpty {
                    keyBodyLandmarks[key] = point
                }
            }
        }
        
        return keyBodyLandmarks
    }

    // MARK: Hand landmarks detection

    ///
    /// Runs a ML model for detecting hand pose within the scene using the Vision framework. The analysis
    /// is performed in the background thread.
    ///
    /// - Parameters:
    ///   - handler: VNImageRequestHandler to be used to analyse the hand pose
    ///
    func invokeHandPoseDetection(handler: VNImageRequestHandler) {
        // Run the ML processes on the background thread to prevent lag
        DispatchQueue.global(qos: .background).sync {
            do {
                // Setup the request
                let handDetectionRequest = VNDetectHumanHandPoseRequest(completionHandler: retrieveHandPoseDetectionResults)
                handDetectionRequest.maximumHandCount = 2

                // Perform the request
                try handler.perform([handDetectionRequest])
            } catch {
                print("! \(error)")
            }
        }
    }

    /// Retrieves results from ML analysis of hand pose detection, including the relevant joints and their
    /// probabilities.
    ///
    /// - Parameters:
    ///   - request: Initial request updated with the results
    ///   - error: Possible error occuring during the analysis
    ///
    func retrieveHandPoseDetectionResults(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedPointsObservation] else { return }

        // Process each observation to find the recognized hand landmarks
        var result = [[VNRecognizedPointKey: VNPoint]]()
        observations.forEach { result.append(processHandPoseObservation($0)) }
        
        self.keyHandLandmarks.append(result)
        self.framesAnnotated[self.keyHandLandmarks.count - 1]["hands"] = true
    }

    func processHandPoseObservation(_ observation: VNRecognizedPointsObservation) -> [VNRecognizedPointKey: VNPoint] {
        // Retrieve all points.
        guard let recognizedPoints = try? observation.recognizedPoints(forGroupKey: .all) else {
            return [:]
        }

        var keyHandLandmarks = [VNRecognizedPointKey: VNPoint]()

        // Process all of the recognized landmarks
        for (key, point) in recognizedPoints {
            if point.confidence > MachineLearningConfiguration.handPoseDetectionThreshold {
                // Keep the point for further analysis if relevant
                if (!ObservationConfiguration.requestedHandLandmarks.isEmpty && ObservationConfiguration.requestedHandLandmarks.contains(key)) || ObservationConfiguration.requestedHandLandmarks.isEmpty {
                    keyHandLandmarks[key] = point
                }
            }
        }
        
        return keyHandLandmarks
    }

    // MARK: Face landmarks detection

    ///
    /// Runs a ML model for detecting face landmarks within the scene using the Vision framework. The analysis
    /// is performed in the background thread.
    ///
    /// - Parameters:
    ///   - handler: VNImageRequestHandler to be used to analyse the face landmarks
    ///
    func invokeFaceLandmarksDetection(handler: VNImageRequestHandler) {
        // Run the ML processes on the background thread to prevent lag
        DispatchQueue.global(qos: .background).sync {
            do {
                // Setup the request
                let faceLandmarksDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: retrieveFaceLandmarksDetectionResults)
                // Perform the request
                try handler.perform([faceLandmarksDetectionRequest])
            } catch {
                print("! \(error)")
            }
        }
    }

    /// Retrieves results from ML analysis of face pose detection, including the relevant joints and their
    /// probabilities.
    ///
    /// - Parameters:
    ///   - request: Initial request updated with the results
    ///   - error: Possible error occuring during the analysis
    ///
    func retrieveFaceLandmarksDetectionResults(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNFaceObservation] else { return }

        // Process each observation to find the recognized face landmarks
        var result = [[CGPoint]]()
        observations.forEach { result.append(processFaceLandmarksObservation($0)) }
        
        self.keyFaceLandmarks.append(result)
        self.framesAnnotated[self.keyFaceLandmarks.count - 1]["face"] = true
    }

    func processFaceLandmarksObservation(_ observation: VNFaceObservation) -> [CGPoint] {
        // Retrieve all points
        guard let recognizedLandmarks = observation.landmarks else {
            return []
        }
        
        return recognizedLandmarks.allPoints?.normalizedPoints ?? []
    }
    
}
