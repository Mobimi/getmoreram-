//
//  AppIDViewModel.swift
//  GetMoreRam
//
//  Created by s s on 2025/3/15.
//  Enhanced on 2026-10-07.
//

import SwiftUI
import StosSign_API
import StosSign_Auth
import StosSign_Common

enum FilterMode: String, CaseIterable, Identifiable {
    case all
    case favorites
    case enabled
    case needsApply
    case recommended
    
    var id: String { rawValue }
    
    var localizedTitle: String {
        switch self {
        case .all: return L("All")
        case .favorites: return L("Favorites")
        case .enabled: return L("Enabled")
        case .needsApply: return L("Needs Apply")
        case .recommended: return L("Recommended")
        }
    }
}

class AppIDModel: ObservableObject, Hashable, Identifiable {
    static func == (lhs: AppIDModel, rhs: AppIDModel) -> Bool {
        return lhs.appID.identifier == rhs.appID.identifier && lhs.bundleID == rhs.bundleID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(appID.identifier)
        hasher.combine(bundleID)
    }
    
    var id: String {
        appID.identifier.isEmpty ? bundleID : appID.identifier
    }
    
    var appID: AppID
    @Published var bundleID: String
    @Published var name: String
    @Published var result: String = ""
    @Published var isApplying: Bool = false
    @Published var hasIML: Bool = false
    @Published var hasEVA: Bool = false
    @Published var isFavorite: Bool = false
    @Published var lastAppliedDate: Date? = nil
    
    var recommendedProfile: AppProfile? {
        RecommendedProfiles.match(bundleID: bundleID)
    }
    
    init(appID: AppID) {
        self.appID = appID
        self.bundleID = appID.bundleIdentifier
        self.name = appID.name.isEmpty ? appID.bundleIdentifier : appID.name
        self.hasIML = Self.detectIML(appID: appID)
        self.hasEVA = Self.detectEVA(appID: appID)
        self.isFavorite = Self.checkFavorite(bundleID: appID.bundleIdentifier)
    }
    
    private static func detectIML(appID: AppID) -> Bool {
        if appID.entitlements.contains(where: {
            $0.contains("increased-memory-limit") || $0.contains("INCREASED_MEMORY_LIMIT")
        }) {
            return true
        }
        if appID.features.keys.contains(where: {
            $0.contains("INCREASED_MEMORY_LIMIT") || $0.contains("increased-memory-limit")
        }) {
            return true
        }
        return false
    }
    
    private static func detectEVA(appID: AppID) -> Bool {
        if appID.entitlements.contains(where: {
            $0.contains("extended-virtual-addressing") || $0.contains("EXTENDED_VIRTUAL_ADDRESSING")
        }) {
            return true
        }
        if appID.features.keys.contains(where: {
            $0.contains("EXTENDED_VIRTUAL_ADDRESSING") || $0.contains("extended-virtual-addressing")
        }) {
            return true
        }
        return false
    }
    
    private static func checkFavorite(bundleID: String) -> Bool {
        let favorites = UserDefaults.standard.stringArray(forKey: "FavoriteAppIDs") ?? []
        return favorites.contains(bundleID)
    }
    
    func toggleFavorite() {
        var favorites = UserDefaults.standard.stringArray(forKey: "FavoriteAppIDs") ?? []
        if isFavorite {
            favorites.removeAll(where: { $0 == bundleID })
            isFavorite = false
        } else {
            if !favorites.contains(bundleID) {
                favorites.append(bundleID)
            }
            isFavorite = true
        }
        UserDefaults.standard.set(favorites, forKey: "FavoriteAppIDs")
    }
    
    func applyCapabilities(iml: Bool = true, eva: Bool = false) async throws {
        guard let team = DataManager.shared.model.team, let session = DataManager.shared.model.session else {
            LogManager.shared.log("Apply failed: No active login session", level: .error, tag: bundleID)
            throw L("Please Login First")
        }
        
        await MainActor.run {
            self.isApplying = true
        }
        
        defer {
            Task { @MainActor in
                self.isApplying = false
            }
        }
        
        var capabilities: [String] = []
        if iml { capabilities.append("INCREASED_MEMORY_LIMIT") }
        if eva { capabilities.append("EXTENDED_VIRTUAL_ADDRESSING") }
        
        if capabilities.isEmpty {
            capabilities.append("INCREASED_MEMORY_LIMIT")
        }
        
        LogManager.shared.log("Updating capabilities \(capabilities) for \(bundleID)...", level: .info, tag: "AppleAPI")
        
        do {
            let updated = try await AppleAPI.shared.updateAppID(appID, capabilities: capabilities, team: team, session: session)
            
            await MainActor.run {
                self.appID = updated
                self.hasIML = Self.detectIML(appID: updated) || iml
                self.hasEVA = Self.detectEVA(appID: updated) || eva
                self.lastAppliedDate = Date()
                self.result = "Success: \(updated)"
                LogManager.shared.log("Successfully applied capabilities for \(bundleID)", level: .success, tag: "AppleAPI")
            }
        } catch {
            let desc = error.detailedDescription
            await MainActor.run {
                self.result = "Error: \(desc)"
                LogManager.shared.log("Failed to apply for \(bundleID): \(desc)", level: .error, tag: "AppleAPI")
            }
            throw error
        }
    }
    
    func addIncreasedMemory() async throws {
        try await applyCapabilities(iml: true, eva: false)
    }
    
    func oneTapApplyAndVerify() async throws {
        try await applyCapabilities(iml: true, eva: false)
    }
}

@MainActor
class AppIDViewModel: ObservableObject {
    @Published var appIDs: [AppIDModel] = []
    @Published var searchText: String = ""
    @Published var selectedFilter: FilterMode = .all
    @Published var isLoading: Bool = false
    
    // Batch Apply State
    @Published var isBatchMode: Bool = false
    @Published var selectedIDs: Set<String> = []
    @Published var isBatchProcessing: Bool = false
    @Published var batchProgress: Double = 0.0
    @Published var batchStatusMessage: String = ""
    
    // Duplicates and Team Warnings
    @Published var duplicateBundleIDs: [String] = []
    
    var filteredAppIDs: [AppIDModel] {
        var list = appIDs
        
        // Filter by Search Text
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let query = searchText.lowercased()
            list = list.filter {
                $0.bundleID.lowercased().contains(query) ||
                $0.name.lowercased().contains(query)
            }
        }
        
        // Filter by Category
        switch selectedFilter {
        case .all:
            break
        case .favorites:
            list = list.filter { $0.isFavorite }
        case .enabled:
            list = list.filter { $0.hasIML || $0.hasEVA }
        case .needsApply:
            list = list.filter { !$0.hasIML && !$0.hasEVA }
        case .recommended:
            list = list.filter { $0.recommendedProfile != nil }
        }
        
        // Sort: Favorites first, then alphabetical by bundleID
        return list.sorted {
            if $0.isFavorite != $1.isFavorite {
                return $0.isFavorite && !$1.isFavorite
            }
            return $0.bundleID.localizedCompare($1.bundleID) == .orderedAscending
        }
    }
    
    func fetchAppIDs(retryCount: Int = 1) async throws {
        guard let team = DataManager.shared.model.team, let session = DataManager.shared.model.session else {
            LogManager.shared.log("fetchAppIDs called without login session", level: .error, tag: "AppID")
            throw L("Please Login First")
        }
        
        isLoading = true
        LogManager.shared.log("Fetching App IDs for Team: \(team.identifier)...", level: .info, tag: "AppleAPI")
        
        do {
            let ids = try await AppleAPI.shared.fetchAppIDsForTeam(team: team, session: session)
            
            var models: [AppIDModel] = []
            var bundleCounts: [String: Int] = [:]
            
            for id in ids {
                let model = AppIDModel(appID: id)
                models.append(model)
                bundleCounts[model.bundleID, default: 0] += 1
            }
            
            self.appIDs = models
            self.duplicateBundleIDs = bundleCounts.filter { $0.value > 1 }.map { $0.key }
            self.isLoading = false
            
            LogManager.shared.log("Fetched \(models.count) App IDs successfully", level: .success, tag: "AppleAPI")
            if !self.duplicateBundleIDs.isEmpty {
                LogManager.shared.log("Found duplicate App IDs: \(self.duplicateBundleIDs)", level: .warning, tag: "Validation")
            }
        } catch {
            if retryCount > 0 {
                LogManager.shared.log("Fetch failed, retrying in 1.5s...", level: .warning, tag: "AppleAPI")
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                try await fetchAppIDs(retryCount: retryCount - 1)
            } else {
                self.isLoading = false
                LogManager.shared.log("Failed to fetch App IDs: \(error.localizedDescription)", level: .error, tag: "AppleAPI")
                throw error
            }
        }
    }
    
    // Batch Selection Operations
    func toggleSelection(for id: String) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }
    
    func selectAllFiltered() {
        for item in filteredAppIDs {
            selectedIDs.insert(item.id)
        }
    }
    
    func deselectAll() {
        selectedIDs.removeAll()
    }
    
    func applyBatch(iml: Bool = true, eva: Bool = false) async {
        guard !selectedIDs.isEmpty else { return }
        
        isBatchProcessing = true
        batchProgress = 0.0
        
        let targets = appIDs.filter { selectedIDs.contains($0.id) }
        let total = targets.count
        var successCount = 0
        var failCount = 0
        
        LogManager.shared.log("Starting Batch Apply for \(total) apps...", level: .info, tag: "Batch")
        
        for (index, app) in targets.enumerated() {
            batchStatusMessage = "(\(index + 1)/\(total)) \(app.bundleID)"
            batchProgress = Double(index) / Double(total)
            
            do {
                try await app.applyCapabilities(iml: iml, eva: eva)
                successCount += 1
                try? await Task.sleep(nanoseconds: 300_000_000)
            } catch {
                failCount += 1
                LogManager.shared.log("Batch error on \(app.bundleID): \(error.localizedDescription)", level: .error, tag: "Batch")
            }
        }
        
        batchProgress = 1.0
        batchStatusMessage = "Done: \(successCount) OK, \(failCount) Failed"
        LogManager.shared.log("Batch Apply completed: \(successCount) successful, \(failCount) failed", level: .info, tag: "Batch")
        
        try? await Task.sleep(nanoseconds: 800_000_000)
        isBatchProcessing = false
        isBatchMode = false
        selectedIDs.removeAll()
    }
}
