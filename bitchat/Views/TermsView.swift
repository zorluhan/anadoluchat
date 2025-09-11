import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var blocks: [Block] = []
    // Inline fallback so the text is always visible even if the bundled resource is missing
    private let fallbackMarkdown: String = """
    # Kullanım Şartları

    ## Uygulamanın Nasıl Çalıştığı
    - Eşler arası (P2P) iletişim: Yakındaki cihazlarla Bluetooth üzerinden doğrudan haberleşirsiniz; arada merkezi bir sunucu yoktur.
    - İnternet üzerinden köprü: Yakınınızda kimse yoksa, mesajlarınızı herkese açık Nostr aktarıcıları üzerinden iletebilirsiniz. Geohash kanalları genel niteliktedir.
    - Cihazda saklama: Takma adınız, anahtarlarınız ve tercihlerinizi yalnızca kendi cihazınızda tutarız. Sunucu işletmeyiz, hesabınız yoktur.
    - Şifreleme: Özel mesajlar desteklendiği yerlerde uçtan uca şifrelenir (mesh’te Noise, Nostr DM’lerinde hediye paketli şifreleme). Her sistemde olduğu gibi, mutlak güvenlik garanti edilemez; hassas bilgileri paylaşırken dikkatli olun.

    ## Şeffaflık ve Gizlilik
    - Analitik, reklam veya takip SDK’sı kullanmayız.
    - Bildirimler sistem tarafından işlenir; kendi push sunucularımız yoktur.
    - Konum izni “Uygulamayı Kullanırken” düzeyinde istenir; konumunuz sunucularımıza iletilmez. Geohash kanallarını önerirken cihaz üstünde yaklaşık konumdan yararlanırız.

    ## İçerik Görünürlüğü
    - Geohash (kanal) gönderileri herkes tarafından görülebilir ve üçüncü taraf Nostr aktarıcılarında saklanabilir. Paylaşmadan önce bunun herkese açık olduğunu unutmayın.
    - Özel mesajlar yalnızca katılımcılar tarafından görülebilecek şekilde tasarlanır; yine de ekran görüntüleri veya cihaz erişimi gibi dış faktörler bizim kontrolümüz dışındadır.

    ## Topluluk Kuralları (Özet)
    Saygılı, yardımsever ve güvenli bir ortam istiyoruz. Bu nedenle aşağıdakiler yasaktır:
    - Nefret söylemi, ırkçılık, cinsiyetçilik, ayrımcılık ve kişilere/kurumlara yönelik hakaret ve küçük düşürme.
    - Taciz, tehdit, zorbalık, şiddet çağrısı veya şiddeti yücelten içerik.
    - Yasa dışı içerikler; çocuk istismarı, uyuşturucu ticareti, terör propagandası, dolandırıcılık, zararlı yazılım yayma gibi faaliyetler.
    - Başkalarının kişisel verilerini (telefon, adres, kimlik vb.) izinsiz ifşa etmek.
    - Spam, istemsiz reklam, kimlik sahteciliği ve ağın kötüye kullanımı.

    ## Raporlama, Engelleme ve Uygulama İçi Güvenlik
    - Uygunsuz içerikleri “Rapor Et” üzerinden bize bildirebilirsiniz. Bildirimleri önceliklendirerek inceler, mümkün olduğunda 24 saat içinde aksiyon almayı hedefleriz.
    - Kötü niyetli kullanıcılarla karşılaşırsanız “Engelle” seçeneğini kullanabilirsiniz; bu kişilerden mesaj almanız engellenir.
    - Ciddi ihlallerde: İlgili içeriği kaldırma, hesap/cihaz anahtarını bloklama, yasal gereklilikler doğrultusunda iş birliği yapma gibi adımlar atabiliriz.
    - Acil silme: Uygulama içindeki acil silme fonksiyonu (ör. üç kez dokunma) yerel verilerinizi hızlıca kaldırmanıza yardımcı olur.

    ## Kullanıcı Sorumluluğu
    - Paylaştığınız içerikten siz sorumlusunuz. Yerel yasalarınıza uymakla yükümlüsünüz.
    - Üçüncü taraf Nostr aktarıcılarının kendi politikaları olabilir; bu altyapıları biz işletmeyiz veya kontrol etmeyiz.
    - Cihazınızın güvenliğini (kilit, işletim sistemi güncellemeleri, yedeklemeler) sağlamanız önemlidir.

    ## Teknik Sınırlar ve Erişilebilirlik
    - Bluetooth menzili ve çevresel koşullar iletişimi etkileyebilir. İnternet köprüsü yoksa mesajlar yalnızca yakınınızdaki cihazlara ulaşır.
    - Ağ gecikmeleri, cihaz uyumluluğu ve aktarıcı müsaitliği gibi etkenler mesaj teslimini etkileyebilir; kesintisiz/hatasız hizmet garanti edilmez.

    ## İzinler ve Tercihler
    - Bluetooth: Yakın cihazları bulmak ve bağlanmak için kullanılır.
    - Konum (yaklaşık): Bölgenizdeki geohash kanallarını önermek için kullanılır.
    - Bildirimler: Mesaj ve etkinliklerden haberdar olmanız için kullanılır; Ayarlar’dan dilediğiniz an kapatabilirsiniz.

    ## Çocukların Güvenliği
    bounchat, 13 yaş altındaki çocuklara yönelik değildir. Böyle bir kullanım tespit edilirse derhal bildirin; gerekli adımları atarız.

    ## Fikri Mülkiyet ve Açık Kaynak
    - Uygulama açık kaynaklıdır; kodu inceleyebilir ve katkıda bulunabilirsiniz.
    - Kendi içerikleriniz üzerinde haklar sizde kalır; ancak herkese açık kanallara gönderdiğiniz içeriklerin başkalarınca görülebileceğini ve kopyalanabileceğini unutmayın.

    ## Geri Bildirim ve İletişim
    Sorular, geri bildirimler ve raporlar için GitHub üzerinden konu açabilir veya uygulama içi raporlama aracını kullanabilirsiniz. Ayrıca doğrudan e‑posta ile ulaşabilirsiniz:
    - E‑posta: zolruhan@capish.co

    ## Sorumluluğun Sınırlandırılması
    Hizmet “olduğu gibi” sunulur. Veri kaybı, kesinti, gecikme veya üçüncü taraf alt yapılardan kaynaklanan sorunlarda dolaylı zararlardan sorumlu tutulamayız. Yine de güvenilir ve dayanıklı bir deneyim için sürekli iyileştirme yapıyoruz.

    ## Değişiklikler
    Bu şartları zaman zaman güncelleyebiliriz. Önemli değişiklikler uygulama içinde duyurulur ve yürürlük tarihi belirtilir. Uygulamayı kullanmaya devam ederek güncellenen şartları kabul etmiş olursunuz.
    """

    private var backgroundColor: Color { colorScheme == .dark ? .black : .white }
    private var textColor: Color { colorScheme == .dark ? .green : Color(red: 0, green: 0.5, blue: 0) }

    var body: some View {
        #if os(iOS)
        NavigationView {
            content
                .navigationTitle("Kullanım Şartları")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing:
                    Button("kapat") { dismiss() }.foregroundColor(textColor)
                )
        }
        .onAppear(perform: load)
        .background(backgroundColor)
        #else
        VStack(spacing: 0) {
            HStack { Spacer(); Button("BİTTİ") { dismiss() }.buttonStyle(.plain).foregroundColor(textColor).padding() }
                .background(backgroundColor.opacity(0.95))
            content
        }
        .frame(minWidth: 520, minHeight: 600)
        .onAppear(perform: load)
        .background(backgroundColor)
        #endif
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(blocks.enumerated()), id: \.offset) { _, b in
                    switch b {
                    case .heading(let t, let level):
                        Text(t)
                            .font(.system(size: level == 1 ? 18 : 16, weight: .bold))
                            .foregroundColor(textColor)
                            .padding(.top, 8)
                    case .paragraph(let t):
                        Text(t)
                            .font(.system(size: 14))
                            .foregroundColor(textColor)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    case .bullet(let t):
                        HStack(alignment: .top, spacing: 6) {
                            Text("•").font(.system(size: 14)).foregroundColor(textColor).padding(.top, 2)
                            Text(t).font(.system(size: 14)).foregroundColor(textColor).lineSpacing(4).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .background(backgroundColor)
    }

    private func load() {
        let raw: String
        if let url = Bundle.main.url(forResource: "KULLANIM_SARTLARI", withExtension: "md"),
           let data = try? Data(contentsOf: url),
           let s = String(data: data, encoding: .utf8) { raw = s } else { raw = fallbackMarkdown }
        blocks = Self.parseMarkdownLite(raw)
    }

    // Minimal markdown parser reused from PrivacyPolicyView style
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
                result.append(.heading(String(trimmed.dropFirst(2)), 1))
            } else if trimmed.hasPrefix("## ") {
                flushParagraph()
                result.append(.heading(String(trimmed.dropFirst(3)), 2))
            } else if trimmed.hasPrefix("- ") || trimmed.hasPrefix("* ") {
                flushParagraph()
                result.append(.bullet(String(trimmed.dropFirst(2))))
            } else if trimmed.isEmpty {
                flushParagraph()
            } else {
                buffer.append(trimmed)
            }
        }
        flushParagraph()
        return result
    }

    private enum Block { case heading(String, Int); case paragraph(String); case bullet(String) }
}

#Preview { TermsView() }
