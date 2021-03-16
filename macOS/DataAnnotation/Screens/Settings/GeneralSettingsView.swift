//
//  GeneralSettingsView.swift
//  DataAnnotation
//
//  Created by Matyáš Boháček on 07.01.2021.
//

import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("analyzeHands") private var outputHandsLandmarks = true
    @AppStorage("analyzeBody") private var outputBodyLandmarks = true
    @AppStorage("analyzeFace") private var outputFaceLandmarks = true
    
    var body: some View {
        Form {
            Text("Included body parts in output:")
            
            VStack(alignment: .leading) {
                Toggle("Hands landmarks", isOn: $outputHandsLandmarks)
                Toggle("Body landmarks", isOn: $outputBodyLandmarks)
                Toggle("Face landmarks", isOn: $outputFaceLandmarks)
            }
            .padding()
            
        }
        .padding()
    }
}

