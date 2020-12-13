//
//  ContentViewModel.swift
//  SLR data annotation
//
//  Created by Thành Đỗ Long on 13.12.2020.
//

import SwiftUI

extension SimpleView {
    class ViewModel: ObservableObject {

        private let dataStructuringManager: DataStructuringManager
        private let observationConfiguration: ObservationConfiguration
        private var analysisManager: VisionAnalysisManager?

        private(set) var selectedVideoUrl: URL?

        init(dataStructuringManager: DataStructuringManager = .init(),
             observationConfiguration: ObservationConfiguration = .init()) {
            self.dataStructuringManager = dataStructuringManager
            self.observationConfiguration = observationConfiguration
        }

        func selectFile() {
            NSOpenPanel.openVideo { [unowned self] result in
                if case let .success(videoUrl) = result {
                    self.selectedVideoUrl = videoUrl

                    // Load the video into the VisionAnalysisManager
                    self.analysisManager = VisionAnalysisManager(videoUrl: videoUrl,
                                                                 fps: 3)
                }
            }
        }

        func startAnnotate() {
            // Annotate for the necessary elements
            self.analysisManager?.annotate()
        }

        func saveCVS() {
            let savePanel = NSSavePanel()
            savePanel.canCreateDirectories = true
            savePanel.nameFieldStringValue = "result.csv"
            savePanel.showsTagField = false
            savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
            savePanel.begin { [unowned self] result in
                guard result == .OK, let url = savePanel.url else {
                    print("Failed to get file location")
                    return
                }

                self.writeCVS(videoUrl: url, fps: 3, label: "1")
            }
        }

        private func writeCVS(videoUrl datasetPath: URL, fps: Int, label: String) {
            guard let analysisManager = analysisManager else { return }

            do {
                let dataTable = try dataStructuringManager.combineData(labels: [label], visionAnalyses: [analysisManager])

                // Save it to Desktop folder in CSV
                try dataTable.writeCSV(to: datasetPath)
            } catch {
                print(error)
            }
        }
    }
}
