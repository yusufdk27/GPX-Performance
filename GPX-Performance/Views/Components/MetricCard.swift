//
//  MetricCard.swift
//  GPX-Performance
//
//  Created by GPX-Performance Team.
//

import SwiftUI

/// A reusable metric display card with title, value, and optional unit/trend.
struct MetricCard: View {
    let title: String
    let value: String
    var unit: String = ""
    var icon: String? = nil
    var accentColor: Color = Theme.neonOrange
    var trend: TrendDirection? = nil
    var isCompact: Bool = false
    
    enum TrendDirection {
        case up, down, neutral
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "arrow.right"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return Theme.dangerRed
            case .down: return Theme.successGreen
            case .neutral: return Theme.textSecondary
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? 4 : 8) {
            // Title row
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: isCompact ? 10 : 12, weight: .medium))
                        .foregroundStyle(accentColor)
                }
                
                Text(title.uppercased())
                    .font(isCompact ? Theme.smallCaption : Theme.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(1.2)
            }
            
            // Value row
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(isCompact ? Theme.metricSmall : Theme.metricMedium)
                    .foregroundStyle(Theme.textPrimary)
                
                Text(unit)
                    .font(isCompact ? Theme.smallCaption : Theme.caption)
                    .foregroundStyle(Theme.textTertiary)
                
                Spacer()
                
                if let trend {
                    Image(systemName: trend.icon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(trend.color)
                }
            }
        }
        .padding(isCompact ? Theme.spacingM : Theme.spacingL)
        .background(Theme.slateGray)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
    }
}

/// A horizontal row of metric cards.
struct MetricCardRow: View {
    let metrics: [(title: String, value: String, unit: String, icon: String?, color: Color)]
    
    var body: some View {
        HStack(spacing: Theme.spacingS) {
            ForEach(Array(metrics.enumerated()), id: \.offset) { _, metric in
                MetricCard(
                    title: metric.title,
                    value: metric.value,
                    unit: metric.unit,
                    icon: metric.icon,
                    accentColor: metric.color,
                    isCompact: true
                )
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        MetricCard(
            title: "Distance",
            value: "25.4",
            unit: "km",
            icon: "figure.run",
            accentColor: Theme.neonOrange
        )
        
        MetricCardRow(metrics: [
            ("Elevation", "+842", "m", "arrow.up.right", Theme.neonOrange),
            ("Loss", "-756", "m", "arrow.down.right", Theme.cyan),
            ("Segments", "12", "", "square.stack.fill", Theme.successGreen)
        ])
    }
    .padding()
    .background(Theme.background)
}
