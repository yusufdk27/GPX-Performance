//
//  ElevationProfileChart.swift
//  GPX-Performance
//
//  Created by GPX-Performance Team.
//

import SwiftUI
import Charts

/// Interactive elevation profile chart built with Swift Charts.
struct ElevationProfileChart: View {
    let strategy: RaceStrategy
    @Binding var selectedDistance: Double?
    
    init(strategy: RaceStrategy, selectedDistance: Binding<Double?> = .constant(nil)) {
        self.strategy = strategy
        self._selectedDistance = selectedDistance
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            // Header
            headerView
            
            // Chart
            Chart {
                ForEach(strategy.segments) { segment in
                    ForEach(segment.trackPoints) { point in
                        AreaMark(
                            x: .value("Distance", point.distanceFromStart),
                            y: .value("Elevation", point.elevation)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    segment.phase.color.opacity(0.35),
                                    segment.phase.color.opacity(0.05)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.monotone)
                        
                        LineMark(
                            x: .value("Distance", point.distanceFromStart),
                            y: .value("Elevation", point.elevation)
                        )
                        .foregroundStyle(segment.phase.color)
                        .interpolationMethod(.monotone)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    }
                }
                
                // Checkpoint markers
                ForEach(strategy.checkpoints) { checkpoint in
                    if let ele = checkpoint.elevation {
                        PointMark(
                            x: .value("Distance", checkpoint.distanceFromStart),
                            y: .value("Elevation", ele)
                        )
                        .foregroundStyle(Theme.warningYellow)
                        .symbolSize(36)
                        .annotation(position: .top, spacing: 4) {
                            Text(checkpoint.name)
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
                
                // Selection indicator
                if let selected = selectedDistance {
                    RuleMark(x: .value("Selected", selected))
                        .foregroundStyle(Theme.neonOrange)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                }
            }
            .chartYScale(domain: max(0, strategy.minElevation - 50)...(strategy.maxElevation + 50))
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    AxisValueLabel {
                        if let dist = value.as(Double.self) {
                            Text(String(format: "%.0f km", dist / 1000.0))
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.textTertiary)
                        }
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Theme.borderGray)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                    AxisValueLabel {
                        if let ele = value.as(Double.self) {
                            Text(String(format: "%.0fm", ele))
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.textTertiary)
                        }
                    }
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Theme.borderGray)
                }
            }
            .chartXSelection(value: $selectedDistance)
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Theme.slateGray.opacity(0.3))
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
        }
        .padding(Theme.spacingL)
        .background(Theme.slateGray)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("ELEVATION PROFILE")
                    .font(Theme.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(1.5)
                
                if let selected = selectedDistance,
                   let point = nearestPoint(to: selected) {
                    HStack(spacing: Theme.spacingS) {
                        Text(String(format: "%.1f km", selected / 1000.0))
                            .font(Theme.metricSmall)
                            .foregroundStyle(Theme.neonOrange)
                        
                        Text("·")
                            .foregroundStyle(Theme.textTertiary)
                        
                        Text(String(format: "%.0f m", point.elevation))
                            .font(Theme.metricSmall)
                            .foregroundStyle(Theme.textPrimary)
                        
                        if let segment = strategy.segment(at: selected) {
                            Text("·")
                                .foregroundStyle(Theme.textTertiary)
                            
                            HStack(spacing: 3) {
                                Image(systemName: segment.phase.icon)
                                    .font(.system(size: 10))
                                Text(segment.phase.displayName)
                                    .font(Theme.smallCaption)
                            }
                            .foregroundStyle(segment.phase.color)
                        }
                    }
                } else {
                    HStack(spacing: Theme.spacingS) {
                        Text(String(format: "%.0f m", strategy.minElevation))
                            .font(Theme.metricSmall)
                            .foregroundStyle(Theme.textTertiary)
                        Text("→")
                            .foregroundStyle(Theme.textTertiary)
                        Text(String(format: "%.0f m", strategy.maxElevation))
                            .font(Theme.metricSmall)
                            .foregroundStyle(Theme.textPrimary)
                    }
                }
            }
            
            Spacer()
            
            // Legend
            HStack(spacing: Theme.spacingS) {
                legendDot(color: SegmentPhase.climb.color, label: "Climb")
                legendDot(color: SegmentPhase.flat.color, label: "Flat")
                legendDot(color: SegmentPhase.descent.color, label: "Desc")
            }
        }
    }
    
    // MARK: - Helpers
    
    private func nearestPoint(to distance: Double) -> TrackPoint? {
        strategy.allTrackPoints.min(by: {
            abs($0.distanceFromStart - distance) < abs($1.distanceFromStart - distance)
        })
    }
    
    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 3) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Theme.textTertiary)
        }
    }
}

#Preview {
    ElevationProfileChart(
        strategy: RaceStrategy(
            courseName: "Preview",
            segments: [],
            checkpoints: [],
            allTrackPoints: []
        )
    )
    .padding()
    .background(Theme.background)
}
