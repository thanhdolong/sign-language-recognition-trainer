//
//  ContentView.swift
//  SLR data annotation
//
//  Created by Thành Đỗ Long on 12.12.2020.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private(set) var viewModel: ViewModel

    var body: some View {
        VStack {
            Button(action: viewModel.selectFile) {
                Text("Select")
            }

            Button(action: viewModel.startAnnotate) {
                Text("Start")
            }

            Button(action: viewModel.saveCVS) {
                Text("Save")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentView.ViewModel())
    }
}
