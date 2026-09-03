//
//  CourseVisualizerView.swift
//  GPX-Performance
//
//  Created by GPX-Performance Team.
//

import SwiftUI

/// Main strategy screen — elevation chart, map, segment breakdown, pace customization, and watch sync.
struct CourseVisualizerView: View {
    let strategy: RaceStrategy
    @Environment(AppState.self) private var appState
    
    @State private var showingStrategyOverview = false
    @State private var showingWatchSimulator = false
    @State private var animateHeader = false
    @State private var selectedDistance: Double? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AnimatedGradientBackground()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: Theme.spacingL) {
                        // Course header
                        courseHeader
                        
                        // Key metrics row
                        metricsRow
                        
                        // Interactive Base Pace Customizer
                        PaceCustomizerBar(
                            basePaceSecondsPerKm: Binding(
                                get: { appState.basePaceSecondsPerKm },
                                set: { appState.updateBasePace($0) }
                            )
                        )
                        
                        // Elevation profile chart (synchronized)
                        ElevationProfileChart(
                            strategy: strategy,
                            selectedDistance: $selectedDistance
                        )
                        
                        // Course map (synchronized with scrub pin)
                        CourseMapView(
                            strategy: strategy,
                            selectedDistance: selectedDistance,
                            onCheckpointTapped: { checkpoint in
                                appState.selectedCheckpoint = checkpoint
                                appState.showingCheckpointEditor = true
                            }
                        )
                        
                        // Strategy overview link
                        strategyPreviewCard
                        
                        // Segment breakdown
                        SegmentListView(strategy: strategy)
                        
                        // Checkpoints section
                        if !strategy.checkpoints.isEmpty {
                            checkpointsSection
                        }
                        
                        // Bottom CTAs
                        ctaSection
                        
                        // Spacer for bottom safe area
                        Spacer()
                            .frame(height: Theme.spacingXL)
                    }
                    .padding(.horizontal, Theme.spacingL)
                    .padding(.top, Theme.spacingM)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        appState.clearStrategy()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("New Course")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundStyle(Theme.neonOrange)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            showingWatchSimulator = true
                        } label: {
                            Image(systemName: "applewatch")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.neonOrange)
                        }
                        
                        Button {
                            showingStrategyOverview = true
                        } label: {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Theme.neonOrange)
                        }
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingStrategyOverview) {
                StrategyOverviewView(strategy: strategy)
            }
            .sheet(isPresented: $showingWatchSimulator) {
                WatchCompanionSimulatorView(strategy: strategy)
            }
            .sheet(
                isPresented: Binding(
                    get: { appState.showingCheckpointEditor },
                    set: { appState.showingCheckpointEditor = $0 }
                )
            ) {
                if let cp = appState.selectedCheckpoint {
                    CheckpointEditorSheet(checkpoint: cp) { updated in
                        appState.updateCheckpoint(updated)
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    animateHeader = true
                }
            }
        }
    }
    
    // MARK: - Course Header
    
    private var courseHeader: some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            HStack {
                Text("COURSE STRATEGY")
                    .font(Theme.smallCaption)
                    .foregroundStyle(Theme.neonOrange)
                    .tracking(2.0)
                
                Spacer()
                
                Text(strategy.courseName)
                    .font(Theme.smallCaption)
                    .foregroundStyle(Theme.textTertiary)
                    .lineLimit(1)
            }
            
            Text(strategy.courseName)
                .font(Theme.title)
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(animateHeader ? 1 : 0)
        .offset(y: animateHeader ? 0 : -10)
    }
    
    // MARK: - Metrics Row
    
    private var metricsRow: some View {
        HStack(spacing: Theme.spacingS) {
            MetricCard(
                title: "DISTANCE",
                value: strategy.totalDistanceFormatted,
                icon: "figure.run",
                accentColor: Theme.neonOrange
            )
            
            MetricCard(
                title: "ELEV. GAIN",
                value: strategy.elevationGainFormatted,
                icon: "arrow.up.right",
                accentColor: SegmentPhase.climb.color
            )
            
            MetricCard(
                title: "EST. TIME",
                value: strategy.estimatedFinishTimeFormatted,
                icon: "clock.fill",
                accentColor: Theme.warningYellow
            )
            
            MetricCard(
                title: "AVG PACE",
                value: strategy.averagePaceFormatted,
                icon: "speedometer",
                accentColor: SegmentPhase.flat.color
            )
        }
    }
    
    // MARK: - Strategy Preview Card
    
    private var strategyPreviewCard: some View {
        Button {
            showingStrategyOverview = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.shield.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.neonOrange)
                        Text("STRATEGY BLUEPRINT")
                            .font(Theme.smallCaption)
                            .foregroundStyle(Theme.neonOrange)
                            .tracking(1.5)
                    }
                    
                    Text("3 Pacing Zones · Energy & Nutrition Plan")
                        .font(Theme.body)
                        .foregroundStyle(Theme.textPrimary)
                    
                    HStack(spacing: Theme.spacingM) {
                        inlineMetric(
                            icon: "arrow.up.right",
                            value: "\(strategy.climbSegments.count) climbs"
                        )
                        inlineMetric(
                            icon: "arrow.forward",
                            value: "\(strategy.flatSegments.count) flats"
                        )
                        inlineMetric(
                            icon: "arrow.down.right",
                            value: "\(strategy.descentSegments.count) descents"
                        )
                    }
                    .font(Theme.smallCaption)
                    .foregroundStyle(Theme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.textTertiary)
                    .padding(.leading, Theme.spacingS)
            }
            .padding(Theme.spacingL)
            .background(Theme.slateGray)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
            .neonGlow(color: Theme.neonOrange, radius: 6)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Checkpoints Section
    
    private var checkpointsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            HStack {
                Text("CHECKPOINTS & AID STATIONS")
                    .font(Theme.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(1.5)
                
                Spacer()
                
                Text("Tap untuk edit COT")
                    .font(Theme.smallCaption)
                    .foregroundStyle(Theme.neonOrange)
            }
            
            ForEach(strategy.checkpoints) { checkpoint in
                Button {
                    appState.selectedCheckpoint = checkpoint
                    appState.showingCheckpointEditor = true
                } label: {
                    CheckpointRow(checkpoint: checkpoint)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - CTA Section
    
    private var ctaSection: some View {
        VStack(spacing: Theme.spacingM) {
            GlowingDivider()
                .padding(.vertical, Theme.spacingS)
            
            NeonButton(
                title: "Launch Apple Watch Companion",
                icon: "applewatch.radiowaves.left.and.right"
            ) {
                WatchConnectivityManager.shared.sendStrategy(strategy)
                showingWatchSimulator = true
            }
        }
    }
    
    // MARK: - Helpers
    
    private func inlineMetric(icon: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
            Text(value)
        }
    }
}

#Preview {
    CourseVisualizerView(
        strategy: RaceStrategy(
            courseName: "Trail Preview",
            segments: [],
            checkpoints: [],
            allTrackPoints: []
        )
    )
    .environment(AppState())
}
