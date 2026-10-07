//
//  MobileProvisionParser.swift
//  GetMoreRam
//
//  Created on 2026-10-07.
//

import Foundation

struct ParsedProvisioningProfile {
    let name: String
    let teamName: String?
    let teamIdentifier: String?
    let appIdentifier: String?
    let creationDate: Date?
    let expirationDate: Date?
    let isExpired: Bool
    let hasIML: Bool
    let hasEVA: Bool
    let rawEntitlements: [String: Any]
    
    var formattedExpiration: String {
        guard let exp = expirationDate else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: exp)
    }
}

enum MobileProvisionParser {
    static func parse(data: Data) throws -> ParsedProvisioningProfile {
        // Search for <plist and </plist> tags within binary CMS data
        guard let startRange = data.range(of: Data("<plist".utf8)),
              let endRange = data.range(of: Data("</plist>".utf8)) else {
            throw "Invalid provisioning profile format: XML plist not found."
        }
        
        let plistData = data.subdata(in: startRange.lowerBound..<endRange.upperBound)
        
        guard let plist = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any] else {
            throw "Unable to deserialize provisioning profile property list."
        }
        
        let name = plist["Name"] as? String ?? "Unnamed Profile"
        let teamName = plist["TeamName"] as? String
        let teamIDs = plist["TeamIdentifier"] as? [String]
        let teamIdentifier = teamIDs?.first
        let creationDate = plist["CreationDate"] as? Date
        let expirationDate = plist["ExpirationDate"] as? Date
        
        let isExpired: Bool
        if let exp = expirationDate {
            isExpired = (exp < Date())
        } else {
            isExpired = false
        }
        
        let entitlements = plist["Entitlements"] as? [String: Any] ?? [:]
        
        let appIdentifier = entitlements["application-identifier"] as? String
        
        let hasIML = (entitlements["com.apple.developer.kernel.increased-memory-limit"] as? Bool) ?? false
        let hasEVA = (entitlements["com.apple.developer.kernel.extended-virtual-addressing"] as? Bool) ?? false
        
        return ParsedProvisioningProfile(
            name: name,
            teamName: teamName,
            teamIdentifier: teamIdentifier,
            appIdentifier: appIdentifier,
            creationDate: creationDate,
            expirationDate: expirationDate,
            isExpired: isExpired,
            hasIML: hasIML,
            hasEVA: hasEVA,
            rawEntitlements: entitlements
        )
    }
    
    static func parse(url: Data) throws -> ParsedProvisioningProfile {
        return try parse(data: url)
    }
}
