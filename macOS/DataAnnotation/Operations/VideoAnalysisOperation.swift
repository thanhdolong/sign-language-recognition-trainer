//
//  VideoAnalysisOperation.swift
//  DataAnnotation
//
//  Created by Rastislav Červenák on 17.01.2021.
//

import Foundation
import Vision

class VideoAnalysisOperation: AsyncOperation {
    let visionAnalysisManager: VisionAnalysisManager
    let completion: ((VisionAnalysisResult) -> ())?
    
    init(visionAnalysisManager: VisionAnalysisManager,
         completion: ((VisionAnalysisResult) -> ())? = nil) {
        self.visionAnalysisManager = visionAnalysisManager
        self.completion = completion
    }
    
    override func main() {
        self.visionAnalysisManager.annotate {
            let result = VisionAnalysisResult(
                keyLandmarks: self.visionAnalysisManager.keyLandmarks,
                videoSize: self.visionAnalysisManager.videoSize,
                fps: self.visionAnalysisManager.fps)
            self.completion?(result)
            self.state = .Finished
        }
    }
}

class VideoAnnotateOperation: AsyncOperation {
    var keyLandmarks: KeyLandmarks
    let handler: VNImageRequestHandler
    let queue: OperationQueue = .init()
    let completion: (() -> ())?
    
    init(frame: CGImage,
         keyLandmarks: KeyLandmarks,
         options: [VNImageOption : Any] = [:],
         completion: (() -> ())? = nil) {
        self.completion = completion
        self.keyLandmarks = keyLandmarks
        self.handler = VNImageRequestHandler(cgImage: frame, options: options)
    }
    
    override func main() {
        DispatchQueue.global(qos: .default).async {
            self.invokeBodyPoseDetection(handler: self.handler)
            self.invokeHandPoseDetection(handler: self.handler)
            self.invokeFaceLandmarksDetection(handler: self.handler)
            self.completion?()
            self.state = .Finished
        }
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
//        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Setup the request
                let bodyDetectionRequest = VNDetectHumanBodyPoseRequest(completionHandler: self.retrieveBodyPoseDetectionResults)

                // Perform the request
                try handler.perform([bodyDetectionRequest])
            } catch {
                print("! \(error)")
            }
//        }
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
            return self.keyLandmarks.body.append([[VNHumanBodyPoseObservation.JointName: VNPoint]]())
        }

        // Process each observation to find the recognized body landmarks
        var result = [[VNHumanBodyPoseObservation.JointName: VNPoint]]()
        result.append(processBodyPoseObservation(observations))

        self.keyLandmarks.body.append(result)
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
        for key in requestedBodyLandmarks where keyBodyLandmarks[key] == nil {
            keyBodyLandmarks[key] = VNPoint()
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
//        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Setup the request
                let handDetectionRequest = VNDetectHumanHandPoseRequest(completionHandler: self.retrieveHandPoseDetectionResults)
                handDetectionRequest.maximumHandCount = 2

                // Perform the request
                try handler.perform([handDetectionRequest])
            } catch {
                print("! \(error)")
            }
//        }
    }

    /// Retrieves results from ML analysis of hand pose detection, including the relevant joints and their
    /// probabilities.
    ///
    /// - Parameters:
    ///   - request: Initial request updated with the results
    ///   - error: Possible error occuring during the analysis
    ///
    func retrieveHandPoseDetectionResults(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanHandPoseObservation] else {
            // Prevent from crashing once hands are visible only for certain parts of the record
            // TODO: Consider other filling options than just zeros
            return self.keyLandmarks.hand.append([[VNHumanHandPoseObservation.JointName: VNPoint]]())
        }

        // Process each observation to find the recognized hand landmarks
        var result = [[VNHumanHandPoseObservation.JointName: VNPoint]]()
        observations.forEach { observation in
            result.append(processHandPoseObservation(observation))
        }
        
        self.keyLandmarks.hand.append(result)
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
        
        
        // Ensure that all landmark keys are present, otherwise fill in a zero
        // TODO: Consider other filling options than just zeros
        for key in requestedHandLandmarks where keyHandLandmarks[key] == nil {
            keyHandLandmarks[key] = VNPoint()
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
//        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Setup the request
                let faceLandmarksDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: self.retrieveFaceLandmarksDetectionResults)
                // Perform the request
                try handler.perform([faceLandmarksDetectionRequest])
            } catch {
                print("! \(error)")
            }
//        }
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
            return self.keyLandmarks.face.append([[CGPoint]]())
        }

        // Process each observation to find the recognized face landmarks
        var result = [[CGPoint]]()
        result.append(processFaceLandmarksObservation(observations))

        self.keyLandmarks.face.append(result)
    }

    func processFaceLandmarksObservation(_ observation: VNFaceObservation) -> [CGPoint] {
        // Retrieve all points
        guard let recognizedLandmarks = observation.landmarks else { return [] }
        return recognizedLandmarks.allPoints?.normalizedPoints ?? []
    }
}
