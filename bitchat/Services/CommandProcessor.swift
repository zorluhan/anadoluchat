//
// CommandProcessor.swift
// bitchat
//
// Handles command parsing and execution for BitChat
// This is free and unencumbered software released into the public domain.
//

import Foundation

/// Result of command processing
enum CommandResult {
    case success(message: String?)
    case error(message: String)
    case handled  // Command handled, no message needed
}

/// Processes chat commands in a focused, efficient way
@MainActor
class CommandProcessor {
    weak var chatViewModel: ChatViewModel?
    weak var meshService: Transport?
    
    // Student club directory: abbreviation -> (human name, email?)
    // Abbreviations are matched case-insensitively; diacritics and punctuation are ignored.
    private let clubDirectory: [String: (name: String, email: String?)] = [
        // Core examples
        "sk": ("Spor Kurulu", "sporkurulu@bogazici.edu.tr"),
        // Full list (normalized ASCII lowercase keys)
        "adk": ("Atatürkçü Düşünce Kulübü", "adk@bogazici.edu.tr"),
        "bubk": ("Bilim Kulübü", "bilimkulubu@bogazici.edu.tr"),
        "compec": ("Bilişim Kulübü (Compec)", "compec@bogazici.edu.tr"),
        "bric": ("Briç Kulübü", "bric@bogazici.edu.tr"),
        "bucev": ("Çeviri Kulübü", "bucev@bogazici.edu.tr"),
        "bucek": ("Çevre Kulübü", "bucek@bogazici.edu.tr"),
        "budak": ("Dağcılık Kulübü", "budak@bogazici.edu.tr"),
        "budans": ("Dans Kulübü", "budans@bogazici.edu.tr"),
        "budav": ("Davranış Bilimleri Kulübü (Aday)", "budav@bogazici.edu.tr"),
        "buyelken": ("Denizcilik ve Yelkencilik Kulübü (Aday)", "buyelken@bogazici.edu.tr"),
        "bued": ("Edebiyat Kulübü", "bued@bogazici.edu.tr"),
        "erec": ("Eğitim Araştırma Kulübü", "erec@bogazici.edu.tr"),
        "buec": ("Elektro Teknoloji Kulübü", "buec@bogazici.edu.tr"),
        "bufk": ("Folklor Kulübü", "bufk@bogazici.edu.tr"),
        "bufok": ("Fotoğrafçılık Kulübü", "bufok@bogazici.edu.tr"),
        "bugusto": ("Gastronomi ve Degüstasyon Kulübü", "bugusto@bogazici.edu.tr"),
        "buok": ("Gerçek Macera Oyunları Kulübü", "buok@bogazici.edu.tr"),
        "gsk": ("Güzel Sanatlar Kulübü", "gsk@bogazici.edu.tr"),
        "buhak": ("Havacılık Kulübü", "buhak@bogazici.edu.tr"),
        "bisak": ("İslam Araştırmaları Kulübü (Aday)", "bisak@bogazici.edu.tr"),
        "buik": ("İşletme ve Ekonomi Kulübü", nil),
        "bukak": ("Kadın Araştırma Kulübü", "bukak@bogazici.edu.tr"),
        "bukomik": ("Karikatür ve Mizah Kulübü", "bukomik@bogazici.edu.tr"),
        "koykoop": ("Köy‑Koop Kulübü", "koykoop@bogazici.edu.tr"),
        "bumak": ("Mağara Araştırma Kulübü", "bumak@bogazici.edu.tr"),
        "bumatek": ("Makine Teknoloji Kulübü", "bumatek@bogazici.edu.tr"),
        "enso": ("Mühendislik Kulübü", "enso@bogazici.edu.tr"),
        "buds": ("Münazara Kulübü", "buds@bogazici.edu.tr"),
        "bumk": ("Müzik Kulübü", "bumk@bogazici.edu.tr"),
        "radyo": ("Radyo Boğaziçi", "radyobogazici@bogazici.edu.tr"),
        "satranc": ("Satranç Kulübü", "satranc@bogazici.edu.tr"),
        "busk": ("Sinema Kulübü", "sinema@bogazici.edu.tr"),
        "busuik": ("Siyasal Bilimler ve Uluslararası İlişkiler Kulübü", "busuik@bogazici.edu.tr"),
        "sbk": ("Sosyal Bilimler Kulübü", "sbk@bogazici.edu.tr"),
        "busos": ("Sosyal Hizmet Kulübü", "busos@bogazici.edu.tr"),
        "busas": ("Sualtı Sporları Kulübü", "busas@bogazici.edu.tr"),
        "butik": ("Tarih İncelemeleri Kulübü", "butik@bogazici.edu.tr"),
        "buo": ("Tiyatro Kulübü", "buo@bogazici.edu.tr"),
        "butak": ("Türk Araştırmaları Kulübü", "butak.2015@bogazici.edu.tr"),
        "bunis": ("Uluslararası Öğrenci Ağı Kulübü", "bunis@bogazici.edu.tr"),
        "buyap": ("Yapı Kulübü", "buyap@bogazici.edu.tr"),
        "buyak": ("Yöneylem Araştırma Kulübü", "buyak@bogazici.edu.tr")
    ]

    // Expose club commands for UI helpers
    func availableClubCommands() -> [(String, String)] {
        clubDirectory
            .map { ("/\($0.key)", $0.value.name) }
            .sorted { $0.0 < $1.0 }
    }
    
    init(chatViewModel: ChatViewModel? = nil, meshService: Transport? = nil) {
        self.chatViewModel = chatViewModel
        self.meshService = meshService
    }
    
    /// Process a command string
    @MainActor
    func process(_ command: String) -> CommandResult {
        let parts = command.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
        guard let cmd = parts.first else { return .error(message: "Invalid command") }
        let args = parts.count > 1 ? String(parts[1]) : ""
        let token = String(cmd).lowercased()
        
        // Geohash context: disable favoriting in public geohash or GeoDM
        let inGeoPublic: Bool = {
            switch LocationChannelManager.shared.selectedChannel {
            case .mesh: return false
            case .location: return true
            }
        }()
        let inGeoDM = (chatViewModel?.selectedPrivateChatPeer?.hasPrefix("nostr_") == true)

        // Club shortcuts: "/sk", "/adk", etc.
        if let abbr = clubAbbreviation(from: token) {
            return handleClubSwitch(abbr)
        }

        switch token {
        case "/feedback":
            return handleFeedback()
        case "/mesh", "/home", "/main":
            return handleGoMesh()
        case "/m", "/msg":
            return handleMessage(args)
        case "/w", "/who":
            return handleWho()
        case "/clear":
            return handleClear()
        case "/contact":
            return handleContact()
        case "/hug":
            return handleEmote(args, action: "hugs", emoji: "🫂")
        case "/slap":
            return handleEmote(args, action: "slaps", emoji: "🐟", suffix: " around a bit with a large trout")
        case "/block":
            return handleBlock(args)
        case "/unblock":
            return handleUnblock(args)
        case "/fav":
            if inGeoPublic || inGeoDM { return .error(message: "favorites are only for mesh peers in #mesh") }
            return handleFavorite(args, add: true)
        case "/unfav":
            if inGeoPublic || inGeoDM { return .error(message: "favorites are only for mesh peers in #mesh") }
            return handleFavorite(args, add: false)
        //
        case "/help", "/h":
            return .error(message: "unknown command: \(cmd)")
        default:
            return .error(message: "unknown command: \(cmd)")
        }
    }
    
    // MARK: - Command Handlers
    
    private func normalize(_ s: String) -> String {
        let folded = s.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        let filtered = folded.unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) }
        return String(String.UnicodeScalarView(filtered)).lowercased()
    }

    private func clubAbbreviation(from token: String) -> String? {
        guard token.hasPrefix("/") else { return nil }
        let bare = String(token.dropFirst())
        let key = normalize(bare)
        return clubDirectory[key] != nil ? key : nil
    }

    private func handleClubSwitch(_ abbr: String) -> CommandResult {
        // Choose a reasonable level based on pseudo-"geohash" length
        func level(for len: Int) -> GeohashChannelLevel {
            switch len {
            case 0...2: return .region
            case 3...4: return .province
            case 5: return .city
            case 6: return .neighborhood
            default: return .block
            }
        }
        let ch = GeohashChannel(level: level(for: abbr.count), geohash: abbr)
        // Mark as teleported if not in regional suggestions
        let inRegional = LocationChannelManager.shared.availableChannels.contains { $0.geohash == abbr }
        if !inRegional && !LocationChannelManager.shared.availableChannels.isEmpty {
            LocationChannelManager.shared.markTeleported(for: abbr, true)
        }
        LocationChannelManager.shared.select(.location(ch))
        if let info = clubDirectory[abbr] {
            let suffix = info.email != nil ? " — /contact" : ""
            return .success(message: "kanal: #\(abbr) (\(info.name))\(suffix)")
        } else {
            return .success(message: "kanal: #\(abbr)")
        }
    }

    private func handleContact() -> CommandResult {
        switch LocationChannelManager.shared.selectedChannel {
        case .mesh:
            return .error(message: "not in a club channel — use /<kısaltma> first")
        case .location(let ch):
            let key = normalize(ch.geohash)
            if let info = clubDirectory[key] {
                if let email = info.email {
                    return .success(message: "iletisim: \(email)")
                } else {
                    return .success(message: "iletişim e‑postası bulunamadı")
                }
            } else {
                return .error(message: "not a recognized club channel")
            }
        }
    }

    private func handleGoMesh() -> CommandResult {
        LocationChannelManager.shared.select(.mesh)
        return .success(message: "kanal: #mesh")
    }

    private func handleFeedback() -> CommandResult {
        let key = "feedback"
        func level(for len: Int) -> GeohashChannelLevel {
            switch len {
            case 0...2: return .region
            case 3...4: return .province
            case 5: return .city
            case 6: return .neighborhood
            default: return .block
            }
        }
        let ch = GeohashChannel(level: level(for: key.count), geohash: key)
        let inRegional = LocationChannelManager.shared.availableChannels.contains { $0.geohash == key }
        if !inRegional && !LocationChannelManager.shared.availableChannels.isEmpty {
            LocationChannelManager.shared.markTeleported(for: key, true)
        }
        LocationChannelManager.shared.select(.location(ch))
        return .success(message: "kanal: #feedback")
    }
    
    private func handleMessage(_ args: String) -> CommandResult {
        let parts = args.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
        guard !parts.isEmpty else {
            return .error(message: "usage: /msg @nickname [message]")
        }
        
        let targetName = String(parts[0])
        let nickname = targetName.hasPrefix("@") ? String(targetName.dropFirst()) : targetName
        
        guard let peerID = chatViewModel?.getPeerIDForNickname(nickname) else {
            return .error(message: "'\(nickname)' not found")
        }
        
        chatViewModel?.startPrivateChat(with: peerID)
        
        if parts.count > 1 {
            let message = String(parts[1])
            chatViewModel?.sendPrivateMessage(message, to: peerID)
        }
        
        return .success(message: "started private chat with \(nickname)")
    }
    
    private func handleWho() -> CommandResult {
        // Show geohash participants when in a geohash channel; otherwise mesh peers
        switch LocationChannelManager.shared.selectedChannel {
        case .location(let ch):
            // Geohash context: show visible geohash participants (exclude self)
            guard let vm = chatViewModel else { return .success(message: "nobody around") }
            let myHex = (try? NostrIdentityBridge.deriveIdentity(forGeohash: ch.geohash))?.publicKeyHex.lowercased()
            let people = vm.visibleGeohashPeople().filter { person in
                if let me = myHex { return person.id.lowercased() != me }
                return true
            }
            let names = people.map { $0.displayName }
            if names.isEmpty { return .success(message: "no one else is online right now") }
            return .success(message: "online: " + names.sorted().joined(separator: ", "))
        case .mesh:
            // Mesh context: show connected peer nicknames
            guard let peers = meshService?.getPeerNicknames(), !peers.isEmpty else {
                return .success(message: "no one else is online right now")
            }
            let onlineList = peers.values.sorted().joined(separator: ", ")
            return .success(message: "online: \(onlineList)")
        }
    }
    
    private func handleClear() -> CommandResult {
        if let peerID = chatViewModel?.selectedPrivateChatPeer {
            chatViewModel?.privateChats[peerID]?.removeAll()
        } else {
            chatViewModel?.clearCurrentPublicTimeline()
        }
        return .handled
    }
    
    private func handleEmote(_ args: String, action: String, emoji: String, suffix: String = "") -> CommandResult {
        let targetName = args.trimmingCharacters(in: .whitespaces)
        guard !targetName.isEmpty else {
            return .error(message: "usage: /\(action) <nickname>")
        }
        
        let nickname = targetName.hasPrefix("@") ? String(targetName.dropFirst()) : targetName
        
        guard let targetPeerID = chatViewModel?.getPeerIDForNickname(nickname),
              let myNickname = chatViewModel?.nickname else {
            return .error(message: "cannot \(action) \(nickname): not found")
        }
        
        let emoteContent = "* \(emoji) \(myNickname) \(action) \(nickname)\(suffix) *"
        
        if chatViewModel?.selectedPrivateChatPeer != nil {
            // In private chat
            if let peerNickname = meshService?.peerNickname(peerID: targetPeerID) {
                let personalMessage = "* \(emoji) \(myNickname) \(action) you\(suffix) *"
                meshService?.sendPrivateMessage(personalMessage, to: targetPeerID, 
                                               recipientNickname: peerNickname, 
                                               messageID: UUID().uuidString)
                // Also add a local system message so the sender sees a natural-language confirmation
                let pastAction: String = {
                    switch action {
                    case "hugs": return "hugged"
                    case "slaps": return "slapped"
                    default: return action.hasSuffix("e") ? action + "d" : action + "ed"
                    }
                }()
                let localText = "\(emoji) you \(pastAction) \(nickname)\(suffix)"
                chatViewModel?.addLocalPrivateSystemMessage(localText, to: targetPeerID)
            }
        } else {
            // In public chat: send to active public channel (mesh or geohash)
            chatViewModel?.sendPublicRaw(emoteContent)
            let publicEcho = "\(emoji) \(myNickname) \(action) \(nickname)\(suffix)"
            chatViewModel?.addPublicSystemMessage(publicEcho)
        }
        
        return .handled
    }
    
    private func handleBlock(_ args: String) -> CommandResult {
        let targetName = args.trimmingCharacters(in: .whitespaces)
        
        if targetName.isEmpty {
            // List blocked users (mesh) and geohash (Nostr) blocks
            let meshBlocked = chatViewModel?.blockedUsers ?? []
            var blockedNicknames: [String] = []
            if let peers = meshService?.getPeerNicknames() {
                for (peerID, nickname) in peers {
                    if let fingerprint = meshService?.getFingerprint(for: peerID),
                       meshBlocked.contains(fingerprint) {
                        blockedNicknames.append(nickname)
                    }
                }
            }

            // Geohash blocked names (prefer visible display names; fallback to #suffix)
            let geoBlocked = Array(SecureIdentityStateManager.shared.getBlockedNostrPubkeys())
            var geoNames: [String] = []
            if let vm = chatViewModel {
                let visible = vm.visibleGeohashPeople()
                let visibleIndex = Dictionary(uniqueKeysWithValues: visible.map { ($0.id.lowercased(), $0.displayName) })
                for pk in geoBlocked {
                    if let name = visibleIndex[pk.lowercased()] {
                        geoNames.append(name)
                    } else {
                        let suffix = String(pk.suffix(4))
                        geoNames.append("anon#\(suffix)")
                    }
                }
            }

            let meshList = blockedNicknames.isEmpty ? "none" : blockedNicknames.sorted().joined(separator: ", ")
            let geoList = geoNames.isEmpty ? "none" : geoNames.sorted().joined(separator: ", ")
            return .success(message: "blocked peers: \(meshList) | geohash blocks: \(geoList)")
        }
        
        let nickname = targetName.hasPrefix("@") ? String(targetName.dropFirst()) : targetName
        
        if let peerID = chatViewModel?.getPeerIDForNickname(nickname),
           let fingerprint = meshService?.getFingerprint(for: peerID) {
            if SecureIdentityStateManager.shared.isBlocked(fingerprint: fingerprint) {
                return .success(message: "\(nickname) is already blocked")
            }
            // Block the user (mesh/noise identity)
            if var identity = SecureIdentityStateManager.shared.getSocialIdentity(for: fingerprint) {
                identity.isBlocked = true
                identity.isFavorite = false
                SecureIdentityStateManager.shared.updateSocialIdentity(identity)
            } else {
                let blockedIdentity = SocialIdentity(
                    fingerprint: fingerprint,
                    localPetname: nil,
                    claimedNickname: nickname,
                    trustLevel: .unknown,
                    isFavorite: false,
                    isBlocked: true,
                    notes: nil
                )
                SecureIdentityStateManager.shared.updateSocialIdentity(blockedIdentity)
            }
            return .success(message: "blocked \(nickname). you will no longer receive messages from them")
        }
        // Mesh lookup failed; try geohash (Nostr) participant by display name
        if let pub = chatViewModel?.nostrPubkeyForDisplayName(nickname) {
            if SecureIdentityStateManager.shared.isNostrBlocked(pubkeyHexLowercased: pub) {
                return .success(message: "\(nickname) is already blocked")
            }
            SecureIdentityStateManager.shared.setNostrBlocked(pub, isBlocked: true)
            return .success(message: "blocked \(nickname) in geohash chats")
        }
        
        return .error(message: "cannot block \(nickname): not found or unable to verify identity")
    }
    
    private func handleUnblock(_ args: String) -> CommandResult {
        let targetName = args.trimmingCharacters(in: .whitespaces)
        guard !targetName.isEmpty else {
            return .error(message: "usage: /unblock <nickname>")
        }
        
        let nickname = targetName.hasPrefix("@") ? String(targetName.dropFirst()) : targetName
        
        if let peerID = chatViewModel?.getPeerIDForNickname(nickname),
           let fingerprint = meshService?.getFingerprint(for: peerID) {
            if !SecureIdentityStateManager.shared.isBlocked(fingerprint: fingerprint) {
                return .success(message: "\(nickname) is not blocked")
            }
            SecureIdentityStateManager.shared.setBlocked(fingerprint, isBlocked: false)
            return .success(message: "unblocked \(nickname)")
        }
        // Try geohash unblock
        if let pub = chatViewModel?.nostrPubkeyForDisplayName(nickname) {
            if !SecureIdentityStateManager.shared.isNostrBlocked(pubkeyHexLowercased: pub) {
                return .success(message: "\(nickname) is not blocked")
            }
            SecureIdentityStateManager.shared.setNostrBlocked(pub, isBlocked: false)
            return .success(message: "unblocked \(nickname) in geohash chats")
        }
        return .error(message: "cannot unblock \(nickname): not found")
    }
    
    private func handleFavorite(_ args: String, add: Bool) -> CommandResult {
        let targetName = args.trimmingCharacters(in: .whitespaces)
        guard !targetName.isEmpty else {
            return .error(message: "usage: /\(add ? "fav" : "unfav") <nickname>")
        }
        
        let nickname = targetName.hasPrefix("@") ? String(targetName.dropFirst()) : targetName
        
        guard let peerID = chatViewModel?.getPeerIDForNickname(nickname),
              let noisePublicKey = Data(hexString: peerID) else {
            return .error(message: "can't find peer: \(nickname)")
        }
        
        if add {
            let existingFavorite = FavoritesPersistenceService.shared.getFavoriteStatus(for: noisePublicKey)
            FavoritesPersistenceService.shared.addFavorite(
                peerNoisePublicKey: noisePublicKey,
                peerNostrPublicKey: existingFavorite?.peerNostrPublicKey,
                peerNickname: nickname
            )
            
            chatViewModel?.toggleFavorite(peerID: peerID)
            chatViewModel?.sendFavoriteNotification(to: peerID, isFavorite: true)
            
            return .success(message: "added \(nickname) to favorites")
        } else {
            FavoritesPersistenceService.shared.removeFavorite(peerNoisePublicKey: noisePublicKey)
            
            chatViewModel?.toggleFavorite(peerID: peerID)
            chatViewModel?.sendFavoriteNotification(to: peerID, isFavorite: false)
            
            return .success(message: "removed \(nickname) from favorites")
        }
    }
    
    private func handleHelp() -> CommandResult {
        let helpText = """
        commands:
        /msg @name - start private chat
        /who - list who's online
        /clear - clear messages
        /hug @name - send a hug
        /slap @name - slap with a trout
        /fav @name - add to favorites
        /unfav @name - remove from favorites
        /block @name - block
        /unblock @name - unblock
        """
        return .success(message: helpText)
    }
}
