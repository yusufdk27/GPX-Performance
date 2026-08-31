//
//  Checkpoint.swift
//  GPX-Performance
//
//  Created by GPX-Performance Team.
//

import Foundation
import CoreLocation

/// Represents a notable point along the course (aid station, water point, cut-off).
struct Checkpoint: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: CheckpointType
    let latitude: Double
    let longitude: Double
    let distanceFromStart: Double // meters
    
    /// Optional cut-off time in seconds from race start.
    var cutOffTimeSeconds: Double?
    
    /// Optional elevation at this checkpoint.
    var elevation: Double?
    
    /// Estimated arrival time in seconds from race start (computed by strategy engine).
    var estimatedArrivalSeconds: Double?
    
    init(
        id: UUID = UUID(),
        name: String,
        type: CheckpointType,
        latitude: Double,
        longitude: Double,
        distanceFromStart: Double,
        cutOffTimeSeconds: Double? = nil,
        elevation: Double? = nil,
        estimatedArrivalSeconds: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.distanceFromStart = distanceFromStart
        self.cutOffTimeSeconds = cutOffTimeSeconds
        self.elevation = elevation
        self.estimatedArrivalSeconds = estimatedArrivalSeconds
    }
    
    /// The coordinate for MapKit usage.
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Distance from start in kilometers.
    var distanceKm: Double {
        distanceFromStart / 1000.0
    }
    
    /// Formatted estimated arrival time.
    var estimatedArrivalFormatted: String {
        guard let seconds = estimatedArrivalSeconds else { return "--:--" }
        return PacingZone.formatDuration(seconds)
    }
    
    /// Formatted cut-off time.
    var cutOffTimeFormatted: String? {
        guard let seconds = cutOffTimeSeconds else { return nil }
        return PacingZone.formatDuration(seconds)
    }
    
    /// Time margin before cut-off (positive = safe, negative = over).
    var cutOffMarginSeconds: Double? {
        guard let cutOff = cutOffTimeSeconds, let arrival = estimatedArrivalSeconds else { return nil }
        return cutOff - arrival
    }
}

/// Types of checkpoints along the course.
enum CheckpointType: String, Codable, CaseIterable {
    case waterStation
    case aidStation
    case cutOff
    case start
    case finish
    case summit
    
    /// SF Symbol icon for this checkpoint type.
    var icon: String {
        switch self {
        case .waterStation: return "drop.fill"
        case .aidStation: return "cross.case.fill"
        case .cutOff: return "clock.badge.exclamationmark"
        case .start: return "flag.fill"
        case .finish: return "flag.checkered"
        case .summit: return "mountain.2.fill"
        }
    }
    
    /// Display name for this checkpoint type.
    var displayName: String {
        switch self {
        case .waterStation: return "Water Station"
        case .aidStation: return "Aid Station"
        case .cutOff: return "Cut-Off"
        case .start: return "Start"
        case .finish: return "Finish"
        case .summit: return "Summit"
        }
    }
}
