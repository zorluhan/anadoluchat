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
