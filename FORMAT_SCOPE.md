# Convertio kapsamı ve çevrimdışı hedef

[Convertio](https://convertio.co/) 300'den fazla biçim ve 25.600'den fazla dönüşüm eşleşmesi belirtiyor. Bu sayılar uygulamanın mevcut desteği değildir.

Bu Mac uygulaması yerel macOS motorlarıyla çalışır: ImageIO (görsel), PDFKit (PDF), `textutil` (belge), AVFoundation/Core Audio (ses/video). Uygulama yalnızca seçili dosya için yerel motorda bulunan hedefleri listeler. Dönüşümlerde dosya sunucuya yüklenmez.

Uygulama, dosya seçildikten sonra yalnızca o dosya için çalışabilen hedef biçimleri gösterir. Bu belgedeki kapsam planı uygulama içindeki seçenek listesi değildir.

Tam Convertio eşitliği için her biçimin yalnızca uzantısını listelemek yetmez. Gerekli çözücüler, kodlayıcılar, kalite ve kayıpsızlık testleri, özel biçim lisansları, macOS/iOS/Android/Windows derlemeleri ve her kaynak–hedef çiftinin doğrulanması gerekir. Özellikle CAD, e-kitap, font, arşiv, 3D, nadir video codec'leri ve eski ofis biçimleri ayrı motorlar ister. Bazı özel biçimler için çevrimdışı, yasal olarak dağıtılabilir kodlayıcı bulunmayabilir.

Bu yüzden mevcut DMG **Convertio'nun bütün biçimlerini destekliyor** şeklinde sunulmamalıdır. Genişletme sırası: FFmpeg ile ses/video, ImageMagick ile görseller, LibreOffice ile belgeler, Poppler/Ghostscript ile PDF, libarchive ile arşivler; sonra CAD/e-kitap/font için ayrı değerlendirme. Her motor uygulama içine paketlenmeli ve dört platformda ayrıca test edilmelidir.
