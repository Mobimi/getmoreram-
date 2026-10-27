//
//  SettingsView.swift
//  GetMoreRam
//
//  Created by s s on 2025/3/14.
//  Enhanced on 2026-10-07.
//

import SwiftUI
import UniformTypeIdentifiers
import StosSign_API
import StosSign_Auth
import StosSign_Common

struct SettingsView: View {
    @State var email = ""
    @State var teamId = ""
    @StateObject var viewModel: LoginViewModel
    @EnvironmentObject private var sharedModel: SharedModel
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    @State private var errorShow = false
    @State private var errorInfo = ""
    @State private var importResultShow = false
    @State private var importResultInfo = ""
    @State private var isImportingSideStoreAccount = false

    var body: some View {
        NavigationView {
            Form {
                // Account Section
                Section {
                    if sharedModel.isLogin {
                        HStack {
                            Text(L("Email"))
                            Spacer()
                            Text(email)
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text(L("Team ID"))
                            Spacer()
                            Text(teamId)
                                .font(.system(.body, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                        
                        Button(role: .destructive) {
                            signOut()
                        } label: {
                            Text(L("Sign Out"))
                        }
                    } else {
                        Button(L("Sign in")) {
                            viewModel.loginModalShow = true
                        }
                        
                        Button(L("Import SideStore Account")) {
                            isImportingSideStoreAccount = true
                        }
                    }
                } header: {
                    Text(L("Account"))
                }
                
                // Preferences (Language & UI)
                Section {
                    Picker(L("Language"), selection: $localizationManager.selectedLanguage) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang.rawValue)
                        }
                    }
                } header: {
                    Text("Tuỳ Chọn")
                }
                
                // Anisette Server Configuration
                Section {
                    HStack {
                        Text(L("Anisette Server URL"))
                        Spacer()
                        TextField("", text: $sharedModel.anisetteServerURL)
                            .multilineTextAlignment(.trailing)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                } header: {
                    Text("Anisette")
                } footer: {
                    Text("Máy chủ sinh dữ liệu Anisette để xác thực 2FA với Apple.\nKhuyến nghị: https://new.ani.sidestore.io hoặc https://mac-ani.jkcoxson.com (Mac ADI). Sau khi đổi server, hãy xóa Keychain và đăng nhập lại — Apple sẽ cấp anisette mới và hỏi mã 2FA một lần.")
                }
                
                // Device Hardware Info
                Section {
                    HStack {
                        Text(L("Physical RAM"))
                        Spacer()
                        Text(DeviceMemoryInfo.current.formattedPhysicalMemory)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text(L("Available Budget"))
                        Spacer()
                        Text(DeviceMemoryInfo.current.formattedAvailableMemory)
                            .foregroundStyle(.green)
                    }
                } header: {
                    Text(L("Physical RAM"))
                }
                
                // Troubleshooting & Maintenance
                Section {
                    Button(role: .destructive) {
                        cleanUp()
                    } label: {
                        Text(L("Clean Up Keychain"))
                    }
                } header: {
                    Text("Bảo Trì")
                } footer: {
                    Text("Nếu đăng nhập bị lỗi hoặc session hết hạn, hãy xóa Keychain, mở lại ứng dụng và thử lại.")
                }
                
                // About
                Section {
                    HStack {
                        Text("GetMoreRam")
                        Spacer()
                        Text("v2.0 (Enhanced)")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Thông Tin")
                }
            }
            .navigationTitle(L("Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .alert(L("Error"), isPresented: $errorShow) {
                Button("OK", action: {})
            } message: {
                Text(errorInfo)
            }
            .alert("SideStore Account", isPresented: $importResultShow) {
                Button("OK", action: {})
            } message: {
                Text(importResultInfo)
            }
            .fileImporter(
                isPresented: $isImportingSideStoreAccount,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                importSideStoreAccount(result)
            }
            .sheet(isPresented: $viewModel.loginModalShow, onDismiss: {
                viewModel.cancelAuthentication()
            }) {
                loginModal
            }
            .sheet(isPresented: $viewModel.teamSelectionShow) {
                teamSelectionView
            }
            .onAppear {
                if sharedModel.isLogin {
                    email = sharedModel.account?.appleID ?? email
                    teamId = sharedModel.team?.identifier ?? teamId
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var loginModal: some View {
        NavigationView {
            Form {
                Section {
                    TextField("", text: $viewModel.appleID)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .disabled(viewModel.isLoginInProgress)
                } header: {
                    Text("Apple ID")
                }
                
                Section {
                    SecureField("", text: $viewModel.password)
                        .disabled(viewModel.isLoginInProgress)
                } header: {
                    Text("Password")
                }
                
                if viewModel.needVerificationCode {
                    Section {
                        TextField("", text: $viewModel.verificationCode)
                            .disabled(viewModel.isVerificationCodeSubmitting)
                    } header: {
                        Text("Verification Code")
                    }
                }
                
                Section {
                    Button("Continue") {
                        Task { await loginButtonClicked() }
                    }
                    .disabled(continueButtonDisabled)
                }
                
                Section {
                    Text(viewModel.logs)
                        .font(.system(.subheadline, design: .monospaced))
                } header: {
                    Text("Debugging")
                }
            }
            .navigationTitle(L("Sign in"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(L("Cancel"), role: .cancel) {
                        viewModel.cancelAuthentication()
                        viewModel.loginModalShow = false
                    }
                }
            }
        }
        .onAppear {
            if let email = Keychain.shared.appleIDEmailAddress, let password = Keychain.shared.appleIDPassword {
                viewModel.appleID = email
                viewModel.password = password
            }
        }
    }
    
    var teamSelectionView: some View {
        NavigationView {
            List {
                ForEach(Array(viewModel.availableTeams.enumerated()), id: \.offset) { _, team in
                    Button {
                        selectTeam(team)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(team.name)
                                .foregroundStyle(.primary)
                            Text("\(team.identifier) · \(teamTypeDescription(team.type))")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Chọn Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(L("Cancel"), role: .cancel) {
                        cancelTeamSelection()
                    }
                }
            }
        }
    }
    
    func loginButtonClicked() async {
        do {
            if viewModel.needVerificationCode {
                viewModel.submitVerificationCode()
                return
            }
            
            let result = try await viewModel.authenticate()
            if result {
                await MainActor.run {
                    viewModel.loginModalShow = false
                    email = sharedModel.account!.appleID
                    teamId = ""
                }

                if viewModel.availableTeams.count == 1,
                   let team = viewModel.availableTeams.first {
                    await MainActor.run {
                        selectTeam(team)
                    }
                } else {
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    await MainActor.run {
                        viewModel.teamSelectionShow = true
                    }
                }
            }
        } catch is CancellationError {
            return
        } catch {
            errorInfo = error.detailedDescription
            errorShow = true
        }
    }

    private var continueButtonDisabled: Bool {
        if viewModel.needVerificationCode {
            return viewModel.isVerificationCodeSubmitting ||
                viewModel.verificationCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        return viewModel.isLoginInProgress
    }
    
    func signOut() {
        cleanUp()
    }
    
    func cleanUp() {
        Keychain.shared.adiPb = nil
        Keychain.shared.identifier = nil
        Keychain.shared.appleIDPassword = nil
        Keychain.shared.appleIDEmailAddress = nil
        AnisetteDataHelper.shared.resetClientInfo()
        sharedModel.session = nil
        sharedModel.account = nil
        sharedModel.team = nil
        sharedModel.isLogin = false
        viewModel.availableTeams = []
        viewModel.teamSelectionShow = false
        email = ""
        teamId = ""
        LogManager.shared.log("Keychain cleaned up and signed out", level: .info, tag: "Auth")
    }
    
    func importSideStoreAccount(_ result: Result<[URL], Error>) {
        do {
            guard let url = try result.get().first else {
                throw "No file selected."
            }
            
            let didStartAccessing = url.startAccessingSecurityScopedResource()
            defer {
                if didStartAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            let data = try Data(contentsOf: url)
            let account = try SideStoreAccountImporter.importAccount(from: data)
            
            viewModel.appleID = account.email
            viewModel.password = account.password
            sharedModel.session = nil
            sharedModel.account = nil
            sharedModel.team = nil
            sharedModel.isLogin = false
            viewModel.availableTeams = []
            viewModel.teamSelectionShow = false
            email = account.email
            teamId = ""
            importResultInfo = "Đã nhập tài khoản \(account.email).\nBấm \"Đăng Nhập\" để tiếp tục."
            importResultShow = true
            LogManager.shared.log("Imported SideStore account: \(account.email)", level: .success, tag: "SideStore")
        } catch {
            errorInfo = error.detailedDescription
            errorShow = true
        }
    }
    
    func selectTeam(_ team: Team) {
        sharedModel.team = team
        sharedModel.isLogin = true
        email = sharedModel.account?.appleID ?? email
        teamId = team.identifier
        viewModel.availableTeams = []
        viewModel.teamSelectionShow = false
        LogManager.shared.log("Selected team: \(team.identifier) (\(team.name))", level: .success, tag: "Auth")
    }
    
    func cancelTeamSelection() {
        viewModel.availableTeams = []
        viewModel.teamSelectionShow = false
        sharedModel.session = nil
        sharedModel.account = nil
        sharedModel.team = nil
        sharedModel.isLogin = false
        email = ""
        teamId = ""
    }
    
    func teamTypeDescription(_ type: TeamType) -> String {
        switch type {
        case .free:
            return "Free (7 days)"
        case .individual:
            return "Individual ($99/yr)"
        case .organization:
            return "Organization ($99/yr)"
        case .unknown:
            return "Unknown"
        }
    }
}
