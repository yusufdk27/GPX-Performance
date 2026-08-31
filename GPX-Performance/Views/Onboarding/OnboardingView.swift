//
//  OnboardingView.swift
//  GPX-Performance
//
//  Created by GPX-Performance Team.
//

import SwiftUI
import UniformTypeIdentifiers

/// Welcome screen with GPX file import, raw XML paste sheet, and sample course loading.
struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var animateLogo = false
    @State private var animateContent = false
    @State private var mountainOffset: CGFloat = 50
    @State private var pastedXMLText: String = ""
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedGradientBackground()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo & Title
                logoSection
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                
                Spacer()
                
                // Mountain silhouette illustration
                mountainIllustration
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: mountainOffset)
                
                Spacer()
                
                // CTA Buttons
                ctaSection
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 30)
                
                Spacer()
                    .frame(height: 30)
            }
            .padding(.horizontal, Theme.spacingXL)
            
            // Processing overlay
            if appState.isProcessing {
                processingOverlay
            }
            
            // Error alert overlay
            if appState.importError != nil {
                errorOverlay
            }
        }
        .fileImporter(
            isPresented: Binding(
                get: { appState.showingFileImporter },
                set: { appState.showingFileImporter = $0 }
            ),
            allowedContentTypes: UTType.gpxTypes,
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    appState.importGPX(from: url)
                }
            case .failure(let error):
                appState.importError = error.localizedDescription
            }
        }
        .sheet(
            isPresented: Binding(
                get: { appState.showingPasteSheet },
                set: { appState.showingPasteSheet = $0 }
            )
        ) {
            pasteXMLSheet
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animateContent = true
            }
            withAnimation(.easeOut(duration: 1.2).delay(0.4)) {
                mountainOffset = 0
            }
            withAnimation(
                .easeInOut(duration: 3.0)
                .repeatForever(autoreverses: true)
                .delay(1.0)
            ) {
                animateLogo = true
            }
        }
    }
    
    // MARK: - Logo Section
    
    private var logoSection: some View {
        VStack(spacing: Theme.spacingM) {
            // App icon logo
            AppLogoView(size: 88)
                .padding(.bottom, 4)
            
            // App name
            VStack(spacing: 4) {
                Text("GPX")
                    .font(.system(size: 42, weight: .black, design: .default))
                    .foregroundStyle(Theme.textPrimary)
                +
                Text(" Performance")
                    .font(.system(size: 42, weight: .light, design: .default))
                    .foregroundStyle(Theme.textPrimary)
            }
            
            Text("Conquer Every Elevation")
                .font(Theme.body)
                .foregroundStyle(Theme.textSecondary)
                .tracking(2)
        }
    }
    
    // MARK: - Mountain Illustration
    
    private var mountainIllustration: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h: CGFloat = 120
            
            ZStack {
                // Background mountain range
                Path { path in
                    path.move(to: CGPoint(x: 0, y: h))
                    path.addLine(to: CGPoint(x: w * 0.1, y: h * 0.7))
                    path.addLine(to: CGPoint(x: w * 0.2, y: h * 0.5))
                    path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.6))
                    path.addLine(to: CGPoint(x: w * 0.45, y: h * 0.2))
                    path.addLine(to: CGPoint(x: w * 0.55, y: h * 0.35))
                    path.addLine(to: CGPoint(x: w * 0.65, y: h * 0.15))
                    path.addLine(to: CGPoint(x: w * 0.75, y: h * 0.45))
                    path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.3))
                    path.addLine(to: CGPoint(x: w * 0.95, y: h * 0.55))
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Theme.neonOrange.opacity(0.15),
                            Theme.neonOrange.opacity(0.03)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Foreground mountain (elevation profile hint)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: h))
                    path.addLine(to: CGPoint(x: w * 0.15, y: h * 0.75))
                    path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.55))
                    path.addLine(to: CGPoint(x: w * 0.35, y: h * 0.65))
                    path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.25))
                    path.addLine(to: CGPoint(x: w * 0.6, y: h * 0.4))
                    path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.2))
                    path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.5))
                    path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.6))
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Theme.slateGray.opacity(0.8),
                            Theme.slateGray.opacity(0.3)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Glow line on top edge
                Path { path in
                    path.move(to: CGPoint(x: 0, y: h))
                    path.addLine(to: CGPoint(x: w * 0.15, y: h * 0.75))
                    path.addLine(to: CGPoint(x: w * 0.25, y: h * 0.55))
                    path.addLine(to: CGPoint(x: w * 0.35, y: h * 0.65))
                    path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.25))
                    path.addLine(to: CGPoint(x: w * 0.6, y: h * 0.4))
                    path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.2))
                    path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.5))
                    path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.6))
                    path.addLine(to: CGPoint(x: w, y: h))
                }
                .stroke(
                    Theme.neonOrange.opacity(0.5),
                    lineWidth: 1.5
                )
                .shadow(color: Theme.neonOrange.opacity(0.3), radius: 6)
            }
        }
        .frame(height: 120)
    }
    
    // MARK: - CTA Section
    
    private var ctaSection: some View {
        VStack(spacing: Theme.spacingM) {
            NeonButton(
                title: "Import GPX File",
                icon: "doc.badge.plus"
            ) {
                appState.showingFileImporter = true
            }
            
            HStack(spacing: Theme.spacingM) {
                SecondaryButton(
                    title: "Paste GPX XML",
                    icon: "doc.on.clipboard"
                ) {
                    appState.showingPasteSheet = true
                }
                
                SecondaryButton(
                    title: "Sample Course",
                    icon: "map"
                ) {
                    appState.loadSampleCourse()
                }
            }
        }
    }
    
    // MARK: - Paste XML Sheet
    
    private var pasteXMLSheet: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: Theme.spacingL) {
                    Text("Tempel teks XML GPX dari clipboard atau aplikasi lain:")
                        .font(Theme.caption)
                        .foregroundStyle(Theme.textSecondary)
                    
                    TextEditor(text: $pastedXMLText)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(Theme.textPrimary)
                        .padding(Theme.spacingM)
                        .background(Theme.slateGray)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                                .stroke(Theme.borderGray, lineWidth: 1)
                        )
                    
                    HStack(spacing: Theme.spacingM) {
                        Button {
                            if let clipString = UIPasteboard.general.string {
                                pastedXMLText = clipString
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.on.clipboard")
                                Text("Paste Clipboard")
                            }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.neonOrange)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Theme.surfaceGray)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
                        }
                        
                        Button {
                            appState.importGPXString(pastedXMLText)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark")
                                Text("Proses Rute")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(pastedXMLText.isEmpty ? Theme.surfaceGray : Theme.neonOrange)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
                        }
                        .disabled(pastedXMLText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(Theme.spacingL)
            }
            .navigationTitle("Paste GPX XML")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Tutup") {
                        appState.showingPasteSheet = false
                    }
                    .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Processing Overlay
    
    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: Theme.spacingXL) {
                ProcessingAnimation()
                    .frame(height: 60)
                    .padding(.horizontal, 40)
                
                VStack(spacing: Theme.spacingS) {
                    Text(appState.processingStatus)
                        .font(Theme.heading)
                        .foregroundStyle(Theme.textPrimary)
                    
                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Theme.surfaceGray)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Theme.orangeGradient)
                                .frame(width: geo.size.width * appState.processingProgress)
                                .animation(.easeInOut(duration: 0.3), value: appState.processingProgress)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 60)
                    
                    Text("\(Int(appState.processingProgress * 100))%")
                        .font(Theme.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .transition(.opacity)
    }
    
    // MARK: - Error Overlay
    
    private var errorOverlay: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()
                .onTapGesture {
                    appState.dismissError()
                }
            
            VStack(spacing: Theme.spacingL) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.warningYellow)
                
                Text("Gagal Membaca GPX")
                    .font(Theme.title)
                    .foregroundStyle(Theme.textPrimary)
                
                Text(appState.importError ?? "Format file tidak dikenal.")
                    .font(Theme.body)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: Theme.spacingM) {
                    NeonButton(title: "Coba Lagi", icon: "arrow.clockwise") {
                        appState.dismissError()
                    }
                    
                    Button {
                        appState.dismissError()
                        appState.showingPasteSheet = true
                    } label: {
                        Text("Tempel Teks GPX Manual")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.neonOrange)
                    }
                }
            }
            .padding(Theme.spacingXL)
            .background(Theme.slateGray)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusXL))
            .padding(.horizontal, Theme.spacingXL)
        }
        .transition(.opacity)
    }
}

// MARK: - Processing Animation

struct ProcessingAnimation: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: h * 0.8))
                path.addLine(to: CGPoint(x: w * 0.1, y: h * 0.6))
                path.addLine(to: CGPoint(x: w * 0.2, y: h * 0.7))
                path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.3))
                path.addLine(to: CGPoint(x: w * 0.4, y: h * 0.5))
                path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.2))
                path.addLine(to: CGPoint(x: w * 0.6, y: h * 0.4))
                path.addLine(to: CGPoint(x: w * 0.7, y: h * 0.6))
                path.addLine(to: CGPoint(x: w * 0.8, y: h * 0.3))
                path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.5))
                path.addLine(to: CGPoint(x: w, y: h * 0.7))
            }
            .trim(from: 0, to: 1)
            .stroke(
                Theme.neonOrange,
                style: StrokeStyle(
                    lineWidth: 2.5,
                    lineCap: .round,
                    lineJoin: .round,
                    dash: [8, 6],
                    dashPhase: phase
                )
            )
            .shadow(color: Theme.neonOrange.opacity(0.5), radius: 4)
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = -28
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}
