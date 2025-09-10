import SwiftUI

struct ModerationSettingsView: View {
    @ObservedObject var moderation = ModerationService.shared
    @State private var newWord = ""

    var body: some View {
        #if os(iOS)
        NavigationView { content.navigationTitle("Moderasyon") }
        #else
        content.frame(minWidth: 480, minHeight: 520)
        #endif
    }

    private var content: some View {
        Form {
            Section(header: Text("Filtre Davranışı")) {
                Toggle("Gönderirken engelle", isOn: $moderation.blockOnSend)
                Toggle("Alınanı gizle", isOn: $moderation.hideOnReceive)
            }
            Section(header: Text("Engellenen kelimeler (Türkçe)")) {
                HStack {
                    TextField("kelime/ifade ekle", text: $newWord)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    Button("Ekle") {
                        moderation.addWord(newWord)
                        newWord = ""
                    }.disabled(newWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                List {
                    ForEach(Array(moderation.mutedWords.enumerated()), id: \.offset) { _, w in
                        Text(w)
                    }
                    .onDelete(perform: moderation.removeWord)
                }
                .frame(height: 260)
            }
        }
    }
}

#Preview { ModerationSettingsView() }

