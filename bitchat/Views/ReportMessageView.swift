import SwiftUI

struct ReportMessageView: View {
    enum Reason: String, CaseIterable, Identifiable { case spam = "Spam", taciz = "Taciz/Saldırı", nefret = "Nefret", cinsel = "Cinsel", yasadisi = "Yasa dışı", diger = "Diğer"; var id: String { rawValue } }

    let message: BitchatMessage
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.dismiss) var dismiss
    @State private var reason: Reason = .spam
    @State private var note: String = ""
    @State private var blockSender = true
    @State private var addToFilter = true
    @State private var hideMessage = true
    @State private var includeRegionOnly = false

    var body: some View {
        #if os(iOS)
        NavigationView { content.navigationTitle("Uygunsuz içeriği bildir").navigationBarTitleDisplayMode(.inline) }
        #else
        content.frame(minWidth: 520, minHeight: 500)
        #endif
    }

    private var content: some View {
        Form {
            Section(header: Text("Mesaj")) {
                Text(message.content).font(.system(.body, design: .monospaced))
            }
            Section(header: Text("Neden")) {
                Picker("Neden", selection: $reason) {
                    ForEach(Reason.allCases) { r in Text(r.rawValue).tag(r) }
                }.pickerStyle(.segmented)
            }
            Section(header: Text("Açıklama (isteğe bağlı)")) {
                TextEditor(text: $note).frame(minHeight: 100)
            }
            Section(header: Text("Hızlı önlemler (sizde)")) {
                Toggle("Göndereni engelle", isOn: $blockSender)
                Toggle("Bu ifadeyi filtremde engelle", isOn: $addToFilter)
                Toggle("İlgili mesajı gizle", isOn: $hideMessage)
            }
            Section(header: Text("Gizlilik")) {
                Toggle("Konum kanalı bilgisini bölge seviyesinde ekle (2 harf)", isOn: $includeRegionOnly)
            }
            Section { HStack { Spacer(); Button("Gönder") { submit() }.buttonStyle(.borderedProminent); Button("İptal") { dismiss() }.buttonStyle(.bordered); Spacer() } }
        }
    }

    private func submit() {
        // Apply local actions first
        if hideMessage { ModerationService.shared.hideMessage(id: message.id) }
        if addToFilter { ModerationService.shared.addWord(safePhrase(from: message.content)) }
        if blockSender { blockCurrentSender() }
        // Compose report email
        let body = buildBody()
        sendEmail(subject: "Uygunsuz içerik bildirimi", body: body)
        dismiss()
    }

    private func blockCurrentSender() {
        if let pid = message.senderPeerID, pid.hasPrefix("nostr:"), let full = viewModel.fullNostrHex(forSenderPeerID: pid) {
            viewModel.blockGeohashUser(pubkeyHexLowercased: full, displayName: message.sender)
        } else {
            viewModel.sendMessage("/block \(message.sender)")
        }
    }

    private func safePhrase(from text: String) -> String {
        // Sadeleştirilmiş: ilk 20 karakteri al, satır sonlarını temizle
        let trimmed = text.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespaces)
        return String(trimmed.prefix(20))
    }

    private func buildBody() -> String {
        var lines: [String] = []
        lines.append("raporId: \(UUID().uuidString)")
        lines.append("tarih: \(ISO8601DateFormatter().string(from: Date()))")
        lines.append("neden: \(reason.rawValue)")
        if !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { lines.append("not: \(note)") }
        let channelDesc: String = {
            switch viewModel.activeChannel {
            case .mesh: return "mesh"
            case .location(let ch):
                if includeRegionOnly { return "geo:#\(String(ch.geohash.prefix(2)))" }
                else { return "geo:#\(ch.geohash)" }
            }
        }()
        lines.append("kanal: \(channelDesc)")
        let senderSuffix = String((message.senderPeerID ?? "?").suffix(4))
        lines.append("gönderen: @\(message.sender) (id: …\(senderSuffix))")
        lines.append("mesaj: \(message.content)")
        lines.append("yerelEylemler: engelle=\(blockSender), filtreEkle=\(addToFilter), gizle=\(hideMessage)")
        return lines.joined(separator: "\n")
    }

    private func sendEmail(subject: String, body: String) {
        let to = "zorluhan@capish.co"
        let allowed = CharacterSet.urlQueryAllowed
        let subj = subject.addingPercentEncoding(withAllowedCharacters: allowed) ?? subject
        let bdy = body.addingPercentEncoding(withAllowedCharacters: allowed) ?? body
        if let url = URL(string: "mailto:\(to)?subject=\(subj)&body=\(bdy)") {
            #if os(iOS)
            UIApplication.shared.open(url)
            #else
            NSWorkspace.shared.open(url)
            #endif
        }
    }
}

