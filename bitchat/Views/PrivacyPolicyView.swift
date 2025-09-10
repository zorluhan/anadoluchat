import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var text: AttributedString = AttributedString("Yükleniyor…")

    private var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }

    private var textColor: Color {
        colorScheme == .dark ? .green : Color(red: 0, green: 0.5, blue: 0)
    }

    var body: some View {
        #if os(iOS)
        NavigationView {
            content
                .navigationTitle("Gizlilik Politikası")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("kapat") { dismiss() }
                            .foregroundColor(textColor)
                    }
                }
        }
        #else
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("BİTTİ") { dismiss() }
                    .buttonStyle(.plain)
                    .foregroundColor(textColor)
                    .padding()
            }
            .background(backgroundColor.opacity(0.95))
            content
        }
        .frame(minWidth: 520, minHeight: 600)
        #endif
        .onAppear(perform: loadPolicy)
        .background(backgroundColor)
    }

    private var content: some View {
        ScrollView {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background(backgroundColor)
    }

    private func loadPolicy() {
        if let url = Bundle.main.url(forResource: "PRIVACY_POLICY", withExtension: "md"),
           let data = try? Data(contentsOf: url),
           let s = String(data: data, encoding: .utf8) {
            if let att = try? AttributedString(markdown: s) {
                text = att
                return
            }
        }
        text = AttributedString("Gizlilik politikası yüklenemedi.")
    }
}

#Preview {
    PrivacyPolicyView()
}

