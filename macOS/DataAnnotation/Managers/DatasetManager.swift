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
        var analysesManagers = [VisionAnalysisManager]()
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 32
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
                let output = try outputDataStructuringManager.combineData(labels: labels, visionAnalyses: analysesManagers)
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

                        // Load and process the annotations for each of the videos
                        let currentItemAnalysisManager = VisionAnalysisManager(videoUrl: URL(fileURLWithPath: currentLabelPath.appending(item)),
                                                                               fps: self.fps)
                        
                        let videoAnalysisOp = VideoAnalysisOperation(visionAnalysisManager: currentItemAnalysisManager)
                        operations.append(videoAnalysisOp)
                        videoAnalysisFinishedOp.addDependency(videoAnalysisOp)
                        
                        analysesManagers.append(currentItemAnalysisManager)
                        labels.append(subdirectory)
                    }
            }
        } catch {
            completion(.failure(error))
        }
        
        operations.append(videoAnalysisFinishedOp)
        print("READY")
        queue.addOperations(operations, waitUntilFinished: false)
    }
}
