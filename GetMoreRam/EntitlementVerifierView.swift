//
//  EntitlementVerifierView.swift
//  GetMoreRam
//
//  Created on 2026-10-07.
//

import SwiftUI
import UniformTypeIdentifiers

struct EntitlementVerifierView: View {
    @State private var isPickerPresented = false
    @State private var parsedProfile: ParsedProvisioningProfile? = nil
    @State private var errorMessage: String? = nil
    @State private var isVerifying = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header card
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L("Verify Mobileprovision"))
                            .font(.headline)
                        Text("Chọn file .mobileprovision hoặc app đã xuất để kiểm tra xem Apple có thật sự cấp quyền IML/EVA hay chưa.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Button {
                            isPickerPresented = true
                        } label: {
                            HStack {
                                Image(systemName: "doc.badge.plus")
                                Text(L("Select File"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                            .fontWeight(.semibold)
                        }
                        .padding(.top, 4)
                    }
                    .padding(16)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    if let error = errorMessage {
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.title)
                                .foregroundStyle(.red)
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                    
                    if let profile = parsedProfile {
                        profileDetailsSection(profile)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(L("Verifier"))
            .navigationBarTitleDisplayMode(.inline)
            .fileImporter(
                isPresented: $isPickerPresented,
                allowedContentTypes: [.item],
                allowsMultipleSelection: false
            ) { result in
                handleFilePicked(result)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func profileDetailsSection(_ profile: ParsedProvisioningProfile) -> some View {
        VStack(spacing: 16) {
            // Memory Capabilities Status Card
            VStack(alignment: .leading, spacing: 12) {
                Text(L("Entitlements Summary"))
                    .font(.headline)
                
                HStack {
                    Text(L("Increased Memory Limit"))
                        .font(.subheadline)
                    Spacer()
                    if profile.hasIML {
                        Text("ON ✅")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                    } else {
                        Text("OFF ❌")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.red)
                    }
                }
                .padding(.vertical, 4)
                
                Divider()
                
                HStack {
                    Text(L("Extended Virtual Addressing"))
                        .font(.subheadline)
                    Spacer()
                    if profile.hasEVA {
                        Text("ON ✅")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                    } else {
                        Text("OFF ❌")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .padding(.horizontal)
            
            // Team ID Mismatch Check
            if let currentTeam = DataManager.shared.model.team?.identifier,
               let profileTeam = profile.teamIdentifier,
               currentTeam != profileTeam {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.orange)
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cảnh báo Team ID không khớp!")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                        Text("Profile được ký bởi team '\(profileTeam)' nhưng tài khoản hiện tại là '\(currentTeam)'.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.12))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            // App Details Card
            VStack(alignment: .leading, spacing: 10) {
                Text(L("App Details"))
                    .font(.headline)
                
                infoRow(label: "Tên Profile", value: profile.name)
                if let appID = profile.appIdentifier {
                    infoRow(label: "App Identifier", value: appID)
                }
                if let team = profile.teamName {
                    infoRow(label: "Team Name", value: team)
                }
                if let teamID = profile.teamIdentifier {
                    infoRow(label: "Team ID", value: teamID)
                }
                infoRow(label: "Hết hạn", value: profile.formattedExpiration)
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
    
    func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.footnote)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
    }
    
    func handleFilePicked(_ result: Result<[URL], Error>) {
        do {
            guard let url = try result.get().first else { return }
            
            let didAccess = url.startAccessingSecurityScopedResource()
            defer {
                if didAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            let data = try Data(contentsOf: url)
            let profile = try MobileProvisionParser.parse(data: data)
            
            self.parsedProfile = profile
            self.errorMessage = nil
            LogManager.shared.log("Parsed provisioning profile: \(profile.name) (IML: \(profile.hasIML), EVA: \(profile.hasEVA))", level: .success, tag: "Verifier")
        } catch {
            self.errorMessage = "Không thể phân tích file: \(error.localizedDescription)"
            LogManager.shared.log("Verifier error: \(error.localizedDescription)", level: .error, tag: "Verifier")
        }
    }
}
