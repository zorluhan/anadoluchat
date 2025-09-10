import Foundation

enum TermsAcceptance {
    // Versiyonu artırarak yeni şartların yeniden kabul edilmesini sağlayın
    static let currentVersion = "2025-09-10"
    private static let key = "terms.accepted.version"

    static var isAccepted: Bool {
        UserDefaults.standard.string(forKey: key) == currentVersion
    }

    static func accept() {
        UserDefaults.standard.set(currentVersion, forKey: key)
    }
}

