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
    func generateMLTable() throws -> MLDataTable {
        var foundSubdirectories = [String]()
        var labels = [String]()
        var analysesManagers = [VisionAnalysisManager]()

        do {
            // Load all of the labels present in the dataset
            foundSubdirectories = try fileManager.contentsOfDirectory(atPath: self.directoryPath)
        } catch {
            throw DatasetError.invalidDirectoryContents
        }

        // Create annotations managers for each of the labels
        do {
            for subdirectory in foundSubdirectories {
                if subdirectory.starts(with: ".") {
                    continue
                }

                // Construct the URL path for each of the labels (items of the repository)
                let currentLabelPath = self.directoryPath.appending("/" + subdirectory + "/")

                for item in try fileManager.contentsOfDirectory(atPath: currentLabelPath) {
                    // Prevent from non-video formats
                    if !item.contains(".mp4") {
                        // TODO: Throw
                    }

                    // Load and process the annotations for each of the videos
                    let currentItemAnalysisManager = VisionAnalysisManager(videoUrl: URL(fileURLWithPath: currentLabelPath.appending(item)),
                                                                           fps: self.fps)
                    currentItemAnalysisManager.annotate()

                    analysesManagers.append(currentItemAnalysisManager)
                }

                labels.append(subdirectory)
            }
        } catch {
            throw error
        }

        do {
            // Structure the data into a MLDataTable
            let outputDataStructuringManager = DataStructuringManager()
            return try outputDataStructuringManager.combineData(labels: labels, visionAnalyses: analysesManagers)
        } catch {
            throw error
        }
    }

}
