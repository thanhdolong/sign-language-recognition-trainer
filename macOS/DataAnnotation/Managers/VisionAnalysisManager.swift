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
    public func annotate(_ completion: @escaping () -> ()) {
        // Generate the individual frames from the vido
        frames = videoProcessingManager.getAllFrames(videoUrl: self.videoUrl, fps: self.fps)

        framesAnnotated = Array.init(repeating: ["body": false, "hands": false, "face": false], count: self.frames.count)

        // Calculate the size of the video
        videoSize = videoProcessingManager.getVideoSize(videoUrl: self.videoUrl)

        var operations: [Operation] = []
        
        let finishedAnnotationOp = BlockOperation {
            completion()
        }
        
        for frame in frames {
            // Create a VNImageRequestHandler for each of the desired frames
            let handler = VNImageRequestHandler(cgImage: frame, options: [:])

            // Process the Vision data for all of the
            
            let videoAnnotateOp = VideoAnnotateOperation(
                keyBodyLandmarks: keyBodyLandmarks,
                keyHandLandmarks: keyHandLandmarks,
                keyFaceLandmarks: keyFaceLandmarks,
                framesAnnotated: framesAnnotated,
                handler: handler)
            finishedAnnotationOp.addDependency(videoAnnotateOp)
            operations.append(videoAnnotateOp)
        }
        
        operations.insert(finishedAnnotationOp, at: 0)
        queue.addOperations(operations, waitUntilFinished: false)

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
}
