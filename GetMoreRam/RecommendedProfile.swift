//
//  RecommendedProfile.swift
//  GetMoreRam
//
//  Created on 2026-10-07.
//

import Foundation

struct AppProfile: Identifiable {
    var id: String { bundleIDPrefix }
    let bundleIDPrefix: String
    let appName: String
    let iconName: String
    let recommendIML: Bool
    let recommendEVA: Bool
    let reasonVI: String
    let reasonEN: String
    
    var reason: String {
        LocalizationManager.shared.currentLanguage == .vietnamese ? reasonVI : reasonEN
    }
}

enum RecommendedProfiles {
    static let profiles: [AppProfile] = [
        AppProfile(
            bundleIDPrefix: "org.angelauramc.amethyst",
            appName: "Amethyst (Minecraft Java)",
            iconName: "cube.fill",
            recommendIML: true,
            recommendEVA: false,
            reasonVI: "Bắt buộc cần IML để cấp thêm heap memory cho JVM, tránh crash khi load Chunk và Shaders.",
            reasonEN: "IML is essential to provide adequate JVM heap memory, preventing OOM crashes during chunk loading & shaders."
        ),
        AppProfile(
            bundleIDPrefix: "net.kdt.pojavlauncher",
            appName: "PojavLauncher",
            iconName: "terminal.fill",
            recommendIML: true,
            recommendEVA: false,
            reasonVI: "Khuyến nghị IML để phân bổ RAM cao hơn cho Minecraft Java Edition.",
            reasonEN: "IML recommended to allow allocating higher RAM limits for Minecraft Java Edition."
        ),
        AppProfile(
            bundleIDPrefix: "org.dolphin-emu",
            appName: "Dolphin Emulator",
            iconName: "gamecontroller.fill",
            recommendIML: true,
            recommendEVA: true,
            reasonVI: "Cần IML để chạy mượt mà game Wii/GameCube, EVA giúp mở rộng bộ nhớ ảo JIT (nếu có tài khoản Paid).",
            reasonEN: "Requires IML for smooth GameCube/Wii emulation; EVA expands virtual address space for JIT (paid account required)."
        ),
        AppProfile(
            bundleIDPrefix: "com.utmapp",
            appName: "UTM Virtual Machine",
            iconName: "desktopcomputer",
            recommendIML: true,
            recommendEVA: true,
            reasonVI: "Máy ảo cần IML để gán RAM cho hệ điều hành khách (Windows/Linux).",
            reasonEN: "Virtual machines require IML to allocate sufficient RAM to guest OS (Windows/Linux)."
        ),
        AppProfile(
            bundleIDPrefix: "com.stossy11.melonx",
            appName: "MeloNX (Switch)",
            iconName: "gamecontroller",
            recommendIML: true,
            recommendEVA: true,
            reasonVI: "Giả lập Nintendo Switch ngốn rất nhiều RAM, cần IML + EVA để tránh crash.",
            reasonEN: "Nintendo Switch emulation is memory intensive; requires IML + EVA to prevent crashes."
        ),
        AppProfile(
            bundleIDPrefix: "org.ppsspp",
            appName: "PPSSPP",
            iconName: "play.tv.fill",
            recommendIML: true,
            recommendEVA: false,
            reasonVI: "Khuyến nghị IML để chạy texture packs độ phân giải cao mượt mà.",
            reasonEN: "IML recommended for smooth rendering with high-resolution texture packs."
        ),
        AppProfile(
            bundleIDPrefix: "com.libretro",
            appName: "RetroArch",
            iconName: "arcade.stick.console.fill",
            recommendIML: true,
            recommendEVA: false,
            reasonVI: "Khuyến nghị IML cho các core giả lập nặng (PS1, N64, Saturn).",
            reasonEN: "IML recommended for demanding emulation cores (PS1, N64, Saturn)."
        )
    ]
    
    static func match(bundleID: String) -> AppProfile? {
        let lower = bundleID.lowercased()
        return profiles.first { lower.contains($0.bundleIDPrefix.lowercased()) }
    }
}
