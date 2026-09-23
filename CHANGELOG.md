# Değişiklik günlüğü

Bu kayıt, elde kalan kaynak dosyaları ve doğrulanmış teslimlerden geriye dönük oluşturuldu. Kayıtlı olmayan ara kaynak durumları veya kesinleştirilemeyen değişiklikler sürüm olarak sunulmaz. Bundan sonraki her yayın, kendi kaynak anlık görüntüsü, sürüm etiketi ve değişiklik notuyla kaydedilecektir.

## 0.5.0 — 23 Eylül 2026

### macOS

- İlk yerel macOS SwiftUI uygulaması ve Apple Silicon DMG paketi hazırlandı.
- Dosya seçimi, kaynak dosyaya göre hedef biçim listesi, ön izleme ve çıktı kaydetme eklendi.
- Görsel/PDF, bazı belge, ses ve video dönüşümleri macOS'un yerel araçlarıyla eklendi.
- Açık, koyu ve saydamlığı ayarlanabilir Liquid Glass temaları eklendi.
- Ayarlar sekmesine sürüm, kullanıcı tarafından düzenlenen yapımcı adı ve biçim durumları eklendi.
- İstenen bütün biçimlerin henüz desteklenmediği arayüzde ve belgelerde açıklandı.

### iPhone

- SwiftUI arayüzü iPhone'a uyarlandı; dosya seçimi, ön izleme, dönüştürme, paylaşma ve ayarlar eklendi.
- İşlemler cihaz üzerinde çalışacak şekilde kuruldu.
- Fiziksel iPhone 16 Plus'a yüklenip MP4 → MOV dönüşümü doğrulandı.
- iOS sürümünde belge ve özel biçimlerin çoğu henüz dönüşüm hedefi değildir; biçim listesi durumlarını gösterir.

### Kod ve paketler

- Kaynaklar `macos/` ve `ios/` dizinlerinde tutulur.
- macOS DMG bu depoya eklenmedi; kaynak kodu derlenebilir durumdadır. iOS uygulaması geliştirme imzasıyla cihaza yüklenmiştir, genel dağıtım paketi değildir.

## 0.1.0+1 — 23 Eylül 2026 — Flutter prototipi

- macOS, iOS, Android ve Windows için ortak Flutter arayüzü taslağı oluşturuldu.
- Görsel, PDF, ses ve video için hedef biçim kataloğu; FFmpeg tabanlı dönüşüm servisi ve paylaşma arayüzü yazıldı.
- Bu aşamanın kaynakları [`archive/flutter-0.1.0`](archive/flutter-0.1.0) altında saklanır.
- Flutter SDK bu çalışma ortamında bulunmadığından prototip derlenmedi ve dört platformda çalıştığı doğrulanmadı. APK, IPA, EXE veya DMG bu sürüm için yayımlanmadı.

## Ara geliştirme notları

0.1.0 prototipinden 0.5.0'a geçerken birkaç numarasız macOS test derlemesi oluşturuldu. Bunlar ayrı yayımlanmış sürümler değildir. Her birine ait kaynak anlık görüntüsü bulunmadığından sürüm etiketi veya doğrulanmamış özellik listesi eklenmedi. 0.5.0 öncesindeki görünüm, tema ve dönüştürme isteklerinin sonucu yukarıdaki 0.5.0 kaydında açıklanır.

## Bundan sonraki sürüm kayıtları

Her yeni sürümde `CHANGELOG.md` güncellenecek; sürüm numarası kaynakta da artırılacak. Kaynak anlık görüntüsü Git etiketiyle sabitlenecek. Kullanıcıya dönük değişiklikler, düzeltilen hatalar, doğrulanan platformlar, bilinen sınırlamalar ve varsa kurulum paketi aynı sürüm notunda yazılacak. Tamamlanmamış biçimler “destekleniyor” diye listelenmeyecek.
