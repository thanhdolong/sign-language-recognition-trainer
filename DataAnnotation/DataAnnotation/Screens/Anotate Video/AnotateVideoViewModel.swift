//
//  AnotateVideoViewModel.swift
//  SLR data annotation
//
//  Created by Thành Đỗ Long on 13.12.2020.
//

import SwiftUI
import CreateML

extension AnotateVideoView {
    class ViewModel: ObservableObject {
        private let dataStructuringManager: DataStructuringManager
        private let observationConfiguration: ObservationConfiguration
        private var analysisManager: VisionAnalysisManager!

        @Published var selectedVideoUrl: URL?
        @Published var nameVideoUrl: String?

        var isStartProcessingActive: Bool { selectedVideoUrl != nil }

        init(dataStructuringManager: DataStructuringManager = .init(),
             observationConfiguration: ObservationConfiguration = .init()) {
            self.dataStructuringManager = dataStructuringManager
            self.observationConfiguration = observationConfiguration
        }

        func selectFile() {
            NSOpenPanel.openVideo { [unowned self] result in
                if case let .success(videoUrl) = result {
                    self.selectedVideoUrl = videoUrl
                    self.nameVideoUrl = videoUrl.pathComponents.elementBeforeLast
                }
            }
        }

        func startAnnotate() {
            guard let selectedVideoUrl = selectedVideoUrl,
                  let nameVideoUrl = nameVideoUrl else { fatalError("URL cannot be empty")}

            do {
                self.analysisManager = VisionAnalysisManager(videoUrl: selectedVideoUrl,
                                                             fps: 3)

                // Annotate for the necessary elements
                self.analysisManager?.annotate()

                let data = try self.dataStructuringManager.combineData(labels: [nameVideoUrl],
                                                                       visionAnalyses: [self.analysisManager])

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

                    guard Constant.allowedFileTypes.contains(url.pathExtension) else { return }
                    self.selectedVideoUrl = url
                    self.nameVideoUrl = url.pathComponents.elementBeforeLast
                }
            }
            return true
        }
    }
}
