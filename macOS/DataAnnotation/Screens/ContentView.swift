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
            SimpleView(viewModel: .init())
        }
        .frame(minWidth: 1000, minHeight: 600)
        .navigationTitle("Pose Data Annotator")
    }

    var content: some View {
        List {
            NavigationLink(destination: SimpleView(viewModel: .init())) {
                Label("One by one", systemImage: "book.closed")
            }
            NavigationLink(destination: EmptyView()) {
                Label("Entire dataset", systemImage: "list.bullet.rectangle")
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
