//
//  SettingsView.swift
//  DataAnnotation
//
//  Created by Matyáš Boháček on 07.01.2021.
//

import SwiftUI

struct SettingsView: View {
    private enum Tabs: Hashable {
        case general, video, analysis
    }
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
            VideoSettingsView()
                .tabItem {
                    Label("Video", systemImage: "video.fill")
                }
                .tag(Tabs.video)
            AnalysisSettingsView()
                .tabItem {
                    Label("Analysis", systemImage: "figure.wave")
                }
                .tag(Tabs.analysis)
        }
        .padding(20)
        .frame(width: 450, height: 200)
        .navigationTitle("Preferences")
    }
}
