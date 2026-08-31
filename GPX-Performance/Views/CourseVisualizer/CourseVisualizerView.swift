//
//  CourseVisualizerView.swift
//  GPX-Performance
//
//  Created by GPX-Performance Team.
//

import SwiftUI

/// Main strategy screen — elevation chart, map, segment breakdown, and sync CTA.
struct CourseVisualizerView: View {
    let strategy: RaceStrategy
    @Environment(AppState.self) private var appState
    
    @State private var showingStrategyOverview = false
    @State private var showingSyncAlert = false
    @State private var animateHeader = false
    
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
                        
                        // Elevation profile chart
                        ElevationProfileChart(strategy: strategy)
                        
                        // Course map
                        CourseMapView(strategy: strategy)
                        
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
                    Button {
                        showingStrategyOverview = true
                    } label: {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Theme.neonOrange)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingStrategyOverview) {
                StrategyOverviewView(strategy: strategy)
            }
            .alert("Sync to Watch", isPresented: $showingSyncAlert) {
                Button("OK") {}
            } message: {
                Text("Connect an Apple Watch and add the watchOS target to enable strategy sync.")
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
                Image(systemName: "mountain.2.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Theme.neonOrange)
                
                Text(strategy.courseName)
                    .font(Theme.largeTitle)
                    .foregroundStyle(Theme.textPrimary)
            }
            .opacity(animateHeader ? 1 : 0)
            .offset(y: animateHeader ? 0 : 10)
            
            HStack(spacing: Theme.spacingM) {
                inlineMetric(icon: "figure.run", value: strategy.totalDistanceFormatted)
                
                Text("·")
                    .foregroundStyle(Theme.textTertiary)
                
                inlineMetric(icon: "arrow.up.right", value: strategy.elevationGainFormatted)
                
                Text("·")
                    .foregroundStyle(Theme.textTertiary)
                
                inlineMetric(icon: "clock", value: strategy.estimatedFinishTimeFormatted)
            }
            .font(Theme.caption)
            .foregroundStyle(Theme.textSecondary)
            .opacity(animateHeader ? 1 : 0)
            .offset(y: animateHeader ? 0 : 10)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Metrics Row
    
    private var metricsRow: some View {
        MetricCardRow(metrics: [
            ("Distance", String(format: "%.1f", strategy.totalDistanceKm), "km", "figure.run", Theme.neonOrange),
            ("Gain", String(format: "+%.0f", strategy.totalElevationGain), "m", "arrow.up.right", SegmentPhase.climb.color),
            ("Loss", String(format: "%.0f", strategy.totalElevationLoss), "m", "arrow.down.right", Theme.cyan)
        ])
    }
    
    // MARK: - Strategy Preview Card
    
    private var strategyPreviewCard: some View {
        Button {
            showingStrategyOverview = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: Theme.spacingS) {
                    Text("RACE STRATEGY")
                        .font(Theme.caption)
                        .foregroundStyle(Theme.neonOrange)
                        .tracking(1.2)
                    
                    Text("Est. Finish: \(strategy.estimatedFinishTimeFormatted)")
                        .font(Theme.heading)
                        .foregroundStyle(Theme.textPrimary)
                    
                    Text("Avg Pace: \(strategy.averagePaceFormatted)")
                        .font(Theme.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    ForEach(SegmentPhase.allCases) { phase in
                        let count = strategy.segments.filter { $0.phase == phase }.count
                        HStack(spacing: 4) {
                            Circle()
                                .fill(phase.color)
                                .frame(width: 6, height: 6)
                            Text("\(count)")
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundStyle(Theme.textPrimary)
                            Text(phase.displayName)
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.textTertiary)
                        }
                    }
                }
                
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
            Text("CHECKPOINTS & AID STATIONS")
                .font(Theme.caption)
                .foregroundStyle(Theme.textSecondary)
                .tracking(1.5)
            
            ForEach(strategy.checkpoints) { checkpoint in
                CheckpointRow(checkpoint: checkpoint)
            }
        }
    }
    
    // MARK: - CTA Section
    
    private var ctaSection: some View {
        VStack(spacing: Theme.spacingM) {
            GlowingDivider()
                .padding(.vertical, Theme.spacingS)
            
            NeonButton(
                title: "Sync to Watch",
                icon: "applewatch.radiowaves.left.and.right"
            ) {
                showingSyncAlert = true
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
