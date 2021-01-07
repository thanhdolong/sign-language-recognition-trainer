//
//  AnotateDatasetViewModel.swift
//  DataAnnotation
//
//  Created by Thành Đỗ Long on 24.12.2020.
//

import SwiftUI
import CreateML

extension AnotateDatasetView {
    class ViewModel: ObservableObject {
        private let fileManager: FileManager
        private let dataStructuringManager: DataStructuringManager
        private let observationConfiguration: ObservationConfiguration
        private var analysisManager: VisionAnalysisManager!

        @Published var selectedFolderUrl: URL?
        @Published var subdirectories: Int = 0
        @Published var files: Int = 0

        var isStartProcessingActive: Bool { subdirectories > 0 && files > 0}

        init(fileManager: FileManager = .default,
             dataStructuringManager: DataStructuringManager = .init(),
             observationConfiguration: ObservationConfiguration = .init()) {
            self.dataStructuringManager = dataStructuringManager
            self.observationConfiguration = observationConfiguration
            self.fileManager = fileManager
        }

        func selectFile() {
            NSOpenPanel.openFolder { [unowned self] result in
                if case let .success(videoUrl) = result {
                    selectedFolderUrl = videoUrl
                    subdirectories = numberOfFolders(from: videoUrl)
                    files = numberOfFiles(from: videoUrl)
                }
            }
        }

        func startAnnotate() {
            guard let selectedFolderUrl = selectedFolderUrl else { fatalError("URL cannot be empty")}
            let datasetManager = DatasetManager(directoryPath: selectedFolderUrl.path, fps: 3)

            do {
                // Structure the data into a MLDataTable
                let data = try datasetManager.generateMLTable()

                saveCVS(data: data)
            } catch {
                print(error)
            }
        }

        func saveCVS(data: MLDataTable) {
            DispatchQueue.main.async {
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

                    do {
                        try data.writeCSV(to: url)
                    } catch {
                        print(error)
                    }
                }
            }
        }

        func handleOnDrop(providers: [NSItemProvider]) -> Bool {
            guard let item = providers.first else { return false }
            item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
                DispatchQueue.main.async {
                    guard let urlData = urlData as? Data else { return }
                    let url = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL

                    guard url.isDirectory else { return }
                    self.selectedFolderUrl = url
                    self.subdirectories = self.numberOfFolders(from: url)
                    self.files = self.numberOfFiles(from: url)
                }
            }
            return true
        }

        private func numberOfFolders(from videoUrl: URL) -> Int {
            let contentsOfDirectory = try? fileManager.contentsOfDirectory(atPath: videoUrl.path)
            return contentsOfDirectory?.filter({ $0.starts(with: ".") == false }).count ?? 0
        }

        private func numberOfFiles(from url: URL) -> Int {
            let contentsOfDirectory = try? fileManager.contentsOfDirectory(atPath: url.path)
            return contentsOfDirectory?
                .filter({ $0.starts(with: ".") == false })
                .compactMap({ subdirectory -> Int? in
                    let currentLabelPath = url.path.appending("/" + subdirectory + "/")
                    return try? fileManager.contentsOfDirectory(atPath: currentLabelPath)
                        .filter({ $0.starts(with: ".") == false })
                        .count
                })
                .reduce(0, +) ?? 0
        }
    }
}
