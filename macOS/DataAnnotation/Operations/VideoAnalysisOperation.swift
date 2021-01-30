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
    let completion: (() -> ())?
    
    init(visionAnalysisManager: VisionAnalysisManager,
         completion: (() -> ())? = nil) {
        self.visionAnalysisManager = visionAnalysisManager
        self.completion = completion
    }
    
    override func main() {
        self.visionAnalysisManager.annotate {
            self.completion?()
            self.state = .Finished
        }
    }
}

class VideoAnnotateOperation: AsyncOperation {
    var keyBodyLandmarks: KeyBodyLandmarks
    var keyHandLandmarks: KeyHandLandmarks
    var keyFaceLandmarks: KeyFaceLandmarks
    var framesAnnotated = [[String: Bool]]()
    let handler: VNImageRequestHandler
    
    let queue: OperationQueue = .init()
    
    init(keyBodyLandmarks: KeyBodyLandmarks,
         keyHandLandmarks: KeyHandLandmarks,
         keyFaceLandmarks: KeyFaceLandmarks,
         framesAnnotated: [[String: Bool]],
         handler: VNImageRequestHandler) {
        self.keyBodyLandmarks = keyBodyLandmarks
        self.keyHandLandmarks = keyHandLandmarks
        self.keyFaceLandmarks = keyFaceLandmarks
        self.framesAnnotated = framesAnnotated
        self.handler = handler
    }
    
    override func main() {
        let bodyOperation = BlockOperation {
            self.invokeBodyPoseDetection(handler: self.handler)
        }
        
        let handOperation = BlockOperation {
            self.invokeHandPoseDetection(handler: self.handler)
        }
        
        let faceOperation = BlockOperation {
            self.invokeFaceLandmarksDetection(handler: self.handler)
        }
        
        let finishedOperation = BlockOperation {
            self.state = .Finished
        }
        
        finishedOperation.addDependency(bodyOperation)
        finishedOperation.addDependency(handOperation)
        finishedOperation.addDependency(faceOperation)
        
        queue.addOperations([finishedOperation, bodyOperation, handOperation, faceOperation], waitUntilFinished: false)
        
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
