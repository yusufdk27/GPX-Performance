//
//  RaceStrategy.swift
//  GPX-Performance
//
//  Created by GPX-Performance Team.
//

import Foundation

/// Container for the complete race strategy derived from GPX analysis.
struct RaceStrategy: Codable, Identifiable {
    let id: UUID
    let courseName: String
    let segments: [CourseSegment]
    let checkpoints: [Checkpoint]
    let allTrackPoints: [TrackPoint]
    let pacingZone: PacingZone
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        courseName: String,
        segments: [CourseSegment],
        checkpoints: [Checkpoint],
        allTrackPoints: [TrackPoint],
        pacingZone: PacingZone = PacingZone(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.courseName = courseName
        self.segments = segments
        self.checkpoints = checkpoints
        self.allTrackPoints = allTrackPoints
        self.pacingZone = pacingZone
        self.createdAt = createdAt
    }
    
    // MARK: - Distance
    
    /// Total course distance in meters.
    var totalDistance: Double {
        allTrackPoints.last?.distanceFromStart ?? 0
    }
    
    /// Total course distance in kilometers.
    var totalDistanceKm: Double {
        totalDistance / 1000.0
    }
    
    /// Formatted total distance string.
    var totalDistanceFormatted: String {
        String(format: "%.1f km", totalDistanceKm)
    }
    
    // MARK: - Elevation
    
    /// Total elevation gain across the entire course.
    var totalElevationGain: Double {
        segments.reduce(0) { $0 + $1.elevationGain }
    }
    
    /// Total elevation loss across the entire course.
    var totalElevationLoss: Double {
        segments.reduce(0) { $0 + $1.elevationLoss }
    }
    
    /// Minimum elevation on the course.
    var minElevation: Double {
        allTrackPoints.map(\.elevation).min() ?? 0
    }
    
    /// Maximum elevation on the course.
    var maxElevation: Double {
        allTrackPoints.map(\.elevation).max() ?? 0
    }
    
    /// Formatted elevation gain string.
    var elevationGainFormatted: String {
        String(format: "+%.0f m", totalElevationGain)
    }
    
    /// Formatted elevation loss string.
    var elevationLossFormatted: String {
        String(format: "-%.0f m", totalElevationLoss)
    }
    
    // MARK: - Segments by Phase
    
    /// All climb segments.
    var climbSegments: [CourseSegment] {
        segments.filter { $0.phase == .climb }
    }
    
    /// All descent segments.
    var descentSegments: [CourseSegment] {
        segments.filter { $0.phase == .descent }
    }
    
    /// All flat segments.
    var flatSegments: [CourseSegment] {
        segments.filter { $0.phase == .flat }
    }
    
    /// Total climb distance in km.
    var totalClimbDistanceKm: Double {
        climbSegments.reduce(0) { $0 + $1.distanceKm }
    }
    
    /// Total descent distance in km.
    var totalDescentDistanceKm: Double {
        descentSegments.reduce(0) { $0 + $1.distanceKm }
    }
    
    /// Total flat distance in km.
    var totalFlatDistanceKm: Double {
        flatSegments.reduce(0) { $0 + $1.distanceKm }
    }
    
    // MARK: - Time Estimates
    
    /// Estimated total finish time in seconds.
    var estimatedFinishTimeSeconds: Double {
        segments.reduce(0) { $0 + $1.estimatedTimeSeconds }
    }
    
    /// Formatted estimated finish time.
    var estimatedFinishTimeFormatted: String {
        PacingZone.formatDuration(estimatedFinishTimeSeconds)
    }
    
    /// Average pace across the entire course (seconds per km).
    var averagePaceSecondsPerKm: Double {
        guard totalDistanceKm > 0 else { return 0 }
        return estimatedFinishTimeSeconds / totalDistanceKm
    }
    
    /// Formatted average pace.
    var averagePaceFormatted: String {
        PacingZone.formatPace(averagePaceSecondsPerKm)
    }
    
    // MARK: - Cumulative Data
    
    /// Calculate cumulative elevation gain at each trackpoint for charting.
    var cumulativeElevationGain: [(distance: Double, gain: Double)] {
        var result: [(distance: Double, gain: Double)] = []
        var totalGain: Double = 0
        
        result.append((distance: 0, gain: 0))
        
        for i in 1..<allTrackPoints.count {
            let diff = allTrackPoints[i].elevation - allTrackPoints[i - 1].elevation
            if diff > 0 { totalGain += diff }
            result.append((distance: allTrackPoints[i].distanceFromStart, gain: totalGain))
        }
        
        return result
    }
    
    /// Get the segment for a given distance from start.
    func segment(at distance: Double) -> CourseSegment? {
        segments.first { distance >= $0.startDistance && distance <= $0.endDistance }
    }
}
