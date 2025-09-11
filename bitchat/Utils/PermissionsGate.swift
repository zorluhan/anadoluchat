import Foundation

/// Tracks and triggers first-run permission requests to minimize time to prompts.
enum PermissionsGate {
    private static let key = "permissions.requested.v1"

    static var hasRequested: Bool {
        UserDefaults.standard.bool(forKey: key)
    }

    static func markRequested() {
        UserDefaults.standard.set(true, forKey: key)
    }
}

