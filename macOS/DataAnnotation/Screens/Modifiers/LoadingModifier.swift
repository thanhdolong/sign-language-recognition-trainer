//
//  LoadingModifier.swift
//  DataAnnotation
//
//  Created by Thành Đỗ Long on 07.05.2021.
//

import SwiftUI

struct LoadingModifier: ViewModifier {
    @Binding var showLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if showLoading {
                LoadingView()
            }
        }
    }
}
