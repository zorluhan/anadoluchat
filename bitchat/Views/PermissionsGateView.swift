import SwiftUI

struct PermissionsGateView: View {
    @Environment(\.colorScheme) var colorScheme
    let onDone: () -> Void

    private var backgroundColor: Color { colorScheme == .dark ? .black : .white }
    private var textColor: Color { colorScheme == .dark ? .green : Color(red: 0, green: 0.5, blue: 0) }

    @State private var started = false

    var body: some View {
        VStack(spacing: 16) {
            Text("İzinler Hazırlanıyor")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(textColor)
            Text("Bildirim, Bluetooth ve Konum izinleri isteniyor…")
                .font(.system(size: 14, design: .monospaced))
                .multilineTextAlignment(.center)
                .foregroundColor(textColor.opacity(0.9))
            ProgressView()
                .progressViewStyle(.circular)
                .tint(textColor)
                .scaleEffect(1.1)
            Button("Devam et") { finish() }
                .buttonStyle(.bordered)
                .padding(.top, 8)
        }
        .padding(24)
        .frame(maxWidth: 360)
        .background(backgroundColor)
        .task { kickOffIfNeeded() }
        .onAppear { kickOffIfNeeded() }
    }

    private func kickOffIfNeeded() {
        guard !started else { return }
        started = true

        // 1) Notifications
        NotificationService.shared.requestAuthorization()

        // 2) Konum (geohash kanalları için)
        LocationChannelManager.shared.enableLocationChannels()

        // 3) Bluetooth — hızlı yetki ısındırması
        #if os(iOS)
        BluetoothPermissionWarmup.shared.start()
        #endif

        // Progress quickly to main UI; prompts will display over it
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            finish()
        }
    }

    private func finish() {
        onDone()
    }
}

#Preview {
    PermissionsGateView(onDone: {})
}

