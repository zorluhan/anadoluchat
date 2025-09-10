import SwiftUI

struct AppInfoView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showPrivacyPolicy = false
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    
    private var textColor: Color {
        colorScheme == .dark ? Color.green : Color(red: 0, green: 0.5, blue: 0)
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? Color.green.opacity(0.8) : Color(red: 0, green: 0.5, blue: 0).opacity(0.8)
    }
    
    // MARK: - Constants
    private enum Strings {
    static let appName = "bounchat"
        static let tagline = "yan grup sohbeti"
        
        enum Features {
            static let title = "ÖZELLİKLER"
            static let offlineComm = ("wifi.slash", "çevrimdışı iletişim", "Bluetooth düşük enerji kullanarak internet olmadan çalışır")
            static let encryption = ("lock.shield", "uçtan uca şifreleme", "özel mesajlar noise protokolü ile şifrelenir")
            static let extendedRange = ("antenna.radiowaves.left.and.right", "genişletilmiş menzil", "mesajlar eşler arasında aktarılarak uzağa ulaşır")
            static let mentions = ("at", "bahsetmeler", "belirli kişileri bilgilendirmek için @takmaad kullanın")
            static let favorites = ("star.fill", "favoriler", "favori kişileriniz katıldığında bildirim alın")
            static let geohash = ("number", "yerel kanallar", "merkezi olmayan anonim aktarıcılar üzerinden yakındaki bölgelerdeki insanlarla sohbet etmek için geohash kanalları")
        }
        
        enum Privacy {
            static let title = "GİZLİLİK"
            static let noTracking = ("eye.slash", "izleme yok", "sunucu, hesap veya veri toplama yoktur")
            static let ephemeral = ("shuffle", "geçici kimlik", "düzenli olarak yeni eş kimliği oluşturulur")
            static let panic = ("hand.raised.fill", "panik modu", "tüm verileri anında temizlemek için logoya üç kez dokunun")
        }
        
        enum HowToUse {
            static let title = "NASIL KULLANILIR"
            static let instructions = [
                "• takma adınızı dokunarak ayarlayın",
                "• kanalları değiştirmek için #mesh'e dokunun",
                "• kenar çubuğu için kişiler simgesine dokunun",
                "• DM başlatmak için bir eşin adına dokunun",
                "• temizlemek için sohbete üç kez dokunun",
                "• komutlar için / yazın"
            ]
        }
        
        enum Warning {
            static let title = "UYARI"
            static let message = "özel mesaj güvenliği henüz tam olarak denetlenmemiştir. bu uyarı kaybolana kadar kritik durumlar için kullanmayın."
        }
    }
    
    var body: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            // Custom header for macOS
            HStack {
                Spacer()
                Button("BİTTİ") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(textColor)
                .padding()
            }
            .background(backgroundColor.opacity(0.95))
            
            ScrollView {
                infoContent
            }
            .background(backgroundColor)
        }
        .frame(width: 600, height: 700)
        #else
        NavigationView {
            ScrollView {
                infoContent
            }
            .background(backgroundColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("kapat") {
                        dismiss()
                    }
                    .foregroundColor(textColor)
                }
            }
        }
        #endif
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
    }
    
    @ViewBuilder
    private var infoContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .center, spacing: 8) {
                Text(Strings.appName)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(textColor)
                
                Text(Strings.tagline)
                    .font(.system(size: 16, design: .monospaced))
                    .foregroundColor(secondaryTextColor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            
            // Features
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(Strings.Features.title)
                
                FeatureRow(icon: Strings.Features.offlineComm.0, 
                          title: Strings.Features.offlineComm.1,
                          description: Strings.Features.offlineComm.2)
                
                FeatureRow(icon: Strings.Features.encryption.0,
                          title: Strings.Features.encryption.1,
                          description: Strings.Features.encryption.2)
                
                FeatureRow(icon: Strings.Features.extendedRange.0,
                          title: Strings.Features.extendedRange.1,
                          description: Strings.Features.extendedRange.2)
                
                FeatureRow(icon: Strings.Features.favorites.0,
                          title: Strings.Features.favorites.1,
                          description: Strings.Features.favorites.2)
                
                FeatureRow(icon: Strings.Features.geohash.0,
                          title: Strings.Features.geohash.1,
                          description: Strings.Features.geohash.2)
                
                FeatureRow(icon: Strings.Features.mentions.0,
                          title: Strings.Features.mentions.1,
                          description: Strings.Features.mentions.2)
            }
            
            // Privacy
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(Strings.Privacy.title)
                
                FeatureRow(icon: Strings.Privacy.noTracking.0,
                          title: Strings.Privacy.noTracking.1,
                          description: Strings.Privacy.noTracking.2)
                
                FeatureRow(icon: Strings.Privacy.ephemeral.0,
                          title: Strings.Privacy.ephemeral.1,
                          description: Strings.Privacy.ephemeral.2)
                
                FeatureRow(icon: Strings.Privacy.panic.0,
                          title: Strings.Privacy.panic.1,
                          description: Strings.Privacy.panic.2)
            }
            
            // How to Use
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(Strings.HowToUse.title)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Strings.HowToUse.instructions, id: \.self) { instruction in
                        Text(instruction)
                    }
                }
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(textColor)
            }
            
            // Warning
            VStack(alignment: .leading, spacing: 6) {
                SectionHeader(Strings.Warning.title)
                    .foregroundColor(Color.red)
                
                Text(Strings.Warning.message)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Color.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 6)
            .padding(.bottom, 16)
            .padding(.horizontal)
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
            
            .padding(.top)

            // Legal / Support
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader("YASAL / DESTEK")
                Button {
                    showPrivacyPolicy = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                        Text("Gizlilik Politikası")
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(textColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
}

struct SectionHeader: View {
    let title: String
    @Environment(\.colorScheme) var colorScheme
    
    private var textColor: Color {
        colorScheme == .dark ? Color.green : Color(red: 0, green: 0.5, blue: 0)
    }
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .bold, design: .monospaced))
            .foregroundColor(textColor)
            .padding(.top, 8)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    @Environment(\.colorScheme) var colorScheme
    
    private var textColor: Color {
        colorScheme == .dark ? Color.green : Color(red: 0, green: 0.5, blue: 0)
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? Color.green.opacity(0.8) : Color(red: 0, green: 0.5, blue: 0).opacity(0.8)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(textColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(textColor)
                
                Text(description)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(secondaryTextColor)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

#Preview {
    AppInfoView()
}
