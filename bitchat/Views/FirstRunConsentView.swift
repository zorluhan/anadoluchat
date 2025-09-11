import SwiftUI
#if canImport(os)
import os.log
import os.signpost
#endif

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
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(textColor)

            Text("bounchat; hesabın, telefon numarasının ve merkezi sunucuların olmadığı, eşler arası bir sohbet deneyimi sunar. Gizliliğiniz önceliğimizdir; verilerinizi takip etmeyiz. Lütfen topluluğu saygılı ve güvenli tutmamıza yardımcı olun.")
                .font(.system(size: 15))
                .foregroundColor(textColor)
                .lineSpacing(4)

            Text("Devam etmeden önce aşağıdaki temel kuralları anladığınızı onaylayın:")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(textColor)

            VStack(alignment: .leading, spacing: 8) {
                bullet("Nefret söylemi, taciz, yasa dışı içerik ve şiddet çağrılarına izin verilmez.")
                bullet("Uygunsuz içerikleri ‘Rapor Et’ ile bildirebilirsiniz; bildirimi önceliklendirerek inceleriz.")
                bullet("İstemediğiniz konuşmaları ‘Engelle’ ile durdurabilirsiniz.")
                bullet("Geohash kanalları herkese açıktır; özel mesajlar desteklendiğinde uçtan uca şifrelenir. Ekran görüntülerini engelleyemeyiz, hassas bilgileri dikkatle paylaşın.")
                bullet("Bluetooth ve konum izinlerinizi Ayarlar’dan dilediğiniz an yönetebilirsiniz. Detaylar için Gizlilik Politikası’nı okuyun.")
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
                    .foregroundColor(textColor)
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
        .onAppear {
            #if canImport(os)
            if #available(iOS 12.0, macOS 10.14, *) {
                let log = OSLog(subsystem: "chat.bitchat", category: "launch")
                os_signpost(.event, log: log, name: "FirstRunConsentView.onAppear")
            }
            #endif
        }
    }

    @ViewBuilder
    private func bullet(_ s: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(s)
        }
        .font(.system(size: 14))
        .foregroundColor(textColor)
        .lineSpacing(3)
    }
}

#Preview {
    FirstRunConsentView(onAccepted: {})
}
