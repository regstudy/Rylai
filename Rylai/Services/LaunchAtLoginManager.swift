// LaunchAtLoginManager.swift
// Rylai ❄️ — Launch at Login (macOS 12.0+)

import Foundation
import ServiceManagement

class LaunchAtLoginManager: ObservableObject {

    @Published var isEnabled: Bool = false

    // macOS 13+ SMAppService
    @available(macOS 13.0, *)
    private var modernService: SMAppService {
        return SMAppService.mainApp
    }

    // Legacy API bundle identifier for helper app
    // Note: For SMLoginItemSetEnabled, we need a helper app bundle.
    // This is a simplified implementation that falls back gracefully.
    private let legacyHelperBundleID = "com.rylai.app.LoginItem"

    init() {
        refresh()
    }

    func refresh() {
        if #available(macOS 13.0, *) {
            isEnabled = modernService.status == .enabled
        } else {
            // For macOS 12, check if legacy helper is registered
            isEnabled = SMLoginItemSetEnabled(legacyHelperBundleID as CFString, false)
        }
    }

    func toggle() {
        if #available(macOS 13.0, *) {
            toggleModern()
        } else {
            toggleLegacy()
        }
    }

    @available(macOS 13.0, *)
    private func toggleModern() {
        do {
            if isEnabled {
                try modernService.unregister()
            } else {
                try modernService.register()
            }
            isEnabled.toggle()
        } catch {
            print("LaunchAtLogin (SMAppService) error: \(error.localizedDescription)")
        }
    }

    private func toggleLegacy() {
        // Toggle the legacy helper app registration
        let shouldEnable = !isEnabled
        let success = SMLoginItemSetEnabled(legacyHelperBundleID as CFString, shouldEnable)

        if success {
            isEnabled.toggle()
        } else {
            print("LaunchAtLogin (Legacy) error: Failed to set login item status")
        }
    }
}
