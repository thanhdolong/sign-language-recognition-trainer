//
//  ContentView.swift
//  SLR data annotation
//
//  Created by Thành Đỗ Long on 12.12.2020.
//

import SwiftUI

struct ContentView: View {
//    var datasetPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop")
    var videoUrl: URL?
    let observationConfiguration: ObservationConfiguration = ObservationConfiguration()

    var body: some View {
        return contentView()
    }

    func contentView() -> some View {
        VStack {
            Button(action: selectFile) {
                Text("Select")
            }

            Button(action: saveToFile) {
                Text("Save")
            }
        }
    }

    func loremIpsum(url datasetPath: URL) {
        let labels = ["test"]
        let videoUrl = URL(fileURLWithPath: "/Users/thanhdolong/Desktop/dictio_cislovky/1/A_11.mp4")

        // Load the video into the VisionAnalysisManager
        let analysisManager = VisionAnalysisManager(videoUrl: videoUrl,
                                                    fps: 3,
                                                    observationConfiguration: observationConfiguration)

        // Annotate for the necessary elements
        analysisManager.annotate()

        do {
            // Structure the data into a MLDataTable
            let outputDataStructuringManager = DataStructuringManager(observationConfiguration: observationConfiguration)
            let dataTable = try outputDataStructuringManager.combineData(labels: labels, visionAnalyses: [analysisManager])

            // Save it to Desktop folder in CSV
            try dataTable.writeCSV(to: datasetPath)
        } catch {
            print(error)
        }
    }

    private func selectFile() {
        NSOpenPanel.openVideo { (result) in
            if case let .success(url) = result {
                print(url)
            }
        }
    }

    private func saveToFile() {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "result.csv"
        savePanel.showsTagField = false
        savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
        savePanel.begin { result in
            guard result == .OK, let url = savePanel.url else {
                print("Failed to get file location")
                return
            }

            loremIpsum(url: url)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
