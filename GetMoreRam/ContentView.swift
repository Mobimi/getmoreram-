//
//  ContentView.swift
//  GetMoreRam
//
//  Created by s s on 2025/3/14.
//  Enhanced on 2026-10-07.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appIDViewModel = AppIDViewModel()
    @StateObject private var loginViewModel = LoginViewModel()
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        TabView {
            AppIDView(viewModel: appIDViewModel)
                .tabItem {
                    Label(L("App IDs"), systemImage: "square.stack.3d.up.fill")
                }
            
            EntitlementVerifierView()
                .tabItem {
                    Label(L("Verifier"), systemImage: "checkmark.seal.fill")
                }
            
            DiagnosticsLogView()
                .tabItem {
                    Label(L("Logs"), systemImage: "doc.plaintext.fill")
                }
            
            SettingsView(viewModel: loginViewModel)
                .tabItem {
                    Label(L("Settings"), systemImage: "gearshape.fill")
                }
        }
        .environmentObject(DataManager.shared.model)
        .environmentObject(localizationManager)
    }
}

#Preview {
    ContentView()
}
