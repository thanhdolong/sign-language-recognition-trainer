//
//  AnotateDatasetView.swift
//  DataAnnotation
//
//  Created by Thành Đỗ Long on 24.12.2020.
//

import SwiftUI

struct AnotateDatasetView: View {
    @ObservedObject private(set) var viewModel: ViewModel

    var body: some View {
        VStack {
            Spacer()

            HStack {
                if viewModel.isStartProcessingActive {
                    box(title: "Classes", subtitle: "\(viewModel.subdirectories)")
                    box(title: "Items", subtitle: "\(viewModel.files)")
                } else {
                    Text("Drag and drop dataset")
                }
            }
            .modifier(CardViewModifier())
            .onTapGesture { viewModel.selectFile() }
            .onDrop(of: ["public.file-url"],
                    isTargeted: nil,
                    perform: viewModel.handleOnDrop(providers:))

            Spacer()

            HStack(alignment: .bottom, spacing: 32.0) {
                Button(action: viewModel.selectFile) {
                    Text("Load Dataset")
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

    func box(title: String, subtitle: String) -> some View {
        VStack {
            Text(subtitle)
                .font(.title)
                .fontWeight(.semibold)

            Text(title)
        }
        .padding()
    }
}

struct ComplexView_Previews: PreviewProvider {
    static var previews: some View {
        AnotateDatasetView(viewModel: .init())  }
}
