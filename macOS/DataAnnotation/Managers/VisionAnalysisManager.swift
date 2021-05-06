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

struct KeyLandmarks {
    var body = KeyBodyLandmarks()
    var hand = KeyHandLandmarks()
    var face = KeyFaceLandmarks()
}

struct VisionAnalysisResult {
    let keyLandmarks : KeyLandmarks
    let videoSize: CGSize
    let fps: Int
}

final class VisionAnalysisManager {

    // MARK: Properties
    
    private let videoUrl: URL
    private var frames = [CGImage]()

    private(set) var fps: Int
    private(set) var videoSize = CGSize()

    var keyLandmarks = KeyLandmarks()
    var operations: [Operation] = []

    lazy var queue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "VisionAnalysisManager"
        queue.maxConcurrentOperationCount = .max
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
         fps: Int = UserDefaults.standard.integer(forKey: "fps")) {
        self.videoUrl = videoUrl
        self.fps = fps
    }

    ///
    /// Starts the asynchronous process of annotation with the data associated to this VisionAnalysisManager.
    ///
    public func annotate(_ completion: @escaping () -> ()) {
        // Generate the individual frames from the vido
        frames = VideoProcessingManager.getAllFrames(videoUrl: self.videoUrl, fps: self.fps)

        // Calculate the size of the video
        videoSize = VideoProcessingManager.getVideoSize(videoUrl: self.videoUrl)
        
        let finishedAnnotationOp = BlockOperation {
            self.operations.removeAll()
            completion()
        }
        
        frames.forEach { frame in
            let videoAnnotateOp = VideoAnnotateOperation(
                frame: frame) { landmarks in
                self.keyLandmarks = landmarks
            }
            operations.append(videoAnnotateOp)
        }
        
        if let lastOp = operations.last {
            finishedAnnotationOp.addDependency(lastOp)
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
        (self.keyLandmarks.body, self.keyLandmarks.hand, self.keyLandmarks.face)
    }
}
