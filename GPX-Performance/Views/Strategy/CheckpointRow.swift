//
//  CheckpointRow.swift
//  GPX-Performance
//
//  Created by GPX-Performance Team.
//

import SwiftUI

/// Row displaying a checkpoint with distance, estimated arrival, and cut-off info.
struct CheckpointRow: View {
    let checkpoint: Checkpoint
    
    var body: some View {
        HStack(spacing: Theme.spacingM) {
            // Checkpoint icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: checkpoint.type.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(iconBackgroundColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(checkpoint.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                
                HStack(spacing: Theme.spacingS) {
                    Text(String(format: "km %.1f", checkpoint.distanceKm))
                        .font(Theme.smallCaption)
                        .foregroundStyle(Theme.textSecondary)
                    
                    if let elevation = checkpoint.elevation {
                        Text("·")
                            .foregroundStyle(Theme.textTertiary)
                        Text(String(format: "%.0f m", elevation))
                            .font(Theme.smallCaption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            // Arrival & Cut-off
            VStack(alignment: .trailing, spacing: 2) {
                Text(checkpoint.estimatedArrivalFormatted)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Theme.textPrimary)
                
                if let cutOff = checkpoint.cutOffTimeFormatted {
                    HStack(spacing: 3) {
                        Image(systemName: "clock.badge.exclamationmark")
                            .font(.system(size: 8))
                        Text("COT: \(cutOff)")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(cutOffColor)
                }
            }
        }
        .padding(Theme.spacingM)
        .background(Theme.slateGray)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
    }
    
    // MARK: - Computed
    
    private var iconBackgroundColor: Color {
        switch checkpoint.type {
        case .waterStation: return .blue
        case .aidStation: return Theme.successGreen
        case .cutOff: return Theme.warningYellow
        case .start: return Theme.successGreen
        case .finish: return Theme.neonOrange
        case .summit: return Theme.neonOrange
        }
    }
    
    private var cutOffColor: Color {
        guard let margin = checkpoint.cutOffMarginSeconds else { return Theme.textTertiary }
        if margin > 1800 { return Theme.successGreen } // >30 min margin
        if margin > 0 { return Theme.warningYellow } // tight margin
        return Theme.dangerRed // over cut-off
    }
}

#Preview {
    VStack(spacing: 8) {
        CheckpointRow(
            checkpoint: Checkpoint(
                name: "Water Station 1",
                type: .waterStation,
                latitude: 0,
                longitude: 0,
                distanceFromStart: 5000,
                elevation: 450,
                estimatedArrivalSeconds: 1800
            )
        )
        CheckpointRow(
            checkpoint: Checkpoint(
                name: "Aid Station",
                type: .aidStation,
                latitude: 0,
                longitude: 0,
                distanceFromStart: 12000,
                cutOffTimeSeconds: 7200,
                elevation: 720,
                estimatedArrivalSeconds: 5400
            )
        )
    }
    .padding()
    .background(Theme.background)
}
