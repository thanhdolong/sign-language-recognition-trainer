//
//  SimpleView.swift
//  SLR data annotation
//
//  Created by Thành Đỗ Long on 15.12.2020.
//

import SwiftUI
import AVKit

struct SimpleView: View {
    @ObservedObject private(set) var viewModel: ViewModel

    var body: some View {
        VStack {
            ZStack {
                if let url = viewModel.selectedVideoUrl {
                    VideoPlayer(player: AVPlayer(url: url))
                } else {
                    Text("Drag and drop video file")
                }
            }
            .frame(width: 320, height: 320, alignment: .center)
            .background(Color.black.opacity(0.5))
            .cornerRadius(8)

            .onDrop(of: ["public.file-url"], isTargeted: nil, perform: handleOnDrop(providers:))
            Spacer()

            HStack(alignment: .bottom, spacing: 32.0) {
                Button(action: viewModel.selectFile) {
                    Text("Load Video")
                }

                if viewModel.selectedVideoUrl != nil {
                    Button(action: viewModel.startAnnotate) {
                        Text("Start processing")
                    }
                }
            }
            .padding()
        }
    }

    private func handleOnDrop(providers: [NSItemProvider]) -> Bool {
        guard let item = providers.first else { return false }
        item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
            DispatchQueue.main.async {
                guard let urlData = urlData as? Data else { return }
                let url = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL

                guard Constant.allowedFileTypes.contains(url.pathExtension) else { return }
                self.viewModel.selectedVideoUrl = url
            }
        }
        return true
    }
}

struct SimpleView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleView(viewModel: SimpleView.ViewModel())
            .previewLayout(.device)
    }
}
