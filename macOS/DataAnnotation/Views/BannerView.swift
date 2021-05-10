//
//  BannerView.swift
//  DataAnnotation
//
//  Created by Thành Đỗ Long on 07.05.2021.
//

import SwiftUI

struct BannerView: View {
    @State var bannerData: BannerData

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(bannerData.messageTitle)
                    .bold()
                Text(bannerData.messageContent)
                    .font(Font.system(size: 15, weight: Font.Weight.light, design: Font.Design.default))
            }
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .foregroundColor(Color.white)
        .padding(12)
        .background(bannerData.style.tintColor)
        .cornerRadius(8)
    }
}

extension BannerView {
    struct BannerData {
        let style: BannerStyle
        let messageTitle: String
        let messageContent: String
    }

    enum BannerStyle {
        case infoMessage
        case warningMessage
        case successMessage
        case errorMessage
        case customView(color: Color)

        var tintColor: Color {
            switch self {
            case .infoMessage:
                return Color(red: 67/255, green: 154/255, blue: 215/255)
            case .successMessage:
                return Color.green
            case .warningMessage:
                return Color.yellow
            case .errorMessage:
                return Color.red
            case .customView(color: let color):
                return color
            }
        }
    }
}

struct BannerView_Previews: PreviewProvider {
    static var previews: some View {
        BannerView(bannerData: .init(style: .infoMessage,
                                     messageTitle: "Info title",
                                     messageContent: "This is info notification"))
            .previewLayout(.sizeThatFits)
    }
}
