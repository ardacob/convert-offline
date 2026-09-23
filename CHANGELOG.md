# Değişiklik günlüğü

Bu kayıt, elde kalan kaynak dosyaları ve doğrulanmış teslimlerden geriye dönük oluşturuldu. İlk yerel uygulama sürümü önce yanlışlıkla `0.5.0` olarak etiketlenmiş, arada `0.2.0`–`0.4.0` yayınları olmadığı için `0.2.0` olarak düzeltilmiştir; dönüştürme işlevleri korunmuştur. Bu düzeltmede iPhone cam teması yerel iOS Liquid Glass bileşenleriyle yenilenmiş ve yapımcı adı Arda Çobanoğlu olarak ayarlanmıştır. Kayıtlı olmayan ara kaynak durumları veya kesinleştirilemeyen değişiklikler sürüm olarak sunulmaz. Bundan sonraki her yayın, kendi kaynak anlık görüntüsü, sürüm etiketi ve değişiklik notuyla kaydedilecektir.

## 0.2.3 — 24 Eylül 2026

- Yeni logo macOS ve iPhone uygulamalarının Dönüştür ekranındaki başlıklara eklendi.
- Uygulama simgeleri korunarak Mac DMG ve iPhone uygulaması yeniden paketlendi.

## 0.2.2 — 24 Eylül 2026

- Convert için iki dosya ve dönüşüm oklarından oluşan yeni mavi uygulama logosu hazırlandı.
- Logo iPhone uygulama simgesi ve macOS DMG içindeki uygulama simgesi olarak eklendi.
- iPhone ve macOS paketleri 0.2.2 olarak güncellendi.

## 0.2.1 — 24 Eylül 2026

- macOS ve iPhone Ayarlar ekranlarından statik görsel ve belge biçimi listeleri kaldırıldı.
- Hedef biçim seçenekleri seçilen dosyaya göre Dönüştür ekranında gösterilmeye devam ediyor.
- Uygulama sürümü ve macOS/iPhone kurulum paketleri 0.2.1 olarak güncellendi.

## 0.2.0 — 23 Eylül 2026

### macOS

- İlk yerel macOS SwiftUI uygulaması ve Apple Silicon DMG paketi hazırlandı.
- Dosya seçimi, kaynak dosyaya göre hedef biçim listesi, ön izleme ve çıktı kaydetme eklendi.
- Görsel/PDF, bazı belge, ses ve video dönüşümleri macOS'un yerel araçlarıyla eklendi.
- Açık, koyu ve saydamlığı ayarlanabilir Liquid Glass temaları eklendi.
- Ayarlar sekmesine sürüm, varsayılan Arda Çobanoğlu adı (Ayarlar’dan düzenlenebilir) ve biçim durumları eklendi.
- İstenen bütün biçimlerin henüz desteklenmediği arayüzde ve belgelerde açıklandı.

### iPhone

- Sistemin yerel Liquid Glass görünümü ve cam düğmeleri kullanıldı; cam yüzeylerin saydamlığı Ayarlar’dan değiştirilebilir.
- SwiftUI arayüzü iPhone'a uyarlandı; dosya seçimi, ön izleme, dönüştürme, paylaşma ve ayarlar eklendi.
- İşlemler cihaz üzerinde çalışacak şekilde kuruldu.
- Fiziksel iPhone 16 Plus'a yüklenip MP4 → MOV dönüşümü doğrulandı.
- iOS sürümünde belge ve özel biçimlerin çoğu henüz dönüşüm hedefi değildir; biçim listesi durumlarını gösterir.

### Kod ve paketler

- Kaynaklar `macos/` ve `ios/` dizinlerinde tutulur.
- macOS DMG Git kaynak ağacına eklenmedi; [v0.2.0 sürüm ekinde](https://github.com/ardacob/convert-offline/releases/tag/v0.2.0) yayımlandı. Kaynak kodu derlenebilir durumdadır. iOS uygulaması geliştirme imzasıyla cihaza yüklenmiştir, genel dağıtım paketi değildir.

## 0.1.0+1 — 23 Eylül 2026 — Flutter prototipi

- macOS, iOS, Android ve Windows için ortak Flutter arayüzü taslağı oluşturuldu.
- Görsel, PDF, ses ve video için hedef biçim kataloğu; FFmpeg tabanlı dönüşüm servisi ve paylaşma arayüzü yazıldı.
- Bu aşamanın kaynakları [`archive/flutter-0.1.0`](archive/flutter-0.1.0) altında saklanır.
- Flutter SDK bu çalışma ortamında bulunmadığından prototip derlenmedi ve dört platformda çalıştığı doğrulanmadı. APK, IPA, EXE veya DMG bu sürüm için yayımlanmadı.

## Ara geliştirme notları

0.1.0 prototipinden 0.2.0'a geçerken birkaç numarasız macOS test derlemesi oluşturuldu. Bunlar ayrı yayımlanmış sürümler değildir. Her birine ait kaynak anlık görüntüsü bulunmadığından sürüm etiketi veya doğrulanmamış özellik listesi eklenmedi. 0.2.0 öncesindeki görünüm, tema ve dönüştürme isteklerinin sonucu yukarıdaki 0.2.0 kaydında açıklanır.

## Bundan sonraki sürüm kayıtları

Her yeni sürümde `CHANGELOG.md` güncellenecek; sürüm numarası kaynakta da artırılacak. Kaynak anlık görüntüsü Git etiketiyle sabitlenecek. Kullanıcıya dönük değişiklikler, düzeltilen hatalar, doğrulanan platformlar, bilinen sınırlamalar ve varsa kurulum paketi aynı sürüm notunda yazılacak. Tamamlanmamış biçimler “destekleniyor” diye listelenmeyecek.
