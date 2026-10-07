//
//  DiagnosticsLogView.swift
//  GetMoreRam
//
//  Created on 2026-10-07.
//

import SwiftUI

struct DiagnosticsLogView: View {
    @ObservedObject var logManager = LogManager.shared
    @State private var searchText = ""
    @State private var selectedLevel: LogLevel? = nil
    @State private var shareURL: URL? = nil
    @State private var showShareSheet = false
    
    var filteredLogs: [LogEntry] {
        var result = logManager.logs
        if let level = selectedLevel {
            result = result.filter { $0.level == level }
        }
        if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let query = searchText.lowercased()
            result = result.filter { $0.message.lowercased().contains(query) || $0.tag.lowercased().contains(query) }
        }
        return result
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Segment
                filterBar
                
                // Logs List
                if filteredLogs.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("Chưa có log nào phù hợp")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(filteredLogs) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(entry.level.icon)
                                    Text(entry.tag)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(entry.level.color.opacity(0.15))
                                        .cornerRadius(4)
                                    Spacer()
                                    Text(entry.formattedTime)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Text(entry.message)
                                    .font(.system(.footnote, design: .monospaced))
                                    .foregroundStyle(.primary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .searchable(text: $searchText, prompt: "Tìm kiếm nhật ký...")
            .navigationTitle(L("Logs"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .destructive) {
                        logManager.clearLogs()
                    } label: {
                        Image(systemName: "trash")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            UIPasteboard.general.string = logManager.exportText()
                        } label: {
                            Label(L("Copy"), systemImage: "doc.on.doc")
                        }
                        
                        Button {
                            if let url = logManager.exportToFile() {
                                shareURL = url
                                showShareSheet = true
                            }
                        } label: {
                            Label(L("Export Diagnostics"), systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let shareURL = shareURL {
                    ShareSheet(activityItems: [shareURL])
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: L("All"), isSelected: selectedLevel == nil) {
                    selectedLevel = nil
                }
                FilterChip(title: "Info", isSelected: selectedLevel == .info) {
                    selectedLevel = .info
                }
                FilterChip(title: "Success", isSelected: selectedLevel == .success) {
                    selectedLevel = .success
                }
                FilterChip(title: "Warning", isSelected: selectedLevel == .warning) {
                    selectedLevel = .warning
                }
                FilterChip(title: "Error", isSelected: selectedLevel == .error) {
                    selectedLevel = .error
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.footnote)
                .fontWeight(isSelected ? .bold : .medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(UIColor.secondarySystemFill))
                .foregroundStyle(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
