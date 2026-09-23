# Convert — çevrimdışı dosya dönüştürücü

Flutter tabanlı ilk sürüm. Aynı Dart arayüzü Android (APK), iOS, macOS ve Windows için kullanılır. Dosyalar cihazda işlenir; uygulama bir sunucuya yükleme yapmaz.

## Desteklenen dönüşümler

| Kaynak | Hedef |
| --- | --- |
| JPG, JPEG, PNG, WebP, BMP | JPG, PNG, WebP, PDF |
| PDF | Her sayfa için PNG |
| MP3, WAV, M4A, AAC, FLAC, OGG | MP3, WAV, M4A, FLAC |
| MP4, MOV, MKV, WebM, AVI | MP4, MOV, WebM, MP3, WAV |

Kaynakla aynı uzantı hedef listesinde görünmez. Gerçek kodlayıcı desteği, seçilen FFmpeg paketinin platform derlemesine bağlıdır. Şifreli PDF, bozuk dosya veya nadir codec'ler hata verebilir. “Tüm uzantılar” vaat edilmez; dönüşüm çiftleri `lib/conversion_catalog.dart` içinde genişletilir.

## Geliştirme

Flutter SDK 3.12 veya daha yeni Dart içeren bir sürüm, Android SDK ve Apple hedefleri için Xcode gerekir. Windows derlemesi Windows makinesinde alınır.

```sh
cd convert_app
flutter create --project-name convert_app --platforms=android,ios,macos,windows .
flutter pub get
flutter run -d macos
```

APK: `flutter build apk --release`. iOS: `flutter build ios --release`. macOS: `flutter build macos --release`. Windows: `flutter build windows --release` (Windows üzerinde).

FFmpeg eklentisi için Android minSdk 26, iOS 13 ve macOS 13 ayarlanmalıdır. iOS simulator mimari dışlama ayarları için [eklenti kurulum yönergesini](https://pub.dev/packages/ffmpeg_kit_extended_flutter) izleyin. macOS dosya seçicinin sandbox yetkileri ve iOS imzalama ayarları dağıtımdan önce tamamlanmalıdır.

Çıktılar uygulamanın belgeler klasöründeki `Convert` dizinine yazılır. Arayüzdeki **Dosyaları paylaş / kaydet** düğmesi, mobil cihazlarda Dosyalar uygulamasına dışa aktarmayı sağlar.

## Durum ve doğrulama

Bu çalışma alanında Flutter/Dart SDK olmadığı için `flutter pub get`, analiz, test ve dört platformda derleme çalıştırılamadı. Kaynak proje hazırlanmıştır; derlenmiş APK/IPA/EXE teslim edilmemiştir. İlk derlemede platform ayarları ve FFmpeg yerel kitaplıkları doğrulanmalıdır.

FFmpeg yerel paketinin lisans ve uygulama mağazası koşulları dağıtımdan önce incelenmelidir. Yapılandırma GPL olmayan `video` paketini seçer.
