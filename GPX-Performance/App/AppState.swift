//
//  AppState.swift
//  GPX-Performance
//
//  Created by GPX-Performance Team.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// Global app state managing the GPX import → analysis → strategy pipeline.
@Observable
final class AppState {
    
    /// The generated race strategy (nil until GPX is processed).
    var currentStrategy: RaceStrategy?
    
    /// Whether a GPX file is currently being processed.
    var isProcessing: Bool = false
    
    /// Error message from import/parsing.
    var importError: String?
    
    /// Whether the file importer sheet is presented.
    var showingFileImporter: Bool = false
    
    /// Whether the paste XML sheet/modal is presented.
    var showingPasteSheet: Bool = false
    
    /// Selected checkpoint for editing COT / details.
    var selectedCheckpoint: Checkpoint?
    
    /// Whether the checkpoint editor sheet is presented.
    var showingCheckpointEditor: Bool = false
    
    /// User's base pace in seconds per km.
    var basePaceSecondsPerKm: Double = 360 // 6:00/km default
    
    /// Navigation path
    var navigationPath = NavigationPath()
    
    /// Processing progress (0.0 to 1.0).
    var processingProgress: Double = 0
    
    /// Processing status message.
    var processingStatus: String = ""
    
    // MARK: - GPX Import from File URL
    
    /// Import and process a GPX file from a URL.
    func importGPX(from url: URL) {
        isProcessing = true
        importError = nil
        processingProgress = 0
        processingStatus = "Membuka file GPX..."
        
        Task { @MainActor in
            let accessing = url.startAccessingSecurityScopedResource()
            defer {
                if accessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            do {
                // Step 1: Read Data safely
                processingProgress = 0.15
                processingStatus = "Membaca data file..."
                
                var fileData: Data?
                var coordinateError: NSError?
                let coordinator = NSFileCoordinator()
                
                coordinator.coordinate(readingItemAt: url, options: .withoutChanges, error: &coordinateError) { readURL in
                    fileData = try? Data(contentsOf: readURL)
                }
                
                if let coordinateError {
                    print("Coordination warning: \(coordinateError.localizedDescription)")
                }
                
                guard let data = fileData ?? (try? Data(contentsOf: url)), !data.isEmpty else {
                    throw GPXImportError.fileAccessDenied
                }
                
                // Step 2: Parse GPX
                processingProgress = 0.35
                processingStatus = "Mem-parsing titik elevasi & koordinat..."
                
                let parser = GPXParser()
                let result = try parser.parse(data: data)
                
                guard !result.trackPoints.isEmpty else {
                    throw GPXImportError.noTrackPoints
                }
                
                // Step 3: Analyze & Generate Strategy
                processingProgress = 0.65
                processingStatus = "Menganalisis profil elevasi & grade..."
                
                try await Task.sleep(for: .milliseconds(300))
                
                processingProgress = 0.85
                processingStatus = "Menghitung strategi pacing (GAP)..."
                
                let strategy = StrategyEngine.generateStrategy(
                    from: result,
                    basePaceSecondsPerKm: basePaceSecondsPerKm
                )
                
                try await Task.sleep(for: .milliseconds(200))
                
                processingProgress = 1.0
                processingStatus = "Strategi rute siap!"
                
                try await Task.sleep(for: .milliseconds(200))
                
                currentStrategy = strategy
                isProcessing = false
                
            } catch {
                importError = error.localizedDescription
                isProcessing = false
            }
        }
    }
    
    // MARK: - GPX Import from Raw String
    
    /// Import and process raw GPX XML string (e.g. from Clipboard / Paste).
    func importGPXString(_ rawXML: String) {
        let trimmed = rawXML.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            importError = "Teks XML kosong."
            return
        }
        
        isProcessing = true
        importError = nil
        processingProgress = 0.2
        processingStatus = "Mem-parsing teks XML GPX..."
        
        Task { @MainActor in
            do {
                let parser = GPXParser()
                let result = try parser.parse(xmlString: trimmed)
                
                guard !result.trackPoints.isEmpty else {
                    throw GPXImportError.noTrackPoints
                }
                
                processingProgress = 0.6
                processingStatus = "Menganalisis profil elevasi..."
                
                try await Task.sleep(for: .milliseconds(300))
                
                processingProgress = 0.85
                processingStatus = "Menyusun zonasi rute..."
                
                let strategy = StrategyEngine.generateStrategy(
                    from: result,
                    basePaceSecondsPerKm: basePaceSecondsPerKm
                )
                
                try await Task.sleep(for: .milliseconds(200))
                
                processingProgress = 1.0
                processingStatus = "Strategi rute siap!"
                
                currentStrategy = strategy
                isProcessing = false
                showingPasteSheet = false
                
            } catch {
                importError = error.localizedDescription
                isProcessing = false
            }
        }
    }
    
    // MARK: - Sample Course
    
    /// Load the bundled sample GPX course.
    func loadSampleCourse() {
        isProcessing = true
        importError = nil
        processingProgress = 0
        processingStatus = "Memuat rute contoh..."
        
        Task { @MainActor in
            do {
                processingProgress = 0.2
                processingStatus = "Membaca data trail..."
                
                let parser = GPXParser()
                let result = try parser.parseBundledFile(named: "sample_trail")
                
                try await Task.sleep(for: .milliseconds(300))
                
                processingProgress = 0.6
                processingStatus = "Menganalisis elevasi..."
                
                try await Task.sleep(for: .milliseconds(200))
                
                processingProgress = 0.8
                processingStatus = "Menghitung zonasi pacing..."
                
                let strategy = StrategyEngine.generateStrategy(
                    from: result,
                    basePaceSecondsPerKm: basePaceSecondsPerKm
                )
                
                try await Task.sleep(for: .milliseconds(200))
                
                processingProgress = 1.0
                processingStatus = "Rute siap!"
                
                try await Task.sleep(for: .milliseconds(150))
                
                currentStrategy = strategy
                isProcessing = false
                
            } catch {
                importError = error.localizedDescription
                isProcessing = false
            }
        }
    }
    
    /// Update base flat pace and instantly recalculate all segment GAP paces and arrival times.
    func updateBasePace(_ newPace: Double) {
        basePaceSecondsPerKm = newPace
        guard let current = currentStrategy else { return }
        currentStrategy = StrategyEngine.recalculatePacing(strategy: current, newBasePaceSecondsPerKm: newPace)
    }
    
    /// Update a checkpoint with custom cut-off times or details.
    func updateCheckpoint(_ updated: Checkpoint) {
        guard let current = currentStrategy else { return }
        let updatedCheckpoints = current.checkpoints.map { cp in
            cp.id == updated.id ? updated : cp
        }
        currentStrategy = RaceStrategy(
            id: current.id,
            courseName: current.courseName,
            segments: current.segments,
            checkpoints: updatedCheckpoints,
            allTrackPoints: current.allTrackPoints,
            pacingZone: current.pacingZone,
            createdAt: current.createdAt
        )
    }
    
    /// Clear the current strategy and return to onboarding.
    func clearStrategy() {
        currentStrategy = nil
        navigationPath = NavigationPath()
    }
    
    /// Dismiss error.
    func dismissError() {
        importError = nil
    }
}

// MARK: - Errors

enum GPXImportError: LocalizedError {
    case noTrackPoints
    case fileAccessDenied
    
    var errorDescription: String? {
        switch self {
        case .noTrackPoints:
            return "Tidak ditemukan titik rute (track/route points) dalam file GPX ini. Pastikan file memiliki tag <trkpt> atau <rtept>."
        case .fileAccessDenied:
            return "Tidak dapat mengakses file yang dipilih dari sistem iOS Files. Silakan coba lagi atau salin teks XML GPX."
        }
    }
}

// MARK: - GPX UTTypes

extension UTType {
    /// Supported GPX UTTypes to ensure files in iOS Files app are never grayed out.
    static let gpxTypes: [UTType] = {
        var types: [UTType] = [
            .xml,
            .plainText,
            .data,
            .item,
            .content
        ]
        if let gpxCustom = UTType(filenameExtension: "gpx") {
            types.insert(gpxCustom, at: 0)
        }
        if let gpxStandard = UTType("com.topografix.gpx") {
            types.insert(gpxStandard, at: 0)
        }
        return types
    }()
}
