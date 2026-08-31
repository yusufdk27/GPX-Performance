//
//  CourseMapView.swift
//  GPX-Performance
//
//  Created by GPX-Performance Team.
//

import SwiftUI
import MapKit

/// MapKit view showing the course route colored by segment phase.
struct CourseMapView: View {
    let strategy: RaceStrategy
    
    @State private var mapPosition: MapCameraPosition = .automatic
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            // Header
            Text("COURSE MAP")
                .font(Theme.caption)
                .foregroundStyle(Theme.textSecondary)
                .tracking(1.5)
            
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
                        ZStack {
                            Circle()
                                .fill(Theme.slateGray)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .stroke(Theme.warningYellow, lineWidth: 1.5)
                                )
                            Image(systemName: checkpoint.type.icon)
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(Theme.warningYellow)
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
