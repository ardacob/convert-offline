import SwiftUI
import UIKit
import PDFKit
import ImageIO
import AVFoundation
import UniformTypeIdentifiers

@main
struct ConvertIOSApp: App {
    var body: some Scene {
        WindowGroup { RootView() }
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            ConverterView().tabItem { Label("Dönüştür", systemImage: "arrow.triangle.2.circlepath") }
            SettingsView().tabItem { Label("Ayarlar", systemImage: "gearshape") }
        }
    }
}

struct ConverterView: View {
    @AppStorage("convert.theme") private var theme = "light"
    @AppStorage("convert.glassOpacity") private var glassOpacity = 0.65
    @State private var source: URL?
    @State private var displayName = ""
    @State private var preview: UIImage?
    @State private var target = ""
    @State private var result: URL?
    @State private var status = "Dosya seçin"
    @State private var picking = false
    @State private var busy = false

    private var choices: [String] { source.map { FormatCatalog.choices(for: $0) } ?? [] }
    private var dark: Bool { theme == "dark" }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: dark
                               ? [Color(red: 0.07, green: 0.08, blue: 0.15), Color(red: 0.16, green: 0.12, blue: 0.28)]
                               : [Color(red: 0.91, green: 0.92, blue: 1), Color(red: 0.94, green: 0.99, blue: 1)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.title2.bold()).foregroundStyle(.white)
                                .frame(width: 52, height: 52)
                                .background(Color.indigo.gradient, in: RoundedRectangle(cornerRadius: 16))
                            VStack(alignment: .leading) {
                                Text("Convert").font(.largeTitle.bold())
                                Text("Çevrimdışı dosya dönüştürme").font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        VStack(alignment: .leading, spacing: 12) {
                            Text("1  DOSYA").font(.caption.bold()).foregroundStyle(.indigo)
                            ZStack {
                                RoundedRectangle(cornerRadius: 18).fill(.indigo.opacity(0.08))
                                if let preview {
                                    Image(uiImage: preview).resizable().scaledToFit().padding(8)
                                } else {
                                    Image(systemName: source == nil ? "doc.badge.plus" : "doc")
                                        .font(.system(size: 52)).foregroundStyle(.indigo)
                                }
                            }
                            .frame(maxWidth: .infinity).frame(height: 190)
                            Text(source == nil ? "Bir dosya seçin" : displayName)
                                .font(.headline).lineLimit(2)
                            Button { picking = true } label: {
                                Label(source == nil ? "Dosya seç" : "Dosyayı değiştir", systemImage: "folder")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered).tint(.indigo).disabled(busy)
                        }
                        .cardStyle(theme: theme, opacity: glassOpacity)

                        VStack(alignment: .leading, spacing: 14) {
                            Text("2  DÖNÜŞTÜR").font(.caption.bold()).foregroundStyle(.indigo)
                            if choices.isEmpty {
                                Text(source == nil ? "Hedefler dosya seçince görünür." : "Bu dosya iPhone'da henüz desteklenmiyor.")
                                    .foregroundStyle(.secondary)
                            } else {
                                Picker("Hedef biçim", selection: $target) {
                                    ForEach(choices, id: \.self) { Text($0.uppercased()).tag($0) }
                                }
                                .pickerStyle(.menu)
                                Button { Task { await convert() } } label: {
                                    Label("Dönüştür", systemImage: "arrow.triangle.2.circlepath")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent).tint(.indigo)
                                .disabled(busy || target.isEmpty)
                            }
                            if busy { ProgressView() }
                        }
                        .cardStyle(theme: theme, opacity: glassOpacity)

                        VStack(alignment: .leading, spacing: 12) {
                            Text(status).font(.subheadline).textSelection(.enabled)
                            if let result {
                                ShareLink(item: result) {
                                    Label("Paylaş / Dosyalara Kaydet", systemImage: "square.and.arrow.up")
                                }
                            }
                        }
                        .cardStyle(theme: theme, opacity: glassOpacity)
                    }
                    .padding(18)
                }
            }
            .navigationTitle("Convert")
            .fileImporter(isPresented: $picking, allowedContentTypes: [.item]) { response in
                do {
                    let picked = try response.get()
                    let scoped = picked.startAccessingSecurityScopedResource()
                    defer { if scoped { picked.stopAccessingSecurityScopedResource() } }
                    let tempFolder = FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString, isDirectory: true)
                    try FileManager.default.createDirectory(at: tempFolder, withIntermediateDirectories: true)
                    let local = tempFolder.appendingPathComponent(picked.lastPathComponent)
                    try FileManager.default.copyItem(at: picked, to: local)
                    source = local
                    displayName = picked.lastPathComponent
                    preview = FormatCatalog.preview(for: local)
                    target = FormatCatalog.choices(for: local).first ?? ""
                    result = nil
                    status = "Dönüştürmeye hazır"
                } catch { status = "Dosya açılamadı: \(error.localizedDescription)" }
            }
        }
        .fontDesign(.default)
        .preferredColorScheme(dark ? .dark : .light)
    }

    @MainActor private func convert() async {
        guard let source else { return }
        busy = true
        result = nil
        status = "Dönüştürülüyor…"
        do {
            let destination = try await ConversionEngine.convert(source, target: target)
            result = destination
            status = "Tamamlandı: \(destination.lastPathComponent)"
        } catch { status = "Hata: \(error.localizedDescription)" }
        busy = false
    }
}

struct SettingsView: View {
    @AppStorage("convert.maker") private var maker = ""
    @AppStorage("convert.theme") private var theme = "light"
    @AppStorage("convert.glassOpacity") private var glassOpacity = 0.65
    private let images = ["jpg/jpeg", "png", "gif", "webp", "avif", "heif/heic", "svg", "ai", "eps", "cdr", "tiff/tif", "bmp", "tga", "exr", "raw", "dng", "cr2/cr3", "nef", "arw", "psd", "xcf", "indd", "ico", "jxl", "pdf"]
    private let documents = ["pdf", "docx/doc", "xlsx/xls", "pptx/ppt", "txt", "rtf", "odt", "ods", "odp", "csv", "md", "html/htm", "xml", "epub", "mobi", "pages", "numbers", "key", "wps", "tex"]
    var body: some View {
        NavigationStack {
            Form {
                Section("Uygulama") {
                    LabeledContent("Sürüm", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.5.0")
                    TextField("Yapımcı", text: $maker, prompt: Text("Adınızı yazın"))
                }
                Section("Görünüm") {
                    Picker("Tema", selection: $theme) {
                        Text("Açık").tag("light")
                        Text("Koyu").tag("dark")
                        Text("Liquid Glass").tag("glass")
                    }
                    if theme == "glass" {
                        HStack {
                            Text("Saydamlık")
                            Slider(value: $glassOpacity, in: 0.1...1)
                            Text("\(Int(glassOpacity * 100))%")
                        }
                    }
                }
                Section("Görsel biçimleri") {
                    ForEach(images, id: \.self) { name in
                        LabeledContent(".\(name)", value: imageStatus(name))
                    }
                }
                Section("Belge biçimleri") {
                    ForEach(documents, id: \.self) { name in
                        LabeledContent(".\(name)", value: name == "pdf" ? "Görsel ↔ PDF" : "Planlandı")
                    }
                }
                Section {
                    Text("Yalnızca Dönüştür sekmesinde gösterilen hedefler çalışır. Dosyalar iPhone'da işlenir.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Ayarlar")
        }
        .fontDesign(.default)
        .preferredColorScheme(theme == "dark" ? .dark : .light)
    }

    private func imageStatus(_ name: String) -> String {
        if name == "pdf" { return "Dönüştürme" }
        if name == "heif/heic" { return "HEIC hedef / kaynak" }
        let ext = name.components(separatedBy: "/")[0]
        if FormatCatalog.writableImages.contains(ext) { return "Dönüştürme" }
        if ["webp", "svg", "jxl", "dng", "cr2", "nef", "arw", "ico", "raw"].contains(ext) { return "Kaynak / cihaza bağlı" }
        return "Planlandı"
    }
}

private extension View {
    @ViewBuilder func cardStyle(theme: String, opacity: Double) -> some View {
        let base = self.padding(18).frame(maxWidth: .infinity, alignment: .leading)
        if theme == "glass" {
            if #available(iOS 26.0, *) {
                base.background(Color.white.opacity(0.7 * (1 - opacity)), in: RoundedRectangle(cornerRadius: 23))
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 23))
            } else {
                base.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 23))
            }
        } else {
            base.background(theme == "dark" ? Color(red: 0.15, green: 0.16, blue: 0.25) : .white,
                            in: RoundedRectangle(cornerRadius: 23))
        }
    }
}

enum FormatCatalog {
    static let imageOutputTypes: [(String, String)] = [
        ("jpg", "public.jpeg"), ("png", "public.png"), ("tiff", "public.tiff"),
        ("gif", "com.compuserve.gif"), ("bmp", "com.microsoft.bmp"),
        ("heic", "public.heic"), ("avif", "public.avif")
    ]
    static var writableImages: [String] {
        let types = Set(CGImageDestinationCopyTypeIdentifiers() as! [String])
        return imageOutputTypes.filter { types.contains($0.1) }.map(\.0)
    }
    static func type(for ext: String) -> String? { imageOutputTypes.first { $0.0 == ext }?.1 }
    static func choices(for url: URL) -> [String] {
        let ext = url.pathExtension.lowercased()
        if ext == "pdf" { return writableImages }
        if ["mp4", "mov", "m4v"].contains(ext) { return ["mp4", "mov", "m4a"].filter { $0 != ext } }
        if ["mp3", "wav", "m4a", "aac"].contains(ext) { return ["m4a"].filter { $0 != ext } }
        if let source = CGImageSourceCreateWithURL(url as CFURL, nil), CGImageSourceGetCount(source) > 0 {
            return (writableImages + ["pdf"]).filter { $0 != ext && !(ext == "jpeg" && $0 == "jpg") }
        }
        return []
    }
    static func preview(for url: URL) -> UIImage? {
        if url.pathExtension.lowercased() == "pdf" {
            return PDFDocument(url: url)?.page(at: 0)?.thumbnail(of: CGSize(width: 500, height: 500), for: .mediaBox)
        }
        if let source = CGImageSourceCreateWithURL(url as CFURL, nil),
           let image = CGImageSourceCreateImageAtIndex(source, 0, nil) { return UIImage(cgImage: image) }
        if ["mp4", "mov", "m4v"].contains(url.pathExtension.lowercased()) {
            let generator = AVAssetImageGenerator(asset: AVURLAsset(url: url))
            generator.appliesPreferredTrackTransform = true
            if let frame = try? generator.copyCGImage(at: CMTime(seconds: 0.2, preferredTimescale: 600), actualTime: nil) {
                return UIImage(cgImage: frame)
            }
        }
        return nil
    }
}

enum ConversionEngine {
    enum Failure: LocalizedError {
        case unsupported, unreadable, failed
        var errorDescription: String? {
            switch self {
            case .unsupported: "Bu dönüşüm desteklenmiyor."
            case .unreadable: "Dosya okunamadı."
            case .failed: "Dönüştürme başarısız oldu."
            }
        }
    }
    static func convert(_ input: URL, target: String) async throws -> URL {
        guard FormatCatalog.choices(for: input).contains(target) else { throw Failure.unsupported }
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Convert", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let name = input.deletingPathExtension().lastPathComponent
        let output = folder.appendingPathComponent("\(name)_\(Int(Date().timeIntervalSince1970)).\(target)")
        let ext = input.pathExtension.lowercased()
        if ext == "pdf" { return try pdfToImages(input, output, target) }
        if ["mp4", "mov", "m4v", "mp3", "wav", "m4a", "aac"].contains(ext) {
            try await mediaToMedia(input, output, target)
            return output
        }
        if target == "pdf" {
            guard let source = CGImageSourceCreateWithURL(input as CFURL, nil),
                  let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
                  let page = PDFPage(image: UIImage(cgImage: image)) else { throw Failure.unreadable }
            let document = PDFDocument()
            document.insert(page, at: 0)
            guard document.write(to: output) else { throw Failure.failed }
            return output
        }
        guard let source = CGImageSourceCreateWithURL(input as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else { throw Failure.unreadable }
        try writeImage(image, output, target)
        return output
    }
    private static func writeImage(_ image: CGImage, _ output: URL, _ target: String) throws {
        guard let type = FormatCatalog.type(for: target),
              let destination = CGImageDestinationCreateWithURL(output as CFURL, type as CFString, 1, nil) else {
            throw Failure.unsupported
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw Failure.failed }
    }
    private static func pdfToImages(_ input: URL, _ output: URL, _ target: String) throws -> URL {
        guard let document = PDFDocument(url: input), document.pageCount > 0 else { throw Failure.unreadable }
        var first: URL?
        for index in 0..<document.pageCount {
            guard let page = document.page(at: index) else { throw Failure.failed }
            let size = page.bounds(for: .mediaBox).size
            let thumb = page.thumbnail(of: CGSize(width: size.width * 2, height: size.height * 2), for: .mediaBox)
            guard let image = thumb.cgImage else { throw Failure.failed }
            let stem = output.deletingPathExtension().lastPathComponent
            let file = document.pageCount == 1 ? output : output.deletingLastPathComponent()
                .appendingPathComponent("\(stem)_page_\(index + 1)").appendingPathExtension(target)
            try writeImage(image, file, target)
            if first == nil { first = file }
        }
        return first!
    }
    private static func mediaToMedia(_ input: URL, _ output: URL, _ target: String) async throws {
        let preset = target == "m4a" ? AVAssetExportPresetAppleM4A : AVAssetExportPresetHighestQuality
        guard let session = AVAssetExportSession(asset: AVURLAsset(url: input), presetName: preset) else { throw Failure.unsupported }
        session.outputURL = output
        session.outputFileType = switch target {
        case "m4a": .m4a
        case "mp4": .mp4
        case "mov": .mov
        default: throw Failure.unsupported
        }
        await session.export()
        guard session.status == .completed else { throw session.error ?? Failure.failed }
    }
}
