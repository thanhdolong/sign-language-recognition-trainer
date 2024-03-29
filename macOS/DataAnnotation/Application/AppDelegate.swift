//
//  DataAnnotationApp.swift
//  DataAnnotation
//
//  Created by Thành Đỗ Long on 15.12.2020.
//

import SwiftUI

@main
struct DataAnnotationApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: {
                    ObservationType.allCases.forEach { observationType in
                        if UserDefaults.standard.object(forKey: observationType.rawValue) == nil {
                            UserDefaults.standard.setValue(true, forKey: observationType.rawValue)
                        }
                    }
                })
        }
        
        Settings {
            SettingsView()
        }
    }
}
