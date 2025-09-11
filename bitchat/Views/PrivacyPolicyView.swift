import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    // Parsed blocks to control spacing/typography
    @State private var blocks: [Block] = []

    private var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }

    private var textColor: Color {
        colorScheme == .dark ? .green : Color(red: 0, green: 0.5, blue: 0)
    }

    // Inline fallback in case the bundled Markdown cannot be found
    private let fallbackMarkdown: String = """
    # Gizlilik Politikası

    ## Biz kimiz
    bounchat, eşler arası (peer-to-peer) bir kampüs mesajlaşma uygulamasıdır. Mesajlarınızı saklayan merkezi sunucular çalıştırmıyoruz. Analitik veya reklam platformu da işletmiyoruz. Tüm mesajlar kendi telefonunuzda depolanır ve telefonunuzdan dışarı çıkmaz.

    ## Özet
    - Hesap veya telefon numarası yok.
    - Analitik, reklam ya da takip SDK’sı yok.
    - Kişisel verileri toplamıyor, satmıyor veya paylaşmıyoruz.
    - Mesajlar Bluetooth üzerinden eşler arası veya herkese açık Nostr aktarıcıları üzerinden gönderilir. Herkese açık mesajlar herkes tarafından görülebilir; özel mesajlar ise desteklendiğinde uçtan uca şifrelenir.

    ## Toplamadığımız veriler
    Sunucularımızda şunları toplamaz veya saklamayız: isimler, e-postalar, telefon numaraları, kişiler, hassas cihaz tanımlayıcıları (IDFA dahil), kullanım analitiği, satın alma geçmişi veya teşhis günlükleri. Kişisel bilgileri satmaz veya gizlilik yasalarında tanımlandığı şekilde “paylaşmayız”.

    ## Cihazınızda işlenen veriler
    - Takma ad ve ayarlar: yalnızca cihazınızda saklanır.
    - Kriptografik anahtarlar: cihazınızda (iOS Keychain) üretilir ve saklanır.
    - Konum (yaklaşık): konum kanallarını açarsanız, yakın geohash kanallarını hesaplamak için cihaz üzerinde “Uygulamayı Kullanırken” izni isteriz. Konumunuz sunucularımıza iletilmez. İstediğiniz zaman Ayarlar’dan izni geri alabilirsiniz.
    - Bluetooth: yakın cihazları bulmak ve onlarla iletişim kurmak için kullanılır. İlk kullanımda sistem Bluetooth izin uyarısı gösterebilir.

    ## Mesajlaşma ve aktarıcılar
    - Mesh/Bluetooth: Mesajlar doğrudan yakın cihazlar arasında iletilir. Özel mesh mesajları Noise tabanlı uçtan uca şifreleme ile korunur.
    - Nostr/İnternet: Yakın değilseniz, mesajlar herkese açık Nostr aktarıcıları üzerinden gönderilebilir. Geohash gönderileri herkese açıktır ve aktarıcılar tarafından saklanabilir. Özel DM’ler NIP-17 hediye paketli şifreleme ile korunur. Aktarıcılar üçüncü taraflardır; kendi politikaları geçerlidir. Biz onları kontrol etmeyiz veya işletmeyiz.

    ## Bildirimler
    Uygulama yerel bildirimler veya platform bildirimlerini zamanlayabilir. Bildirim işleme Apple/işletim sistemi tarafından sağlanır; biz kendi push sunucumuzu işletmeyiz ve kendi kullanımımız için push belirteçlerini toplamıyoruz.

    ## Seçenekleriniz ve kontrolleriniz
    - İzinler: Bluetooth ve Konumu cihaz Ayarları’ndan yönetebilirsiniz.
    - Veri temizleme: Uygulama içindeki silme/temizleme fonksiyonlarını (acil silme dahil) kullanarak cihazınızdaki içerik ve anahtarları kaldırabilirsiniz.
    - Herkese açık gönderiler: Geohash kanal gönderilerinin herkese açık olduğunu ve üçüncü taraf aktarıcılar tarafından saklanabileceğini unutmayın.

    ## Çocukların gizliliği
    bounchat, 13 yaş altındaki (veya bulunduğunuz bölgedeki asgari yaş sınırının altındaki) çocuklara yönelik değildir. Çocukların kişisel verilerini bilerek toplamıyoruz.

    ## Güvenlik
    Anahtarlar iOS Keychain’de saklanır. Mesh DM’leri Noise şifrelemesiyle, Nostr DM’leri standart Nostr şifrelemesiyle korunur. Hiçbir güvenlik sistemi kusursuz değildir; hassas bilgiler paylaşırken dikkatli olun.

    ## Uluslararası aktarımlar
    Sunucular işletmiyoruz ve verilerinizi kendi altyapımıza aktarmıyoruz. Ancak herkese açık aktarıcılara gönderi yaparsanız, içeriğiniz bu üçüncü taraflarca küresel olarak saklanabilir ve sunulabilir.

    ## Bu politikanın değişiklikleri
    Bu politikayı açıklık veya yasal nedenlerle güncelleyebiliriz. Önemli değişiklikler “Son güncelleme” tarihinde yansıtılır.
    """

    var body: some View {
        #if os(iOS)
        NavigationView {
            policyContent
                .navigationTitle("Gizlilik Politikası")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing:
                    Button("kapat") { dismiss() }
                        .foregroundColor(textColor)
                )
        }
        .onAppear(perform: loadPolicy)
        .background(backgroundColor)
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
            policyContent
        }
        .frame(minWidth: 520, minHeight: 600)
        .onAppear(perform: loadPolicy)
        .background(backgroundColor)
        #endif
    }

    private var policyContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(blocks.enumerated()), id: \.offset) { _, b in
                    switch b {
                    case .heading(let t, let level):
                        Text(t)
                            .font(.system(size: level == 1 ? 18 : 16, weight: .bold, design: .default))
                            .foregroundColor(textColor)
                            .padding(.top, 8)
                    case .paragraph(let t):
                        Text(t)
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(textColor)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    case .bullet(let t):
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(textColor)
                                .padding(.top, 2)
                            Text(t)
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(textColor)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .background(backgroundColor)
    }

    private func loadPolicy() {
        // Prefer bundled markdown; otherwise fallback text
        let raw: String = {
            if let url = Bundle.main.url(forResource: "PRIVACY_POLICY", withExtension: "md"),
               let data = try? Data(contentsOf: url),
               let s = String(data: data, encoding: .utf8) { return s }
            return fallbackMarkdown
        }()
        self.blocks = Self.parseMarkdownLite(raw)
    }

    // Minimal markdown parser for our headings/bullets/paragraphs
    private static func parseMarkdownLite(_ s: String) -> [Block] {
        var result: [Block] = []
        var buffer: [String] = []
        func flushParagraph() {
            if !buffer.isEmpty {
                let text = buffer.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                if !text.isEmpty { result.append(.paragraph(text)) }
                buffer.removeAll()
            }
        }
        for line in s.replacingOccurrences(of: "\r\n", with: "\n").split(separator: "\n", omittingEmptySubsequences: false) {
            let str = String(line)
            let trimmed = str.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("# ") {
                flushParagraph()
                let t = trimmed.dropFirst(2).trimmingCharacters(in: .whitespaces)
                result.append(.heading(String(t), 1))
            } else if trimmed.hasPrefix("## ") {
                flushParagraph()
                let t = trimmed.dropFirst(3).trimmingCharacters(in: .whitespaces)
                result.append(.heading(String(t), 2))
            } else if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") {
                flushParagraph()
                let t = trimmed.dropFirst(2).trimmingCharacters(in: .whitespaces)
                result.append(.bullet(String(t)))
            } else if trimmed.isEmpty {
                flushParagraph()
            } else {
                buffer.append(trimmed)
            }
        }
        flushParagraph()
        return result
    }

    private enum Block {
        case heading(String, Int)
        case paragraph(String)
        case bullet(String)
    }
}

#Preview {
    PrivacyPolicyView()
}
