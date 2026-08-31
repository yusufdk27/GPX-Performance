//
//  GPX_PerformanceApp.swift
//  GPX-Performance
//
//  Created by Yusuf Dwi Kurniawan on 31/08/26.
//

import SwiftUI

@main
struct GPX_PerformanceApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let strategy = appState.currentStrategy {
                    CourseVisualizerView(strategy: strategy)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)),
                            removal: .opacity
                        ))
                } else {
                    OnboardingView()
                        .transition(.opacity)
                }
            }
            .environment(appState)
            .preferredColorScheme(.dark)
            .animation(.easeInOut(duration: 0.4), value: appState.currentStrategy?.id)
            .onAppear {
                WatchConnectivityManager.shared.activate()
            }
        }
    }
}
