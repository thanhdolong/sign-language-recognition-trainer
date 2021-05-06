//
//  AnotateVideoView.swift
//  SLR data annotation
//
//  Created by Thành Đỗ Long on 15.12.2020.
//

import SwiftUI
import AVKit

struct AnotateVideoView: View {
    @ObservedObject private(set) var viewModel: ViewModel

    var body: some View {
        VStack {

            Spacer()

            ZStack {
                if let url = viewModel.selectedVideoUrl {
                    VideoPlayer(player: AVPlayer(url: url))
                } else {
                    Text("Drag and drop video file")
                }
            }
            .onTapGesture { viewModel.selectFile() }
            .onDrop(of: ["public.file-url"],
                    isTargeted: nil,
                    perform: viewModel.handleOnDrop(providers:))
            .modifier(CardViewModifier())

            if let nameVideoUrl = viewModel.nameVideoUrl {
                Text(nameVideoUrl)
            }

            Spacer()

            HStack(alignment: .bottom, spacing: 32.0) {
                Button(action: viewModel.selectFile) {
                    Text("Load Video")
                }

                if viewModel.isStartProcessingActive {
                    Button(action: viewModel.startAnnotate) {
                        Text("Start Processing")
                    }
                }
            }
            .padding()
        }
    }
}

struct SimpleView_Previews: PreviewProvider {
    static var previews: some View {
        AnotateVideoView(viewModel: AnotateVideoView.ViewModel())
            .previewLayout(.device)
    }
}
