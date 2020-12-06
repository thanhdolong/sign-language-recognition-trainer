//
//  OutputDataStructuringManager.swift
//  SLR_Data_Annotation
//
//  Created by Matyáš Boháček on 01/12/2020.
//  Copyright © 2020 Matyáš Boháček. All rights reserved.
//

import Foundation
import CreateML

public class OutputDataStructuringManager {
    
    ///
    /// Representations of the possible errors occuring
    ///
    enum OutputProcessingError: Error {
        case invalidData
        case structuringData
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
    public static func combineData(labels: [String], visionAnalyses: [VisionAnalysisManager]) throws -> MLDataTable {
        // Ensure that the data is equally long
        guard labels.count == visionAnalyses.count else {
            throw OutputProcessingError.invalidData
        }
        
        // Prepare the structured data in the MLDataTable-processable format
        var convertedToMLData = [String: MLDataValueConvertible]()
        convertedToMLData["labels"] = labels
        
        // Stack the data from individual analyses to arrays
        var stackedData = [String: [[Double]]]()
        for key in ObservationTerminology.bodyLandmarksKeyOrder + ObservationTerminology.handLandmarksKeyOrder + ObservationTerminology.faceLandmarksKeyOrder {
            stackedData[key] = []
        }
        
        for analysis in visionAnalyses {
            let analyzedData = analysis.getData()
            
            // Append data for body landmarks
            if ObservationConfiguration.desiredDataAnnotations.contains(.bodyLandmarks) {
                for (key, value) in DataStructuringManager.convertBodyLandmarksToMLData(recognizedLandmarks: analyzedData.0) {
                    stackedData[key]?.append(value)
                }
            }
            
            // Append data for hand landmarks
            if ObservationConfiguration.desiredDataAnnotations.contains(.handLandmarks) {
                for (key, value) in DataStructuringManager.convertHandLandmarksToMLData(recognizedLandmarks: analyzedData.1) {
                    stackedData[key]?.append(value)
                }
            }
            
            // Append data for face landmarks
            if ObservationConfiguration.desiredDataAnnotations.contains(.faceLandmarks) {
                for (key, value) in DataStructuringManager.convertFaceLandmarksToMLData(recognizedLandmarks: analyzedData.2) {
                    stackedData[key]?.append(value)
                }
            }
        }
        
        for (key, value) in stackedData {
            if !value.isEmpty {
                convertedToMLData[key] = value
            }
        }
        
        do {
            // Create a MLDataTable on top of the structured data
            return try MLDataTable(dictionary: convertedToMLData)
        } catch {
            throw OutputProcessingError.structuringData
        }
    }
    
}
