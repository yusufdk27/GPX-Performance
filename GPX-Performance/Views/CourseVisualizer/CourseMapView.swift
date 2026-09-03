//
//  CourseMapView.swift
//  GPX-Performance
//
//  Created by GPX-Performance Team.
//

import SwiftUI
import MapKit

/// MapKit view showing the course route colored by segment phase,
/// with live synchronized runner position scrubbing and tappable checkpoints.
struct CourseMapView: View {
    let strategy: RaceStrategy
    var selectedDistance: Double? = nil
    var onCheckpointTapped: ((Checkpoint) -> Void)? = nil
    
    @State private var mapPosition: MapCameraPosition = .automatic
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            // Header
            HStack {
                Text("COURSE MAP")
                    .font(Theme.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(1.5)
                
                Spacer()
                
                if let dist = selectedDistance {
                    Text(String(format: "KM %.1f", dist / 1000.0))
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(Theme.neonOrange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.neonOrange.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            
            Map(position: $mapPosition) {
                // Draw colored polylines for each segment
                ForEach(strategy.segments) { segment in
                    let coords = segment.trackPoints.map { $0.coordinate }
                    MapPolyline(coordinates: coords)
                        .stroke(segment.phase.color, lineWidth: 3)
                }
                
                // Start marker
                if let first = strategy.allTrackPoints.first {
                    Annotation("Start", coordinate: first.coordinate) {
                        ZStack {
                            Circle()
                                .fill(Theme.successGreen)
                                .frame(width: 24, height: 24)
                            Image(systemName: "flag.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                
                // Finish marker
                if let last = strategy.allTrackPoints.last {
                    Annotation("Finish", coordinate: last.coordinate) {
                        ZStack {
                            Circle()
                                .fill(Theme.neonOrange)
                                .frame(width: 24, height: 24)
                            Image(systemName: "flag.checkered")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                
                // Checkpoint markers
                ForEach(strategy.checkpoints) { checkpoint in
                    Annotation(checkpoint.name, coordinate: checkpoint.coordinate) {
                        Button {
                            onCheckpointTapped?(checkpoint)
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Theme.slateGray)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .stroke(Theme.warningYellow, lineWidth: 1.5)
                                    )
                                Image(systemName: checkpoint.type.icon)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Theme.warningYellow)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Live Synchronized Runner Scrubbing Pin
                if let runnerCoord = currentScrubbingCoordinate {
                    Annotation("Runner", coordinate: runnerCoord) {
                        ZStack {
                            Circle()
                                .fill(Theme.neonOrange.opacity(0.35))
                                .frame(width: 28, height: 28)
                            
                            Circle()
                                .fill(Theme.neonOrange)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: 2)
                                )
                                .shadow(color: Theme.neonOrange, radius: 6)
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .frame(height: 250)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
        }
        .padding(Theme.spacingL)
        .background(Theme.slateGray)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge))
    }
    
    // MARK: - Helper
    
    private var currentScrubbingCoordinate: CLLocationCoordinate2D? {
        guard let dist = selectedDistance, !strategy.allTrackPoints.isEmpty else { return nil }
        let closest = strategy.allTrackPoints.min(by: {
            abs($0.distanceFromStart - dist) < abs($1.distanceFromStart - dist)
        })
        return closest?.coordinate
    }
}

#Preview {
    CourseMapView(
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
