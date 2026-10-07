//
//  DeviceMemoryCardView.swift
//  GetMoreRam
//
//  Created on 2026-10-07.
//

import SwiftUI

struct DeviceMemoryCardView: View {
    @State private var memoryInfo = DeviceMemoryInfo.current
    @State private var showInfoSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(L("Physical RAM"), systemImage: "memorychip.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    showInfoSheet = true
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.blue)
                }
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text(memoryInfo.formattedPhysicalMemory)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(L("Available Budget"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(memoryInfo.formattedAvailableMemory)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                }
            }
            
            // Visual Progress Comparison
            VStack(spacing: 6) {
                HStack {
                    Text(L("Estimated Limit (Default)"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(memoryInfo.formattedDefaultLimit)
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
                
                ProgressView(value: memoryInfo.estimatedDefaultLimitGB, total: memoryInfo.physicalMemoryGB)
                    .tint(.orange)
                
                HStack {
                    Text(L("Estimated Limit (With IML)"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(memoryInfo.formattedIMLLimit)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                }
                
                ProgressView(value: memoryInfo.estimatedIMLLimitGB, total: memoryInfo.physicalMemoryGB)
                    .tint(.green)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal)
        .sheet(isPresented: $showInfoSheet) {
            memoryExplanationSheet
        }
        .onAppear {
            memoryInfo = DeviceMemoryInfo.current
        }
    }
    
    var memoryExplanationSheet: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(L("Memory Info"))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(L("Memory Info Description"))
                        .font(.body)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📊 Thông số thực tế")
                            .font(.headline)
                        
                        HStack {
                            Text("RAM phần cứng:")
                            Spacer()
                            Text(memoryInfo.formattedPhysicalMemory).fontWeight(.semibold)
                        }
                        HStack {
                            Text("Budget khi chạy không IML:")
                            Spacer()
                            Text(memoryInfo.formattedDefaultLimit).fontWeight(.semibold).foregroundStyle(.orange)
                        }
                        HStack {
                            Text("Budget tối đa khi có IML:")
                            Spacer()
                            Text(memoryInfo.formattedIMLLimit).fontWeight(.semibold).foregroundStyle(.green)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.tertiarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle(L("Memory Budget"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L("Done")) {
                        showInfoSheet = false
                    }
                }
            }
        }
    }
}
