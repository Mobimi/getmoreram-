//
//  AppIDView.swift
//  GetMoreRam
//
//  Created by s s on 2025/3/15.
//  Redesigned on 2026-10-07.
//

import SwiftUI

struct AppIDEditView: View {
    @ObservedObject var viewModel: AppIDModel
    
    @State private var enableIML: Bool = true
    @State private var enableEVA: Bool = false
    @State private var errorShow = false
    @State private var errorInfo = ""
    @State private var showSuccessAlert = false
    
    var body: some View {
        Form {
            // App Information
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.name)
                        .font(.headline)
                    Text(viewModel.bundleID)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }
                .padding(.vertical, 2)
            } header: {
                Text(L("App Details"))
            }
            
            // Recommended Profile Banner
            if let profile = viewModel.recommendedProfile {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: profile.iconName)
                            .font(.title2)
                            .foregroundStyle(.purple)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.appName)
                                .font(.subheadline)
                                .fontWeight(.bold)
                            Text(profile.reason)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text(L("Recommended"))
                }
            }
            
            // Capabilities Config
            Section {
                Toggle(isOn: $enableIML) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L("Increased Memory Limit"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("com.apple.developer.kernel.increased-memory-limit")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Toggle(isOn: $enableEVA) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L("Extended Virtual Addressing"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("com.apple.developer.kernel.extended-virtual-addressing")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if enableEVA {
                    Text(L("EVA Warning"))
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            } header: {
                Text("Cấu Hình Quyền")
            } footer: {
                Text("Chọn quyền bạn muốn Apple cấp phát cho App ID này.")
            }
            
            // Action Buttons
            Section {
                Button {
                    Task { await applyChanges() }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isApplying {
                            ProgressView()
                                .padding(.trailing, 6)
                        }
                        Text(L("One-Tap Apply"))
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
                .disabled(viewModel.isApplying || (!enableIML && !enableEVA))
            }
            
            // Server Response
            if !viewModel.result.isEmpty {
                Section {
                    Text(viewModel.result)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                } header: {
                    Text(L("Server Response"))
                }
            }
        }
        .onAppear {
            enableIML = viewModel.hasIML || true
            enableEVA = viewModel.hasEVA
        }
        .alert(L("Error"), isPresented: $errorShow) {
            Button("OK", action: {})
        } message: {
            Text(errorInfo)
        }
        .alert(L("Success"), isPresented: $showSuccessAlert) {
            Button("OK", action: {})
        } message: {
            Text("Đã cập nhật quyền thành công trên Apple Developer Portal! Hãy re-install app từ SideStore/AltStore.")
        }
        .navigationTitle(viewModel.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func applyChanges() async {
        do {
            try await viewModel.applyCapabilities(iml: enableIML, eva: enableEVA)
            showSuccessAlert = true
        } catch {
            errorInfo = error.detailedDescription
            errorShow = true
        }
    }
}

struct AppIDView: View {
    @StateObject var viewModel: AppIDViewModel
    
    @State private var errorShow = false
    @State private var errorInfo = ""
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 12) {
                        // Device RAM Card
                        DeviceMemoryCardView()
                        
                        // Duplicate Warning Banner
                        if !viewModel.duplicateBundleIDs.isEmpty {
                            duplicateWarningBanner
                        }
                        
                        // Filter Chips Bar
                        filterBar
                        
                        // Batch Mode Actions Header
                        if viewModel.isBatchMode {
                            batchActionBar
                        }
                        
                        // App List
                        if viewModel.isLoading {
                            ProgressView(L("Loading App IDs..."))
                                .padding(.top, 40)
                        } else if viewModel.filteredAppIDs.isEmpty {
                            emptyStateView
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(viewModel.filteredAppIDs) { app in
                                    AppCardRow(
                                        app: app,
                                        isBatchMode: viewModel.isBatchMode,
                                        isSelected: viewModel.selectedIDs.contains(app.id)
                                    ) {
                                        if viewModel.isBatchMode {
                                            viewModel.toggleSelection(for: app.id)
                                        }
                                    } onOneTapApply: {
                                        Task {
                                            do {
                                                try await app.oneTapApplyAndVerify()
                                            } catch {
                                                errorInfo = error.detailedDescription
                                                errorShow = true
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, viewModel.isBatchMode ? 80 : 20)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .refreshable {
                    await refreshData()
                }
                
                // Floating Batch Apply Bar
                if viewModel.isBatchMode && !viewModel.selectedIDs.isEmpty {
                    floatingBatchButton
                }
            }
            .searchable(text: $viewModel.searchText, prompt: L("Search apps..."))
            .navigationTitle(L("App IDs"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(viewModel.isBatchMode ? L("Done") : L("Batch Apply")) {
                        withAnimation {
                            viewModel.isBatchMode.toggle()
                            if !viewModel.isBatchMode {
                                viewModel.deselectAll()
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await refreshData() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .alert(L("Error"), isPresented: $errorShow) {
                Button("OK", action: {})
            } message: {
                Text(errorInfo)
            }
            .sheet(isPresented: $viewModel.isBatchProcessing) {
                batchProgressSheet
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var duplicateWarningBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(L("Duplicate App IDs Detected"))
                    .font(.footnote)
                    .fontWeight(.bold)
                Text(viewModel.duplicateBundleIDs.joined(separator: ", "))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.orange.opacity(0.12))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FilterMode.allCases) { mode in
                    FilterChip(title: mode.localizedTitle, isSelected: viewModel.selectedFilter == mode) {
                        viewModel.selectedFilter = mode
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    var batchActionBar: some View {
        HStack {
            Button(L("Select All")) {
                viewModel.selectAllFiltered()
            }
            .font(.footnote)
            
            Spacer()
            
            Text("Đã chọn \(viewModel.selectedIDs.count)")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Button(L("Deselect All")) {
                viewModel.deselectAll()
            }
            .font(.footnote)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
    
    var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 40)
            Image(systemName: "square.stack.3d.slash")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(L("No App IDs found"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button(L("Refresh")) {
                Task { await refreshData() }
            }
            .buttonStyle(.bordered)
        }
    }
    
    var floatingBatchButton: some View {
        Button {
            Task {
                await viewModel.applyBatch(iml: true, eva: false)
            }
        } label: {
            HStack {
                Image(systemName: "bolt.fill")
                Text("Áp dụng IML cho \(viewModel.selectedIDs.count) apps")
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundStyle(.white)
            .cornerRadius(16)
            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    var batchProgressSheet: some View {
        VStack(spacing: 20) {
            Text("Đang xử lý hàng loạt...")
                .font(.headline)
            
            ProgressView(value: viewModel.batchProgress, total: 1.0)
                .progressViewStyle(.linear)
                .padding(.horizontal)
            
            Text(viewModel.batchStatusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(30)
        .presentationDetents([.fraction(0.3)])
    }
    
    func refreshData() async {
        do {
            try await viewModel.fetchAppIDs()
        } catch {
            errorInfo = error.detailedDescription
            errorShow = true
        }
    }
}

struct AppCardRow: View {
    @ObservedObject var app: AppIDModel
    let isBatchMode: Bool
    let isSelected: Bool
    let onSelectToggle: () -> Void
    let onOneTapApply: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox for batch mode
            if isBatchMode {
                Button(action: onSelectToggle) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isSelected ? .blue : .secondary)
                }
            }
            
            // Star Favorite Button
            Button {
                app.toggleFavorite()
            } label: {
                Image(systemName: app.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(app.isFavorite ? .yellow : .secondary.opacity(0.5))
            }
            .buttonStyle(.plain)
            
            // App Info Navigation Link
            NavigationLink {
                AppIDEditView(viewModel: app)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(app.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    
                    Text(app.bundleID)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    // Badges
                    HStack(spacing: 6) {
                        if app.hasIML {
                            badgeText("IML ON", color: .green)
                        }
                        if app.hasEVA {
                            badgeText("EVA ON", color: .blue)
                        }
                        if !app.hasIML && !app.hasEVA {
                            badgeText(L("Needs Apply"), color: .orange)
                        }
                        if app.recommendedProfile != nil {
                            badgeText(L("Recommended"), color: .purple)
                        }
                    }
                    .padding(.top, 2)
                }
            }
            
            // Quick One-Tap Button
            if !isBatchMode && !app.hasIML {
                Button {
                    onOneTapApply()
                } label: {
                    if app.isApplying {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "bolt.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
                .buttonStyle(.plain)
                .disabled(app.isApplying)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
    
    func badgeText(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .cornerRadius(4)
    }
}
