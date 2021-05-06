//
//  DatasetManager.swift
//  SLR data annotation
//
//  Created by Matyáš Boháček on 07/12/2020.
//  Copyright © 2020 Matyáš Boháček. All rights reserved.
//

import Foundation
import Cocoa
import CreateML

class DatasetManager {

    ///
    /// Representations of the possible errors occuring in this context
    ///
    enum DatasetError: Error {
        case invalidDirectoryContents
        case unsupportedFormat
    }

    // MARK: Properties

    private let directoryPath: String
    private let fps: Int
    private let fileManager: FileManager
    
    lazy var queue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "DatasetManager"
        queue.maxConcurrentOperationCount = 5
        return queue
    }()

    // MARK: Methods

    ///
    /// Initiates the DatasetManager for easy data processing and annotations of complete dataset directories.
    ///
    /// - Parameters:
    ///   - directoryPath: String path of the dataset directory
    ///   - fps: Frames per second to be annotated by the individual videos
    ///
    init(directoryPath: String,
         fps: Int,
         fileManager: FileManager = .default) {
        self.directoryPath = directoryPath
        self.fps = fps
        self.fileManager = fileManager
    }

    ///
    /// Annotates the entire associated dataset and returns the data in a form of a MLDataTable.
    ///
    /// - Returns: MLDataTable generated from the data
    ///
    /// - Throws: Corresponding `DatasetError` or `OutputProcessingError`, based on any
    ///     errors occurring during the data processing or the annotations
    ///
    func generateMLTable(_ completion: @escaping(Result<MLDataTable, Error>) -> ()) {
        var foundSubdirectories = [String]()
        var labels = [String]()
        var analysisResult = [VisionAnalysisResult]()
        var operations: [Operation] = []
        do {
            // Load all of the labels present in the dataset
            foundSubdirectories = try fileManager.contentsOfDirectory(atPath: self.directoryPath)
        } catch {
            completion(.failure(DatasetError.invalidDirectoryContents))
        }
        
        let videoAnalysisFinishedOp = BlockOperation {
            do {
                // Structure the data into a MLDataTable
                let outputDataStructuringManager = DataStructuringManager()
                let output = try outputDataStructuringManager.combineData(labels: labels, results: analysisResult)
                completion(.success(output))
            } catch {
                completion(.failure(error))
            }
        }
        // Create annotations managers for each of the labels
        do {
            for subdirectory in foundSubdirectories where subdirectory.contains(".") == false {
                // Construct the URL path for each of the labels (items of the repository)
                let currentLabelPath = self.directoryPath.appending("/" + subdirectory + "/")

                try fileManager.contentsOfDirectory(atPath: currentLabelPath)
                    .filter({ $0.starts(with: ".") == false })
                    .forEach { item in
                        // Prevent from non-video formats
                        guard item.contains(".mp4") else{
                            throw DatasetError.unsupportedFormat
                        }
                        let fps = fps
                        // Load and process the annotations for each of the videos
                        let currentItemAnalysisManager = VisionAnalysisManager(
                            videoUrl: URL(fileURLWithPath: currentLabelPath.appending(item)),
                            fps: fps)

                        let videoAnalysisOp = VideoAnalysisOperation(visionAnalysisManager: currentItemAnalysisManager) { result in
                            analysisResult.append(result)
                        }
                        
                        operations.append(videoAnalysisOp)
                        
                        labels.append(subdirectory)
                    }
            }
        } catch {
            completion(.failure(error))
        }
        
        if let lastOp = operations.last {
            videoAnalysisFinishedOp.addDependency(lastOp)
        }

        operations.insert(videoAnalysisFinishedOp, at: 0)
        print("READY")
        queue.addOperations(operations, waitUntilFinished: false)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
