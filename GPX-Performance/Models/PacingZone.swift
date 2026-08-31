//
//  PacingZone.swift
//  GPX-Performance
//
//  Created by GPX-Performance Team.
//

import Foundation

/// Pacing configuration and Grade Adjusted Pace (GAP) calculator.
struct PacingZone: Codable {
    
    /// User's base flat pace in seconds per kilometer (default: 6:00/km = 360s).
    var basePaceSecondsPerKm: Double = 360
    
    /// Calculate Grade Adjusted Pace for a given gradient percentage.
    ///
    /// Formula based on research-backed GAP calculations:
    /// - Uphill: pace slows proportionally to gradient
    /// - Gentle downhill (0 to -10%): pace slightly increases
    /// - Steep downhill (< -10%): pace slows due to technical terrain
    ///
    /// - Parameter gradient: The gradient percentage (positive = uphill, negative = downhill)
    /// - Returns: Adjusted pace in seconds per kilometer
    func gradeAdjustedPace(for gradient: Double) -> Double {
        let adjustmentFactor: Double
        
        if gradient > 0 {
            // Uphill: ~3.3% slower per 1% grade
            // e.g., 10% grade → 33% slower → 6:00 becomes ~8:00
            adjustmentFactor = 1.0 + (gradient * 0.033)
        } else if gradient >= -10 {
            // Gentle downhill: slight speed increase
            // e.g., -5% grade → 10% faster → 6:00 becomes ~5:24
            adjustmentFactor = 1.0 + (gradient * 0.02)
        } else {
            // Steep downhill: technical slowdown kicks in
            // Beyond -10%, each additional -1% adds slowdown
            let gentlePortion = 1.0 + (-10.0 * 0.02) // = 0.80
            let steepExtra = (abs(gradient) - 10.0) * 0.025
            adjustmentFactor = gentlePortion + steepExtra
        }
        
        return basePaceSecondsPerKm * max(adjustmentFactor, 0.6) // floor at 60% of base
    }
    
    /// Format a pace value in seconds/km to a readable string (e.g., "6:30/km").
    static func formatPace(_ secondsPerKm: Double) -> String {
        let totalSeconds = Int(secondsPerKm)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d/km", minutes, seconds)
    }
    
    /// Format a duration in seconds to a readable string.
    static func formatDuration(_ totalSeconds: Double) -> String {
        let total = Int(totalSeconds)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let secs = total % 60
        if hours > 0 {
            return String(format: "%dh %02dm %02ds", hours, minutes, secs)
        }
        return String(format: "%dm %02ds", minutes, secs)
    }
}
