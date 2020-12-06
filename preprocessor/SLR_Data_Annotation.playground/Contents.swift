import Cocoa
import Foundation
import CreateML


//
// Demonstration of the annotations script. The video is analyzed for all of the relevant
// key landmarks and this data is further structured into a CSV file.
//
// TODO: Implement a structure for "soaking" entire structured directories with automatic
// labelling
// TODO: Update the Vision keys to new, non-deprecated values
// TODO: Add information on FPS and video size into the CSV files
//


// Path to desktop
let fileManager = FileManager.default
var desktopPath = ((NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true) as [String]).first ?? "")

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
    try dataTable.writeCSV(to: URL(fileURLWithPath: desktopPath).appendingPathComponent("test.csv"))
} catch {}

