# Convert

Convert, dosyaları cihazda ve internet bağlantısı gerektirmeden dönüştüren bir macOS ve iPhone uygulamasıdır. Bu depo **0.5.0 deneme sürümünün** kaynak kodunu içerir.

## Platformlar

- **iPhone:** `ios/ConvertIOS.xcodeproj` dosyasını Xcode 27 ile açın. iOS 17 veya üstü hedeflenir. Signing & Capabilities bölümünde kendi Apple geliştirme takımınızı seçip cihazınıza çalıştırın.
- **macOS:** `macos/ConvertMac.swift` kaynak dosyası. Xcode'da yeni bir macOS SwiftUI App projesi oluşturup varsayılan uygulama dosyasının yerine bu dosyayı koyarak derleyebilirsiniz. Apple Silicon Mac üzerinde denendi.

## Mevcut özellikler

- Dosya seçme, hedef biçim önerisi, ön izleme ve çıktı paylaşma/kaydetme.
- Açık, koyu ve saydamlığı ayarlanabilir Liquid Glass temaları.
- Ayarlar bölümünde sürüm, yerel olarak saklanan düzenlenebilir yapımcı adı ve biçim durumları.
- Görsel/PDF dönüşümleri ve sistem çerçevelerinin desteklediği bazı ses/video dönüşümleri. Tam destek kaynak biçime ve işletim sisteminin yerel kodlayıcılarına bağlıdır.

**Convertio biçim eşitliği henüz yoktur.** MP3 çıktısı, pek çok ofis/özel biçim ve Windows/Android uygulaması bu sürümde bulunmaz. Ayarlar ekranındaki biçim listesi destek planını gösterir; listede görünmek çalışan bir dönüşüm anlamına gelmez. Ayrıntılar için [FORMAT_SCOPE.md](FORMAT_SCOPE.md) dosyasına bakın.

## Gizlilik

Dönüştürme cihazda yapılır; dosyalar bir sunucuya yüklenmez.

## Dağıtım

Bu depo kaynak kodu içerir. İmzalı iOS uygulaması geliştirme takımınıza ve cihazınıza bağlıdır. macOS DMG paketi Apple Developer kimliğiyle notarize edilmemiştir ve bu depodaki kaynakla ayrıca derlenmelidir.
