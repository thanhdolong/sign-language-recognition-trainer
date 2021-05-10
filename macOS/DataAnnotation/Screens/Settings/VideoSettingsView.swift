//
//  VideoSettingsView.swift
//  DataAnnotation
//
//  Created by Matyáš Boháček on 07.01.2021.
//

import SwiftUI

struct VideoSettingsView: View {
    @AppStorage("fps") private var fps: Int = 1

    var body: some View {
        Form {
            HStack {
                Stepper("Frames per second", value: $fps, in: 1...60)
                Text("\(fps)")
            }
        }
        .padding()
    }
}
