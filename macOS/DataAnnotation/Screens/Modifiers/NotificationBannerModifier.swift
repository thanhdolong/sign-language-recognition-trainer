//
//  NotificationBannerModifier.swift
//  DataAnnotation
//
//  Created by Thành Đỗ Long on 07.05.2021.
//

import SwiftUI
import Combine

// MARK: - RootViewAppearance

struct NotificationBannerModifier: ViewModifier {
    @StateObject var viewModel: ViewModel

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
                .zIndex(1)

            if viewModel.isBannerHidden == false {
                VStack {
                    BannerView(bannerData: viewModel.bannerData)
                }
                .zIndex(2)
                .ignoresSafeArea(edges: .all)
                .padding()
                .animation(.spring())
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .gesture(DragGesture().onChanged({ gesture in
                    guard gesture.startLocation.y > gesture.location.y else { return }
                    hideBanner()
                }))
                .onTapGesture { hideBanner() }
                .onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        hideBanner()
                    }
                })
            }
        }
    }

    private func hideBanner() {
        withAnimation(.spring(), {
            viewModel.isBannerHidden = true
        })
    }
}

extension NotificationBannerModifier {
    class ViewModel: ObservableObject {
        @Published var isBannerHidden: Bool = false
        @Published var bannerData: BannerView.BannerData {
            didSet {
                isBannerHidden = false
            }
        }

        init(bannerData: BannerView.BannerData) {
            self.bannerData = bannerData
        }
    }
}

extension View {
    func showNotificationBanner(bannerData: BannerView.BannerData) -> some View {
        self.modifier(NotificationBannerModifier(viewModel: .init(bannerData: bannerData)))
    }
}
