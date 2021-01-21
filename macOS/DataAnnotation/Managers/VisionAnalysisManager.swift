//
//  VisionAnalysisManager.swift
//  SLR data annotation
//
//  Created by Matyáš Boháček on 01/12/2020.
//  Copyright © 2020 Matyáš Boháček. All rights reserved.
//

import Foundation
import Cocoa
import Vision

typealias KeyBodyLandmarks = [[[VNHumanBodyPoseObservation.JointName: VNPoint]]]
typealias KeyHandLandmarks = [[[VNHumanHandPoseObservation.JointName: VNPoint]]]
typealias KeyFaceLandmarks = [[[CGPoint]]]

class VisionAnalysisManager {

    // MARK: Properties

    private let videoProcessingManager: VideoProcessingManager

    private let videoUrl: URL
    private var framesAnnotated = [[String: Bool]]()
    private var frames = [CGImage]()

    private(set) var fps: Int
    private(set) var videoSize = CGSize()

    lazy private var keyBodyLandmarks = KeyBodyLandmarks()
    lazy private var keyHandLandmarks = KeyHandLandmarks()
    lazy private var keyFaceLandmarks = KeyFaceLandmarks()

    lazy var queue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "VisionAnalysisManager"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    // MARK: Methods

    ///
    /// Initiates the VisionAnalysisManager which is responsible for the Vision analysis and annotation of any
    /// given video.
    ///
    /// - Parameters:
    ///   - videoUrl: URL of the video to be annotated
    ///   - fps: Frames per second to be annotated
    ///
    init(videoUrl: URL,
         fps: Int = UserDefaults.standard.integer(forKey: "fps"),
         videoProcessingManager: VideoProcessingManager = .init()) {
        self.videoUrl = videoUrl
        self.fps = fps
        self.videoProcessingManager = videoProcessingManager
    }

    ///
    /// Starts the asynchronous process of annotation with the data associated to this VisionAnalysisManager.
    ///
    public func annotate() {
        // Generate the individual frames from the vido
        frames = videoProcessingManager.getAllFrames(videoUrl: self.videoUrl, fps: self.fps)

        framesAnnotated = Array.init(repeating: ["body": false, "hands": false, "face": false], count: self.frames.count)

        // Calculate the size of the video
        videoSize = videoProcessingManager.getVideoSize(videoUrl: self.videoUrl)

        for frame in frames {
            // Create a VNImageRequestHandler for each of the desired frames
            let handler = VNImageRequestHandler(cgImage: frame, options: [:])

            // Process the Vision data for all of the

            queue.addOperation {
                self.invokeBodyPoseDetection(handler: handler)
                self.invokeHandPoseDetection(handler: handler)
                self.invokeFaceLandmarksDetection(handler: handler)
            }
        }

        queue.waitUntilAllOperationsAreFinished()
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
    public func getData() -> (KeyBodyLandmarks, KeyHandLandmarks, KeyFaceLandmarks) {
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
            for result in frameStatus where result.value == false {
                return false
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
        DispatchQueue.global(qos: .userInitiated).sync {
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
                request.results?.first as? VNHumanBodyPoseObservation else {
            // Prevent from crashing once face is visible only for certain parts of the record
            // TODO: Consider other filling options than just zeros
            self.keyBodyLandmarks.append([[VNHumanBodyPoseObservation.JointName: VNPoint]]())
            self.framesAnnotated[self.keyBodyLandmarks.count - 1]["body"] = true
            
            return
        }

        // Process each observation to find the recognized body landmarks
        var result = [[VNHumanBodyPoseObservation.JointName: VNPoint]]()
        result.append(processBodyPoseObservation(observations))

        self.keyBodyLandmarks.append(result)
        self.framesAnnotated[self.keyBodyLandmarks.count - 1]["body"] = true
    }

    func processBodyPoseObservation(_ observation: VNHumanBodyPoseObservation) -> [VNHumanBodyPoseObservation.JointName: VNPoint] {
        // Retrieve all points
        guard let recognizedPoints = try? observation.recognizedPoints(.all) else {
            return [:]
        }

        var keyBodyLandmarks = [VNHumanBodyPoseObservation.JointName: VNPoint]()
        let requestedBodyLandmarks = ObservationConfiguration.requestedBodyLandmarks

        // Process all of the recognized landmarks
        for (key, point) in recognizedPoints where point.confidence > MachineLearningConfiguration.bodyPoseDetectionThreshold {
            // Keep the point for further analysis if relevant
            if (requestedBodyLandmarks.contains(key)) || requestedBodyLandmarks.isEmpty {
                keyBodyLandmarks[key] = point
            }
        }
        
        // Ensure that all landmark keys are present, otherwise fill in a zero
        // TODO: Consider other filling options than just zeros
        for key in requestedBodyLandmarks {
            for key in requestedBodyLandmarks where keyBodyLandmarks[key] == nil {
                keyBodyLandmarks[key] = VNPoint()
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
        DispatchQueue.global(qos: .userInitiated).sync {
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
        guard let observations = request.results?.first as? VNHumanHandPoseObservation else {
            // Prevent from crashing once hands are visible only for certain parts of the record
            // TODO: Consider other filling options than just zeros
            self.keyHandLandmarks.append([[VNHumanHandPoseObservation.JointName: VNPoint]]())
            self.framesAnnotated[self.keyHandLandmarks.count - 1]["hands"] = true
            
            return
        }

        // Process each observation to find the recognized hand landmarks
        var result = [[VNHumanHandPoseObservation.JointName: VNPoint]]()
        result.append(processHandPoseObservation(observations))

        self.keyHandLandmarks.append(result)
        self.framesAnnotated[self.keyHandLandmarks.count - 1]["hands"] = true
    }

    func processHandPoseObservation(_ observation: VNHumanHandPoseObservation) -> [VNHumanHandPoseObservation.JointName: VNPoint] {
        // Retrieve all points.
        guard let recognizedPoints = try? observation.recognizedPoints(.all) else {
            return [:]
        }

        var keyHandLandmarks = [VNHumanHandPoseObservation.JointName: VNPoint]()
        let requestedHandLandmarks = ObservationConfiguration.requestedHandLandmarks

        // Process all of the recognized landmarks
        for (key, point) in recognizedPoints where point.confidence > MachineLearningConfiguration.handPoseDetectionThreshold {
            // Keep the point for further analysis if relevant
            if (requestedHandLandmarks.contains(key)) || requestedHandLandmarks.isEmpty {
                keyHandLandmarks[key] = point
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
        DispatchQueue.global(qos: .userInitiated).sync {
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
        guard let observations = request.results?.first as? VNFaceObservation else {
            // Prevent from crashing once face is visible only for certain parts of the record
            // TODO: Consider other filling options than just zeros
            self.keyFaceLandmarks.append([[CGPoint]]())
            self.framesAnnotated[self.keyFaceLandmarks.count - 1]["face"] = true
            
            return
        }

        // Process each observation to find the recognized face landmarks
        var result = [[CGPoint]]()
        result.append(processFaceLandmarksObservation(observations))

        self.keyFaceLandmarks.append(result)
        self.framesAnnotated[self.keyFaceLandmarks.count - 1]["face"] = true
    }

    func processFaceLandmarksObservation(_ observation: VNFaceObservation) -> [CGPoint] {
        // Retrieve all points
        guard let recognizedLandmarks = observation.landmarks else { return [] }
        return recognizedLandmarks.allPoints?.normalizedPoints ?? []
    }

}
