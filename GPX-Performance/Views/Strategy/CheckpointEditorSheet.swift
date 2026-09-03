//
//  CheckpointEditorSheet.swift
//  GPX-Performance
//
//  Created by GPX-Performance Team.
//

import SwiftUI

/// Modal sheet for editing Checkpoint name and Cut-Off Time (COT),
/// calculating safety margins and DNF risk warnings.
struct CheckpointEditorSheet: View {
    let checkpoint: Checkpoint
    var onSave: ((Checkpoint) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var checkpointName: String = ""
    @State private var hasCutOffTime: Bool = false
    @State private var cotHours: Int = 2
    @State private var cotMinutes: Int = 30
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.spacingL) {
                        // Checkpoint Header Card
                        headerCard
                        
                        // Checkpoint Name
                        VStack(alignment: .leading, spacing: Theme.spacingS) {
                            Text("NAMA CHECKPOINT")
                                .font(Theme.caption)
                                .foregroundStyle(Theme.textSecondary)
                                .tracking(1.2)
                            
                            TextField("Nama Checkpoint", text: $checkpointName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.textPrimary)
                                .padding(Theme.spacingM)
                                .background(Theme.slateGray)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall)
                                        .stroke(Theme.borderGray, lineWidth: 1)
                                )
                        }
                        
                        // Cut-Off Time Toggle & Pickers
                        cotSection
                        
                        // Safety Margin Preview
                        safetyMarginCard
                        
                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(Theme.spacingL)
                }
            }
            .navigationTitle("Edit Checkpoint")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Batal") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.textSecondary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Simpan") {
                        saveChanges()
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.neonOrange)
                }
            }
            .onAppear {
                setupInitialValues()
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Subviews
    
    private var headerCard: some View {
        HStack(spacing: Theme.spacingM) {
            ZStack {
                Circle()
                    .fill(Theme.warningYellow.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: checkpoint.type.icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Theme.warningYellow)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(checkpoint.name)
                    .font(Theme.heading)
                    .foregroundStyle(Theme.textPrimary)
                
                Text(String(format: "KM %.1f · Elevasi %.0f m", checkpoint.distanceKm, checkpoint.elevation ?? 0))
                    .font(Theme.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            
            Spacer()
        }
        .padding(Theme.spacingL)
        .background(Theme.slateGray)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
    }
    
    private var cotSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            Toggle(isOn: $hasCutOffTime.animation()) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cut-Off Time (COT)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Batas waktu eliminasi panitia di pos ini")
                        .font(Theme.smallCaption)
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            .tint(Theme.neonOrange)
            
            if hasCutOffTime {
                GlowingDivider(opacity: 0.2)
                
                HStack(spacing: Theme.spacingM) {
                    // Hours
                    VStack(alignment: .leading, spacing: 4) {
                        Text("JAM")
                            .font(Theme.smallCaption)
                            .foregroundStyle(Theme.textTertiary)
                        
                        Picker("Jam", selection: $cotHours) {
                            ForEach(0...24, id: \.self) { h in
                                Text("\(h) jam").tag(h)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Theme.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Theme.surfaceGray)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // Minutes
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MENIT")
                            .font(Theme.smallCaption)
                            .foregroundStyle(Theme.textTertiary)
                        
                        Picker("Menit", selection: $cotMinutes) {
                            ForEach(Array(stride(from: 0, through: 55, by: 5)), id: \.self) { m in
                                Text("\(m) mnt").tag(m)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Theme.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Theme.surfaceGray)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(Theme.spacingL)
        .background(Theme.slateGray)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
    }
    
    private var safetyMarginCard: some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            Text("ANALISIS KEAMANAN COT")
                .font(Theme.smallCaption)
                .foregroundStyle(Theme.textTertiary)
                .tracking(1.0)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Target Tiba (ETA)")
                        .font(Theme.smallCaption)
                        .foregroundStyle(Theme.textSecondary)
                    Text(checkpoint.estimatedArrivalFormatted)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(Theme.textPrimary)
                }
                
                Spacer()
                
                if hasCutOffTime {
                    let totalSeconds = Double(cotHours * 3600 + cotMinutes * 60)
                    let margin = totalSeconds - (checkpoint.estimatedArrivalSeconds ?? 0)
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Margin Keamanan")
                            .font(Theme.smallCaption)
                            .foregroundStyle(Theme.textSecondary)
                        
                        Text(formatMargin(margin))
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundStyle(marginColor(margin))
                    }
                }
            }
        }
        .padding(Theme.spacingL)
        .background(Theme.surfaceGray)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium))
    }
    
    // MARK: - Helpers
    
    private func setupInitialValues() {
        checkpointName = checkpoint.name
        if let cot = checkpoint.cutOffTimeSeconds {
            hasCutOffTime = true
            cotHours = Int(cot) / 3600
            cotMinutes = (Int(cot) % 3600) / 60
        } else {
            hasCutOffTime = false
            let est = checkpoint.estimatedArrivalSeconds ?? 3600
            cotHours = Int(est) / 3600 + 1
            cotMinutes = 0
        }
    }
    
    private func saveChanges() {
        let finalCotSeconds: Double? = hasCutOffTime ? Double(cotHours * 3600 + cotMinutes * 60) : nil
        let updated = Checkpoint(
            id: checkpoint.id,
            name: checkpointName.isEmpty ? checkpoint.name : checkpointName,
            type: checkpoint.type,
            latitude: checkpoint.latitude,
            longitude: checkpoint.longitude,
            distanceFromStart: checkpoint.distanceFromStart,
            cutOffTimeSeconds: finalCotSeconds,
            elevation: checkpoint.elevation,
            estimatedArrivalSeconds: checkpoint.estimatedArrivalSeconds
        )
        onSave?(updated)
    }
    
    private func formatMargin(_ seconds: Double) -> String {
        let mins = Int(abs(seconds)) / 60
        let sign = seconds >= 0 ? "+" : "-"
        return "\(sign)\(mins) menit"
    }
    
    private func marginColor(_ seconds: Double) -> Color {
        if seconds > 1800 { return Theme.successGreen }
        if seconds > 0 { return Theme.warningYellow }
        return Theme.dangerRed
    }
}
