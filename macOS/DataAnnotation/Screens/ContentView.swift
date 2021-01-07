//
//  ContentView.swift
//  SLR data annotation
//
//  Created by Thành Đỗ Long on 12.12.2020.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            content
                .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
            AnotateVideoView(viewModel: .init())
        }
        .frame(minWidth: 1000, minHeight: 600)
        .navigationTitle("Pose Data Annotator")
    }

    var content: some View {
        List {
            NavigationLink(destination: AnotateVideoView(viewModel: .init())) {
                Label("Anotate video", systemImage: "book.closed")
            }
            NavigationLink(destination: AnotateDatasetView(viewModel: .init())) {
                Label("Anotate dataset", systemImage: "list.bullet.rectangle")
            }
        }
        .listStyle(SidebarListStyle())
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
