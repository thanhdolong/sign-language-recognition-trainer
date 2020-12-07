import Cocoa
import Foundation
import CreateML


//
// Demonstration of the annotations script. The video is analyzed for all of the relevant
// key landmarks and this data is further structured into a CSV file.
//
// TODO: Update the Vision keys to new, non-deprecated values
//


// Path to dataset
let fileManager = FileManager.default
var datasetPath = ((NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true) as [String]).first ?? "").appending("/dictio_cislovky")


/*
// OPTION 1: PROCESSING ONE BY ONE


// Experimental label and URL to one of the videos
let labels = ["test"]
let videoUrl = URL(fileURLWithPath: "/Users/matyasbohacek/Desktop/dictio_cislovky/1/A_11.mp4")

// Load the video into the VisionAnalysisManager
let analysisManager = VisionAnalysisManager(videoUrl: videoUrl, fps: 3)

// Annotate for the necessary elements
analysisManager?.annotate()

do {
    // Structure the data into a MLDataTable
    let dataTable = try OutputDataStructuringManager.combineData(labels: labels, visionAnalyses: [analysisManager!])
    
    // Save it to Desktop folder in CSV
    try dataTable.writeCSV(to: URL(fileURLWithPath: datasetPath).appendingPathComponent("individual_test.csv"))
} catch {}
*/

// OPTION 2: PROCESSING THE ENTIRE DATASET


// Create a dataset manager to process the entire dataset
let datasetManager = DatasetManager(directoryPath: datasetPath, fps: 3)

do {
    // Structure the data into a MLDataTable
    let dataTable = try datasetManager!.generateMLTable()
    
    // Save it to Desktop folder in CSV
    try dataTable.writeCSV(to: URL(fileURLWithPath: datasetPath).appendingPathComponent("dataset_test.csv"))
} catch {
    print(error)
}
