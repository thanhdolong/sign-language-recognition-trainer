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
            VideoPlayer(player: AVPlayer(url:  URL(string: "https://bit.ly/swswift")!))

            Spacer()

            HStack(alignment: .bottom, spacing: 32.0) {
                Button(action: viewModel.selectFile) {
                    Text("Load Video")
                }

                Button(action: viewModel.startAnnotate) {
                    Text("Start processing")
                }

                Button(action: viewModel.saveCVS) {
                    Text("Save CSV file")
                }
            }
            .padding()
        }
    }
}

struct SimpleView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleView(viewModel: SimpleView.ViewModel())
            .previewLayout(.device)
    }
}
