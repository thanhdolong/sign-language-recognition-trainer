//
//  GeneralSettingsView.swift
//  DataAnnotation
//
//  Created by Matyáš Boháček on 07.01.2021.
//

import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage(ObservationType.handLandmarks.rawValue) private var outputHandsLandmarks: Bool = true
    @AppStorage(ObservationType.bodyLandmarks.rawValue) private var outputBodyLandmarks: Bool = true
    @AppStorage(ObservationType.faceLandmarks.rawValue) private var outputFaceLandmarks: Bool = true
    
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

