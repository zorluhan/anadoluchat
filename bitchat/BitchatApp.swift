//
// BitchatApp.swift
// anadoluchat
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import SwiftUI
import UserNotifications

@main
struct AnadoluchatApp: App {
    @State private var accepted = TermsAcceptance.isAccepted
    #if os(iOS)
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #elseif os(macOS)
    @NSApplicationDelegateAdaptor(MacAppDelegate.self) var appDelegate
    #endif
    
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        // Heavy initializations (VM and relay prefetch) are deferred until after terms acceptance.
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if accepted {
                    MainAppRootView { vm in
                        NotificationDelegate.shared.chatViewModel = vm
                        #if os(iOS)
                        appDelegate.chatViewModel = vm
                        #elseif os(macOS)
                        appDelegate.chatViewModel = vm
                        #endif
                    }
                } else {
                    FirstRunConsentView { accepted = true }
                }
            }
            .preferredColorScheme(.dark)
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        #endif
    }
}

// MARK: - Main app root after terms acceptance
struct MainAppRootView: View {
    @StateObject private var chatViewModel = ChatViewModel()
    var onReady: (ChatViewModel) -> Void = { _ in }
    #if os(iOS)
    @Environment(\.scenePhase) var scenePhase
    #endif

    var body: some View {
        ContentView()
            .environmentObject(chatViewModel)
            .onAppear {
                onReady(chatViewModel)
                // Warm up georelay after terms acceptance
                GeoRelayDirectory.shared.prefetchIfNeeded()
                checkForSharedContent()
            }
            .onOpenURL { url in handleURL(url) }
            #if os(iOS)
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                case .background: break
                case .active:
                    chatViewModel.meshService.startServices()
                    checkForSharedContent()
                case .inactive: break
                @unknown default: break
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                checkForSharedContent()
            }
            #endif
    }

    private func handleURL(_ url: URL) {
        if url.scheme == "bounchat" && url.host == "share" { checkForSharedContent() }
    }

    private func checkForSharedContent() {
        guard let userDefaults = UserDefaults(suiteName: "group.capish.testiPad5") else { return }
        guard let sharedContent = userDefaults.string(forKey: "sharedContent"),
              let sharedDate = userDefaults.object(forKey: "sharedContentDate") as? Date else { return }
        if Date().timeIntervalSince(sharedDate) < TransportConfig.uiShareAcceptWindowSeconds {
            let contentType = userDefaults.string(forKey: "sharedContentType") ?? "text"
            userDefaults.removeObject(forKey: "sharedContent")
            userDefaults.removeObject(forKey: "sharedContentType")
            userDefaults.removeObject(forKey: "sharedContentDate")
            DispatchQueue.main.async {
                if contentType == "url" {
                    if let data = sharedContent.data(using: .utf8),
                       let urlData = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                       let url = urlData["url"] {
                        self.chatViewModel.sendMessage(url)
                    } else {
                        self.chatViewModel.sendMessage(sharedContent)
                    }
                } else {
                    self.chatViewModel.sendMessage(sharedContent)
                }
            }
        }
    }
}

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
    weak var chatViewModel: ChatViewModel?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}
#endif

#if os(macOS)
import AppKit

class MacAppDelegate: NSObject, NSApplicationDelegate {
    weak var chatViewModel: ChatViewModel?
    
    func applicationWillTerminate(_ notification: Notification) {
        chatViewModel?.applicationWillTerminate()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
#endif

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    weak var chatViewModel: ChatViewModel?
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        let userInfo = response.notification.request.content.userInfo
        
        // Check if this is a private message notification
        if identifier.hasPrefix("private-") {
            // Get peer ID from userInfo
            if let peerID = userInfo["peerID"] as? String {
                DispatchQueue.main.async {
                    self.chatViewModel?.startPrivateChat(with: peerID)
                }
            }
        }
        // Handle deeplink (e.g., geohash activity)
        if let deep = userInfo["deeplink"] as? String, let url = URL(string: deep) {
            #if os(iOS)
            DispatchQueue.main.async { UIApplication.shared.open(url) }
            #else
            DispatchQueue.main.async { NSWorkspace.shared.open(url) }
            #endif
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let identifier = notification.request.identifier
        let userInfo = notification.request.content.userInfo
        
        // Check if this is a private message notification
        if identifier.hasPrefix("private-") {
            // Get peer ID from userInfo
            if let peerID = userInfo["peerID"] as? String {
                // Don't show notification if the private chat is already open
                if chatViewModel?.selectedPrivateChatPeer == peerID {
                    completionHandler([])
                    return
                }
            }
        }
        // Suppress geohash activity notification if we're already in that geohash channel
        if identifier.hasPrefix("geo-activity-"),
           let deep = userInfo["deeplink"] as? String,
           let gh = deep.components(separatedBy: "/").last {
            if case .location(let ch) = LocationChannelManager.shared.selectedChannel, ch.geohash == gh {
                completionHandler([])
                return
            }
        }
        
        // Show notification in all other cases
        completionHandler([.banner, .sound])
    }
}

extension String {
    var nilIfEmpty: String? {
        self.isEmpty ? nil : self
    }
}
