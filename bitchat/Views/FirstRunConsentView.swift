import SwiftUI

struct FirstRunConsentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showPrivacy = false
    @State private var showTerms = false
    @State private var agreed = false
    let onAccepted: () -> Void

    private var backgroundColor: Color { colorScheme == .dark ? .black : .white }
    private var textColor: Color { colorScheme == .dark ? .green : Color(red: 0, green: 0.5, blue: 0) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Kullanım Şartları ve Gizlilik")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(textColor)

            Text("Bu uygulama kullanıcı tarafından üretilen içerik barındırır. \nAşağıdaki kuralları kabul etmeden devam edemezsiniz:")
                .font(.system(size: 14, design: .monospaced))

            VStack(alignment: .leading, spacing: 8) {
                bullet("Nefret söylemi, taciz, yasa dışı içerik ve şiddete \nsıfır tolerans.")
                bullet("Uygunsuz içerikleri ‘Rapor Et’ ile bildirin; 24 saat içinde işlem taahhüdü.")
                bullet("İstenmeyen kullanıcıları ‘Engelle’ ile durdurabilirsiniz.")
                bullet("Sunucu yok, takip yok; detaylar için Gizlilik Politikası.")
            }

            HStack(spacing: 12) {
                Button { showPrivacy = true } label: {
                    Label("Gizlilik Politikası", systemImage: "doc.text")
                }.buttonStyle(.bordered)

                Button { showTerms = true } label: {
                    Label("Kullanım Şartları", systemImage: "scroll")
                }.buttonStyle(.bordered)
            }

            Toggle(isOn: $agreed) {
                Text("Şartları okudum ve kabul ediyorum")
            }
            .toggleStyle(.switch)

            Button {
                TermsAcceptance.accept()
                onAccepted()
            } label: {
                Text("Kabul ediyorum")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!agreed)
            .padding(.top, 8)

            Spacer()
        }
        .padding(20)
        .background(backgroundColor)
        .sheet(isPresented: $showPrivacy) { PrivacyPolicyView() }
        .sheet(isPresented: $showTerms) { TermsView() }
    }

    @ViewBuilder
    private func bullet(_ s: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(s)
        }
        .font(.system(size: 13, design: .monospaced))
    }
}

#Preview {
    FirstRunConsentView(onAccepted: {})
}

