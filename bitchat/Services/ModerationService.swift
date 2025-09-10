import Foundation

final class ModerationService: ObservableObject {
    static let shared = ModerationService()

    private let wordsKey = "moderation.muted.words"
    private let sendKey = "moderation.blockOnSend"
    private let recvKey = "moderation.hideOnReceive"
    private let hiddenKey = "moderation.hidden.messageIDs"

    @Published var blockOnSend: Bool {
        didSet { UserDefaults.standard.set(blockOnSend, forKey: sendKey) }
    }
    @Published var hideOnReceive: Bool {
        didSet { UserDefaults.standard.set(hideOnReceive, forKey: recvKey) }
    }
    @Published var mutedWords: [String] {
        didSet { UserDefaults.standard.set(mutedWords, forKey: wordsKey) }
    }
    @Published var hiddenMessageIDs: Set<String> {
        didSet { UserDefaults.standard.set(Array(hiddenMessageIDs), forKey: hiddenKey) }
    }

    private init() {
        self.blockOnSend = UserDefaults.standard.object(forKey: sendKey) as? Bool ?? true
        self.hideOnReceive = UserDefaults.standard.object(forKey: recvKey) as? Bool ?? true
        if let saved = UserDefaults.standard.stringArray(forKey: wordsKey) {
            self.mutedWords = saved
        } else {
            // Sadece Türkçe örnek liste (genişletilebilir)
            self.mutedWords = [
                // kaba/küfür örnekleri (bilinçli olarak sansürlü yazım)
                "k*für", "salak", "aptal", "şerefs*z", "oros*pu", "hays*yetsiz",
                // nefret ve taciz
                "nefret", "ırkçı", "taciz", "tehdit",
                // yasa dışı içerik kelimeleri (genel)
                "uyuşturucu sat", "silah sat", "çocuk istismar"
            ]
        }
        if let arr = UserDefaults.standard.stringArray(forKey: hiddenKey) {
            self.hiddenMessageIDs = Set(arr)
        } else {
            self.hiddenMessageIDs = []
        }
    }

    func addWord(_ word: String) {
        let norm = normalize(word)
        guard !norm.isEmpty, !mutedWords.map(normalize).contains(norm) else { return }
        mutedWords.append(word)
    }

    func removeWord(at offsets: IndexSet) { mutedWords.remove(atOffsets: offsets) }

    func shouldMute(_ content: String) -> Bool {
        let text = normalize(content)
        for w in mutedWords {
            let needle = normalize(w)
            if !needle.isEmpty, text.contains(needle) { return true }
        }
        return false
    }

    private func normalize(_ s: String) -> String {
        let folded = s.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        return folded.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Manual hide helpers
    func hideMessage(id: String) { hiddenMessageIDs.insert(id) }
    func isHidden(id: String) -> Bool { hiddenMessageIDs.contains(id) }
}
