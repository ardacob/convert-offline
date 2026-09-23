# Convert

Convert, Arda Çobanoğlu tarafından geliştirilen; dosyaları cihazda ve internet bağlantısı gerektirmeden dönüştüren bir macOS ve iPhone uygulamasıdır. Bu depo **0.2.2 deneme sürümünün** kaynak kodunu içerir.

## Sürüm geçmişi

- [Değişiklik günlüğü](CHANGELOG.md): her doğrulanmış sürümdeki yenilikler ve sınırlamalar.
- [v0.1.0 — Flutter 0.1.0+1 prototipi](https://github.com/ardacob/convert-offline/releases/tag/v0.1.0): ilk, derlenmemiş çok platformlu kaynak taslağı.
- [v0.2.2 — yeni uygulama logosu](https://github.com/ardacob/convert-offline/releases/tag/v0.2.2): iPhone ve macOS uygulama simgeleri yenilendi.
- [v0.2.1 — arayüz düzenlemesi](https://github.com/ardacob/convert-offline/releases/tag/v0.2.1): ayarlardan statik biçim listeleri kaldırıldı; hedefler seçilen dosyaya göre gösteriliyor.
- [v0.2.0 — macOS ve iPhone](https://github.com/ardacob/convert-offline/releases/tag/v0.2.0): `ios/` ve `macos/` kaynakları; macOS DMG sürüm eki.

## Platformlar

- **iPhone:** `ios/ConvertIOS.xcodeproj` dosyasını Xcode 27 ile açın. iOS 17 veya üstü hedeflenir. Signing & Capabilities bölümünde kendi Apple geliştirme takımınızı seçip cihazınıza çalıştırın.
- **macOS:** `macos/ConvertMac.swift` kaynak dosyası. Xcode'da yeni bir macOS SwiftUI App projesi oluşturup varsayılan uygulama dosyasının yerine bu dosyayı koyarak derleyebilirsiniz. Apple Silicon Mac üzerinde denendi.

## Mevcut özellikler

- Dosya seçme, hedef biçim önerisi, ön izleme ve çıktı paylaşma/kaydetme.
- Açık, koyu ve saydamlığı ayarlanabilir Liquid Glass temaları.
- Ayarlar bölümünde sürüm, varsayılanı Arda Çobanoğlu olan düzenlenebilir yapımcı adı.
- Görsel/PDF dönüşümleri ve sistem çerçevelerinin desteklediği bazı ses/video dönüşümleri. Tam destek kaynak biçime ve işletim sisteminin yerel kodlayıcılarına bağlıdır.

**Convertio biçim eşitliği henüz yoktur.** MP3 çıktısı, pek çok ofis/özel biçim ve Windows/Android uygulaması bu sürümde bulunmaz. Ayrıntılar için [FORMAT_SCOPE.md](FORMAT_SCOPE.md) dosyasına bakın.

## Gizlilik

Dönüştürme cihazda yapılır; dosyalar bir sunucuya yüklenmez.

## Dağıtım

Bu depo kaynak kodu içerir. İmzalı iOS uygulaması geliştirme takımınıza ve cihazınıza bağlıdır. macOS DMG paketi [v0.2.2 sürüm ekinde](https://github.com/ardacob/convert-offline/releases/tag/v0.2.2) bulunur; Apple Developer kimliğiyle notarize edilmemiştir.
