//
//  CardViewModifier.swift
//  DataAnnotation
//
//  Created by Thành Đỗ Long on 06.05.2021.
//

import SwiftUI

struct CardViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .foregroundColor(.white)
            .frame(width: 480, height: 480, alignment: .center)
            .background(Color.black.opacity(0.8))
            .cornerRadius(8)
            .shadow(color: .black,
                    radius: 10)
    }
}
