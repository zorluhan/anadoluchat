import SwiftUI

struct ReportUserView: View {
    enum Reason: String, CaseIterable, Identifiable { case spam = "Spam", taciz = "Taciz/Saldırı", nefret = "Nefret", cinsel = "Cinsel", yasadisi = "Yasa dışı", diger = "Diğer"; var id: String { rawValue } }

    let userId: String
    let displayName: String
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.dismiss) var dismiss
    @State private var reason: Reason = .spam
    @State private var note: String = ""
    @State private var blockUser = true
    @State private var addToFilter = false
    @State private var includeRegionOnly = false

    var body: some View {
        #if os(iOS)
        NavigationView { content.navigationTitle("Kullanıcıyı bildir").navigationBarTitleDisplayMode(.inline) }
        #else
        content.frame(minWidth: 520, minHeight: 460)
        #endif
    }

    private var content: some View {
        Form {
            Section(header: Text("Kullanıcı")) {
                Text("@\(displayName)")
            }
            Section(header: Text("Neden")) {
                Picker("Neden", selection: $reason) { ForEach(Reason.allCases) { r in Text(r.rawValue).tag(r) } }
                .pickerStyle(.segmented)
            }
            Section(header: Text("Açıklama (isteğe bağlı)")) {
                TextEditor(text: $note).frame(minHeight: 100)
            }
            Section(header: Text("Yerel önlemler")) {
                Toggle("Kullanıcıyı engelle", isOn: $blockUser)
                Toggle("Bu ifadeyi filtremde engelle (takma ad)", isOn: $addToFilter)
            }
            Section(header: Text("Gizlilik")) {
                Toggle("Konum kanalı bilgisini bölge seviyesinde ekle (2 harf)", isOn: $includeRegionOnly)
            }
            Section { HStack { Spacer(); Button("Gönder") { submit() }.buttonStyle(.borderedProminent); Button("İptal") { dismiss() }.buttonStyle(.bordered); Spacer() } }
        }
    }

    private func submit() {
        if blockUser { block() }
        if addToFilter { ModerationService.shared.addWord(displayName) }
        let body = buildBody()
        sendEmail(subject: "Kullanıcı bildirimi", body: body)
        dismiss()
    }

    private func block() {
        if userId.hasPrefix("nostr:") {
            if let full = viewModel.fullNostrHex(forSenderPeerID: userId) {
                viewModel.blockGeohashUser(pubkeyHexLowercased: full, displayName: displayName)
            }
        } else {
            viewModel.sendMessage("/block \(displayName)")
        }
    }

    private func buildBody() -> String {
        var lines: [String] = []
        lines.append("raporId: \(UUID().uuidString)")
        lines.append("tarih: \(ISO8601DateFormatter().string(from: Date()))")
        lines.append("neden: \(reason.rawValue)")
        if !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { lines.append("not: \(note)") }
        let channelDesc: String = {
            switch LocationChannelManager.shared.selectedChannel {
            case .mesh: return "mesh"
            case .location(let ch):
                if includeRegionOnly { return "geo:#\(String(ch.geohash.prefix(2)))" }
                else { return "geo:#\(ch.geohash)" }
            }
        }()
        lines.append("kanal: \(channelDesc)")
        let senderSuffix = String(userId.suffix(4))
        lines.append("kullanıcı: @\(displayName) (id: …\(senderSuffix))")
        lines.append("yerelEylemler: engelle=\(blockUser), filtreEkle=\(addToFilter)")
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
