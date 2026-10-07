//
//  LocalizationManager.swift
//  GetMoreRam
//
//  Created on 2026-10-07.
//

import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case vietnamese = "vi"
    case english = "en"
    case system = "auto"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .vietnamese: return "Tiếng Việt 🇻🇳"
        case .english: return "English 🇺🇸"
        case .system: return "Hệ thống / System 🌐"
        }
    }
}

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @AppStorage("AppSelectedLanguage") var selectedLanguage: String = AppLanguage.system.rawValue {
        didSet {
            objectWillChange.send()
        }
    }
    
    var currentLanguage: AppLanguage {
        if selectedLanguage == AppLanguage.vietnamese.rawValue {
            return .vietnamese
        } else if selectedLanguage == AppLanguage.english.rawValue {
            return .english
        } else {
            // Check system language
            let preferred = Locale.preferredLanguages.first ?? "en"
            return preferred.starts(with: "vi") ? .vietnamese : .english
        }
    }
    
    func localized(_ key: String) -> String {
        let isVi = (currentLanguage == .vietnamese)
        
        guard let translations = LocalizedStrings[key] else {
            return key
        }
        
        return isVi ? translations.vi : translations.en
    }
}

// Global helper function for concise translation
func L(_ key: String) -> String {
    LocalizationManager.shared.localized(key)
}

struct Translation {
    let vi: String
    let en: String
}

private let LocalizedStrings: [String: Translation] = [
    // Tabs & Navigation
    "App IDs": Translation(vi: "Danh Sách App", en: "App IDs"),
    "Memory Budget": Translation(vi: "Bộ Nhớ RAM", en: "Memory Budget"),
    "Verifier": Translation(vi: "Kiểm Tra Quyền", en: "Verifier"),
    "Logs": Translation(vi: "Nhật Ký", en: "Logs"),
    "Settings": Translation(vi: "Cài Đặt", en: "Settings"),
    
    // Memory Card
    "Physical RAM": Translation(vi: "RAM Vật Lý", en: "Physical RAM"),
    "Available Budget": Translation(vi: "RAM Cấp Phép Hiện Tại", en: "Current Memory Budget"),
    "Estimated Limit (Default)": Translation(vi: "Giới hạn mặc định (Không IML)", en: "Default Limit (No IML)"),
    "Estimated Limit (With IML)": Translation(vi: "Giới hạn sau khi có IML", en: "Limit with IML Enabled"),
    "Memory Info": Translation(vi: "Thông Tin Bộ Nhớ", en: "Memory Information"),
    "Memory Info Description": Translation(
        vi: "Khi chưa có IML, iOS giới hạn mỗi app dùng tối đa ~2-3 GB RAM. Sau khi bật IML, app có thể dùng lên tới ~4-5 GB trước khi bị hệ thống kill.",
        en: "Without IML, iOS caps each app at ~2-3 GB RAM. Enabling IML allows the app to allocate up to ~4-5 GB before being terminated."
    ),
    
    // Actions & Buttons
    "Refresh": Translation(vi: "Làm Mới", en: "Refresh"),
    "Search apps...": Translation(vi: "Tìm kiếm app hoặc Bundle ID...", en: "Search apps or Bundle ID..."),
    "Apply": Translation(vi: "Áp Dụng", en: "Apply"),
    "One-Tap Apply": Translation(vi: "Áp Dụng Nhanh (One-Tap)", en: "One-Tap Apply"),
    "Batch Apply": Translation(vi: "Áp Dụng Hàng Loạt", en: "Batch Apply"),
    "Select All": Translation(vi: "Chọn Tất Cả", en: "Select All"),
    "Deselect All": Translation(vi: "Bỏ Chọn Tất Cả", en: "Deselect All"),
    "Cancel": Translation(vi: "Hủy", en: "Cancel"),
    "Done": Translation(vi: "Xong", en: "Done"),
    "Close": Translation(vi: "Đóng", en: "Close"),
    "Copy": Translation(vi: "Sao Chép", en: "Copy"),
    "Share": Translation(vi: "Chia Sẻ", en: "Share"),
    "Clear": Translation(vi: "Xóa Hết", en: "Clear"),
    "Export Diagnostics": Translation(vi: "Xuất Báo Cáo Chẩn Đoán", en: "Export Diagnostics"),
    "Clean Up Keychain": Translation(vi: "Xóa Dữ Liệu Keychain", en: "Clean Up Keychain"),
    "Sign in": Translation(vi: "Đăng Nhập", en: "Sign in"),
    "Sign Out": Translation(vi: "Đăng Xuất", en: "Sign Out"),
    "Import SideStore Account": Translation(vi: "Nhập Tài Khoản Từ SideStore", en: "Import SideStore Account"),
    
    // Capabilities
    "Increased Memory Limit": Translation(vi: "Increased Memory Limit (IML)", en: "Increased Memory Limit (IML)"),
    "Extended Virtual Addressing": Translation(vi: "Extended Virtual Addressing (EVA)", en: "Extended Virtual Addressing (EVA)"),
    "Already Enabled": Translation(vi: "Đã Kích Hoạt", en: "Already Enabled"),
    "Not Enabled": Translation(vi: "Chưa Kích Hoạt", en: "Not Enabled"),
    "EVA Warning": Translation(
        vi: "Apple chỉ cấp quyền Extended Virtual Addressing cho tài khoản Paid Developer ($99/năm). Tài khoản Free sẽ bị Apple từ chối.",
        en: "Apple only grants Extended Virtual Addressing to Paid Developer Accounts ($99/yr). Free accounts will be rejected by Apple."
    ),
    
    // Filter
    "All": Translation(vi: "Tất Cả", en: "All"),
    "Favorites": Translation(vi: "Đã Ghim ⭐", en: "Favorites ⭐"),
    "Enabled": Translation(vi: "Đã Bật", en: "Enabled"),
    "Needs Apply": Translation(vi: "Chưa Bật", en: "Needs Apply"),
    "Recommended": Translation(vi: "Khuyến Nghị 🎯", en: "Recommended 🎯"),
    
    // Status & Feedback
    "Please Login First": Translation(vi: "Vui lòng đăng nhập tài khoản Apple trước", en: "Please Login First"),
    "Loading App IDs...": Translation(vi: "Đang tải danh sách App ID...", en: "Loading App IDs..."),
    "No App IDs found": Translation(vi: "Không tìm thấy App ID nào", en: "No App IDs found"),
    "Success": Translation(vi: "Thành Công", en: "Success"),
    "Error": Translation(vi: "Lỗi", en: "Error"),
    "Server Response": Translation(vi: "Phản Hồi Từ Máy Chủ Apple", en: "Server Response"),
    "Language": Translation(vi: "Ngôn Ngữ", en: "Language"),
    "Appearance": Translation(vi: "Giao Diện", en: "Appearance"),
    "Account": Translation(vi: "Tài Khoản Apple", en: "Apple Account"),
    "Team ID": Translation(vi: "Team ID", en: "Team ID"),
    "Email": Translation(vi: "Email", en: "Email"),
    "Anisette Server URL": Translation(vi: "Máy Chủ Anisette URL", en: "Anisette Server URL"),
    
    // Verifier
    "Verify Mobileprovision": Translation(vi: "Kiểm Tra File .mobileprovision / .ipa", en: "Verify .mobileprovision / .ipa"),
    "Select File": Translation(vi: "Chọn Tập Tin", en: "Select File"),
    "Entitlements Summary": Translation(vi: "Tóm Tắt Entitlements", en: "Entitlements Summary"),
    "App Details": Translation(vi: "Chi Tiết App", en: "App Details"),
    "Team Mismatch Warning": Translation(
        vi: "Cảnh báo: Team ID trong profile không khớp với Team ID đang đăng nhập!",
        en: "Warning: Team ID in profile does not match currently logged in Team ID!"
    ),
    "Duplicate App IDs Detected": Translation(
        vi: "Phát hiện App ID bị trùng lặp bundle ID trong tài khoản.",
        en: "Duplicate App IDs detected for the same bundle identifier."
    )
]
