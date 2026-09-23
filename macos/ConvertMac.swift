import SwiftUI
import AppKit
import PDFKit
import AVFoundation
import UniformTypeIdentifiers
import ImageIO

@main
struct ConvertMacApp: App {
    var body: some Scene {
        WindowGroup { RootView() }
            .windowResizability(.contentSize)
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            ConvertView()
                .tabItem { Label("Dönüştür", systemImage: "arrow.triangle.2.circlepath") }
            SettingsView()
                .tabItem { Label("Ayarlar", systemImage: "gearshape") }
        }
        .frame(width: 670, height: 730)
    }
}

struct ConvertView: View {
    @State private var source: URL?
    @State private var target = ""
    @State private var status = "Dosya seçin"
    @State private var processing = false
    @State private var output: URL?
    @State private var preview: NSImage?
    @State private var fileSize = ""
    @AppStorage("convert.theme") private var theme = "light"
    @AppStorage("convert.glassTransparency") private var glassTransparency = 0.65

    private var choices: [String] {
        guard let source else { return [] }
        return FormatCatalog.choices(for: source)
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: theme == "dark"
                           ? [Color(red: 0.08, green: 0.09, blue: 0.16),
                              Color(red: 0.14, green: 0.11, blue: 0.25)]
                           : [Color(red: 0.92, green: 0.93, blue: 1),
                              Color(red: 0.98, green: 0.96, blue: 1),
                              Color(red: 0.91, green: 0.98, blue: 1)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            if theme == "glass" {
                Circle().fill(.purple.opacity(0.24)).frame(width: 290)
                    .blur(radius: 38).offset(x: 230, y: -230)
                Circle().fill(.cyan.opacity(0.22)).frame(width: 260)
                    .blur(radius: 38).offset(x: -240, y: 230)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 14) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 28, weight: .semibold))
                            .frame(width: 58, height: 58)
                            .foregroundStyle(.white)
                            .background(Color.indigo.gradient, in: RoundedRectangle(cornerRadius: 18))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Convert").font(.system(size: 30, weight: .bold))
                            Text("Dosyalarını hızlı ve çevrimdışı dönüştür")
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Label("Cihazında", systemImage: "lock.shield")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.indigo)
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(.indigo.opacity(0.09), in: Capsule())
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Görünüm").font(.subheadline.weight(.semibold))
                            Spacer()
                            Picker("Görünüm", selection: $theme) {
                                Text("Açık").tag("light")
                                Text("Koyu").tag("dark")
                                Text("Liquid Glass").tag("glass")
                            }
                            .labelsHidden().pickerStyle(.segmented).frame(width: 350)
                        }
                        if theme == "glass" {
                            HStack {
                                Text("Saydamlık").font(.subheadline)
                                Slider(value: $glassTransparency, in: 0.1...1.0)
                                Text("\(Int(glassTransparency * 100))%")
                                    .monospacedDigit().frame(width: 42)
                            }
                        }
                    }
                    .cardStyle(theme: theme, transparency: glassTransparency)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("1  DOSYA").font(.caption.bold()).foregroundStyle(.indigo)
                        HStack(spacing: 18) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.indigo.opacity(0.07))
                                if let preview {
                                    Image(nsImage: preview).resizable().scaledToFit()
                                        .padding(8)
                                } else {
                                    Image(systemName: source == nil ? "doc.badge.plus" : iconName)
                                        .font(.system(size: 46, weight: .light))
                                        .foregroundStyle(.indigo)
                                }
                            }
                            .frame(width: 150, height: 132)
                            VStack(alignment: .leading, spacing: 8) {
                                Text(source?.lastPathComponent ?? "Bir dosya seçerek başlayın")
                                    .font(.headline).lineLimit(2)
                                Text(source == nil ? "PDF, fotoğraf, video veya ses" : fileSize)
                                    .font(.subheadline).foregroundStyle(.secondary)
                                Button { pickFile() } label: {
                                    Label(source == nil ? "Dosya seç" : "Dosyayı değiştir",
                                          systemImage: "folder")
                                }
                                .disabled(processing)
                                .buttonStyle(.bordered)
                                .tint(.indigo)
                            }
                            Spacer()
                        }
                    }
                    .cardStyle(theme: theme, transparency: glassTransparency)

                    VStack(alignment: .leading, spacing: 15) {
                        Text("2  DÖNÜŞTÜR").font(.caption.bold()).foregroundStyle(.indigo)
                        if choices.isEmpty {
                            Text(source == nil ? "Hedef biçimler dosya seçince burada görünecek."
                                               : "Bu dosya türü henüz desteklenmiyor.")
                                .foregroundStyle(.secondary)
                        } else {
                            HStack {
                                Text("Hedef biçim").font(.headline)
                                Spacer()
                                Picker("Hedef biçim", selection: $target) {
                                    ForEach(choices, id: \.self) {
                                        Text($0.uppercased()).tag($0)
                                    }
                                }
                                .labelsHidden().frame(width: 160)
                            }
                            Button { convert() } label: {
                                HStack {
                                    Spacer()
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text(processing ? "Dönüştürülüyor…" : "Dönüştür")
                                    Spacer()
                                }
                                .padding(.vertical, 7)
                            }
                            .disabled(processing || target.isEmpty)
                            .buttonStyle(.borderedProminent)
                            .tint(.indigo)
                            .controlSize(.large)
                        }
                        if processing { ProgressView() }
                    }
                    .cardStyle(theme: theme, transparency: glassTransparency)

                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: output == nil ? "info.circle" : "checkmark.circle.fill")
                            .foregroundStyle(output == nil ? .indigo : .green)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(status).textSelection(.enabled)
                            if let output {
                                Button("Finder'da Göster") {
                                    NSWorkspace.shared.activateFileViewerSelecting([output])
                                }
                            }
                        }
                        Spacer()
                    }
                    .font(.subheadline)
                    .padding(16)
                    .background(theme == "dark" ? Color.white.opacity(0.1)
                                : Color.white.opacity(theme == "glass"
                                                      ? 1 - glassTransparency * 0.75 : 0.78),
                                in: RoundedRectangle(cornerRadius: 18))

                    Text("Hedefler dosyanın türüne ve Mac'in yerel dönüştürücülerine göre gösterilir.")
                        .font(.caption).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
                .padding(28)
            }
        }
        .frame(width: 670, height: 690)
        .fontDesign(.default)
        .preferredColorScheme(theme == "dark" ? .dark : .light)
    }

    private var iconName: String {
        switch source?.pathExtension.lowercased() {
        case "pdf": "doc.richtext"
        case "mp4", "mov", "m4v": "film"
        case "mp3", "m4a", "wav", "aac", "aif", "aiff", "caf": "waveform"
        case "doc", "docx", "odt", "rtf", "txt", "html", "htm": "doc.text"
        default: "photo"
        }
    }

    private func pickFile() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK, let url = panel.url {
            source = url
            target = choices.first ?? ""
            output = nil
            preview = makePreview(url)
            let bytes = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            fileSize = ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
            status = "Dönüştürmeye hazır"
        }
    }

    private func makePreview(_ url: URL) -> NSImage? {
        switch url.pathExtension.lowercased() {
        case "pdf":
            return PDFDocument(url: url)?.page(at: 0)?
                .thumbnail(of: NSSize(width: 440, height: 330), for: .mediaBox)
        case "mp4", "mov", "m4v":
            let generator = AVAssetImageGenerator(asset: AVURLAsset(url: url))
            generator.appliesPreferredTrackTransform = true
            if let image = try? generator.copyCGImage(at: CMTime(seconds: 0.2,
                                                                   preferredTimescale: 600),
                                                       actualTime: nil) {
                return NSImage(cgImage: image, size: .zero)
            }
            return nil
        default:
            guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
                  let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }
            return NSImage(cgImage: image, size: .zero)
        }
    }

    private func convert() {
        guard let source else { return }
        let chosen = target
        let panel = NSSavePanel()
        panel.title = "Dönüştürülen dosyayı kaydet"
        panel.nameFieldStringValue = "\(source.deletingPathExtension().lastPathComponent)_converted.\(chosen)"
        panel.directoryURL = FileManager.default.urls(for: .downloadsDirectory,
                                                      in: .userDomainMask).first
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let destination = panel.url else { return }
        processing = true
        output = nil
        status = "İşleniyor…"
        Task {
            do {
                let result = try await Converter.convert(source, to: destination, format: chosen)
                output = result
                status = "Tamamlandı: \(result.path)"
            } catch {
                status = "Hata: \(error.localizedDescription)"
            }
            processing = false
        }
    }
}

private struct FormatEntry: Identifiable {
    let name: String
    let status: String
    let color: Color
    var id: String { name }
}

struct SettingsView: View {
    @AppStorage("convert.maker") private var maker = ""
    @AppStorage("convert.theme") private var theme = "light"
    @AppStorage("convert.glassTransparency") private var glassTransparency = 0.65
    @State private var showImages = true
    @State private var showDocuments = false

    private let images: [FormatEntry] = [
        .init(name: ".jpg / .jpeg", status: "Dönüştürme", color: .green),
        .init(name: ".png", status: "Dönüştürme", color: .green),
        .init(name: ".gif", status: "İlk kare", color: .orange),
        .init(name: ".webp", status: "Kaynak", color: .blue),
        .init(name: ".avif", status: "Dönüştürme", color: .green),
        .init(name: ".heif / .heic", status: "Kısmi", color: .orange),
        .init(name: ".svg", status: "Mac'e bağlı", color: .orange),
        .init(name: ".ai", status: "Planlandı", color: .secondary),
        .init(name: ".eps", status: "Planlandı", color: .secondary),
        .init(name: ".cdr", status: "Planlandı", color: .secondary),
        .init(name: ".tiff / .tif", status: "Dönüştürme", color: .green),
        .init(name: ".bmp", status: "Dönüştürme", color: .green),
        .init(name: ".tga", status: "Dönüştürme", color: .green),
        .init(name: ".exr", status: "Dönüştürme", color: .green),
        .init(name: ".raw", status: "Kamera bağlı", color: .orange),
        .init(name: ".dng", status: "Kamera bağlı", color: .orange),
        .init(name: ".cr2 / .cr3", status: "Kamera bağlı", color: .orange),
        .init(name: ".nef", status: "Kamera bağlı", color: .orange),
        .init(name: ".arw", status: "Kamera bağlı", color: .orange),
        .init(name: ".psd", status: "Düzleştirilmiş", color: .orange),
        .init(name: ".xcf", status: "Planlandı", color: .secondary),
        .init(name: ".indd", status: "Planlandı", color: .secondary),
        .init(name: ".ico", status: "Kaynak", color: .blue),
        .init(name: ".jxl", status: "Kaynak", color: .blue),
        .init(name: ".pdf", status: "Dönüştürme", color: .green),
    ]

    private let documents: [FormatEntry] = [
        .init(name: ".pdf", status: "Görsel ↔ PDF", color: .orange),
        .init(name: ".docx / .doc", status: "Dönüştürme", color: .green),
        .init(name: ".xlsx / .xls", status: "Planlandı", color: .secondary),
        .init(name: ".pptx / .ppt", status: "Planlandı", color: .secondary),
        .init(name: ".txt", status: "Dönüştürme", color: .green),
        .init(name: ".rtf", status: "Dönüştürme", color: .green),
        .init(name: ".odt", status: "Dönüştürme", color: .green),
        .init(name: ".ods", status: "Planlandı", color: .secondary),
        .init(name: ".odp", status: "Planlandı", color: .secondary),
        .init(name: ".csv", status: "Planlandı", color: .secondary),
        .init(name: ".md", status: "Planlandı", color: .secondary),
        .init(name: ".html / .htm", status: "Dönüştürme", color: .green),
        .init(name: ".xml", status: "Planlandı", color: .secondary),
        .init(name: ".epub", status: "Planlandı", color: .secondary),
        .init(name: ".mobi", status: "Planlandı", color: .secondary),
        .init(name: ".pages", status: "Planlandı", color: .secondary),
        .init(name: ".numbers", status: "Planlandı", color: .secondary),
        .init(name: ".key", status: "Planlandı", color: .secondary),
        .init(name: ".wps", status: "Planlandı", color: .secondary),
        .init(name: ".tex", status: "Planlandı", color: .secondary),
    ]

    var body: some View {
        ZStack {
            LinearGradient(colors: theme == "dark"
                           ? [Color(red: 0.08, green: 0.09, blue: 0.16),
                              Color(red: 0.14, green: 0.11, blue: 0.25)]
                           : [Color(red: 0.94, green: 0.94, blue: 1),
                              Color(red: 0.91, green: 0.98, blue: 1)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        Image(systemName: "gearshape.fill")
                            .font(.title).foregroundStyle(.white)
                            .frame(width: 54, height: 54)
                            .background(Color.indigo.gradient,
                                        in: RoundedRectangle(cornerRadius: 17))
                        VStack(alignment: .leading) {
                            Text("Ayarlar").font(.largeTitle.bold())
                            Text("Uygulama bilgileri ve biçim kapsamı")
                                .foregroundStyle(.secondary)
                        }
                    }
                    VStack(alignment: .leading, spacing: 14) {
                        Text("UYGULAMA").font(.caption.bold()).foregroundStyle(.indigo)
                        LabeledContent("Sürüm", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.5.0")
                        HStack {
                            Text("Yapımcı")
                            Spacer()
                            TextField("Adınızı yazın", text: $maker)
                                .textFieldStyle(.roundedBorder).frame(width: 250)
                        }
                        Text("Yapımcı adı bu Mac'te saklanır.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .cardStyle(theme: theme, transparency: glassTransparency)

                    Text("Dönüştürme ekranı yalnızca çalışan hedefleri listeler. ‘Kaynak’ ve ‘Mac'e bağlı’ işaretleri hedef biçim üretildiği anlamına gelmez.")
                        .font(.subheadline)
                        .padding(14)
                        .background(Color.indigo.opacity(0.09),
                                    in: RoundedRectangle(cornerRadius: 14))

                    DisclosureGroup(isExpanded: $showImages) {
                        formatList(images)
                    } label: {
                        Label("Görsel biçimleri (25)", systemImage: "photo")
                            .font(.headline)
                    }
                    .cardStyle(theme: theme, transparency: glassTransparency)

                    DisclosureGroup(isExpanded: $showDocuments) {
                        formatList(documents)
                    } label: {
                        Label("Belge biçimleri (20)", systemImage: "doc.text")
                            .font(.headline)
                    }
                    .cardStyle(theme: theme, transparency: glassTransparency)
                }
                .padding(28)
            }
        }
        .fontDesign(.default)
        .preferredColorScheme(theme == "dark" ? .dark : .light)
    }

    private func formatList(_ entries: [FormatEntry]) -> some View {
        LazyVStack(spacing: 0) {
            ForEach(entries) { entry in
                HStack {
                    Text(entry.name).font(.subheadline.monospaced())
                    Spacer()
                    Text(entry.status)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(entry.color)
                        .padding(.horizontal, 9).padding(.vertical, 5)
                        .background(entry.color.opacity(0.12), in: Capsule())
                }
                .padding(.vertical, 6)
                Divider()
            }
        }
        .padding(.top, 12)
    }
}

private extension View {
    @ViewBuilder
    func cardStyle(theme: String, transparency: Double) -> some View {
        let base = self.padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        if theme == "glass" {
            if #available(macOS 26.0, *) {
                base.background(Color.white.opacity(0.7 * (1 - transparency)),
                                in: RoundedRectangle(cornerRadius: 24))
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24))
            } else {
                base.background(Color.white.opacity(0.7 * (1 - transparency)),
                                in: RoundedRectangle(cornerRadius: 24))
                    .background(.ultraThinMaterial,
                                in: RoundedRectangle(cornerRadius: 24))
            }
        } else {
            base.background(theme == "dark"
                            ? Color(red: 0.14, green: 0.16, blue: 0.25)
                            : Color.white,
                            in: RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.indigo.opacity(0.08), lineWidth: 1))
                .shadow(color: Color.indigo.opacity(0.08), radius: 18, y: 7)
        }
    }
}

enum FormatCatalog {
    static let imageOutputs: [(String, String)] = [
        ("jpg", "public.jpeg"), ("png", "public.png"),
        ("tiff", "public.tiff"), ("gif", "com.compuserve.gif"),
        ("bmp", "com.microsoft.bmp"), ("heic", "public.heic"),
        ("avif", "public.avif"), ("jp2", "public.jpeg-2000"),
        ("psd", "com.adobe.photoshop-image"),
        ("exr", "com.ilm.openexr-image"), ("tga", "com.truevision.tga-image")
    ]
    static let documentFormats = ["txt", "rtf", "html", "doc", "docx", "odt", "wordml", "webarchive"]
    static let audioInputs: Set<String> = ["mp3", "wav", "m4a", "aac", "aif", "aiff", "caf"]
    static let videoInputs: Set<String> = ["mp4", "mov", "m4v"]

    static var writableImages: [String] {
        let available = Set(CGImageDestinationCopyTypeIdentifiers() as! [String])
        return imageOutputs.filter { available.contains($0.1) }.map(\.0)
    }

    static func imageType(_ ext: String) -> String? {
        imageOutputs.first { $0.0 == ext }?.1
    }

    static func choices(for url: URL) -> [String] {
        let ext = url.pathExtension.lowercased()
        if ext == "pdf" { return writableImages }
        if documentFormats.contains(ext) || ext == "htm" {
            return documentFormats.filter { $0 != ext && !(ext == "htm" && $0 == "html") }
        }
        if videoInputs.contains(ext) {
            return ["mp4", "mov", "m4a", "wav", "aiff", "caf"].filter { $0 != ext }
        }
        if audioInputs.contains(ext) {
            return ["m4a", "wav", "aiff", "caf"].filter { $0 != ext }
        }
        if let source = CGImageSourceCreateWithURL(url as CFURL, nil),
           CGImageSourceGetCount(source) > 0 {
            return (writableImages + ["pdf"]).filter { $0 != ext && !(ext == "jpeg" && $0 == "jpg") }
        }
        return []
    }
}

enum Converter {
    enum Failure: LocalizedError {
        case unreadable, unsupported, failed
        var errorDescription: String? {
            switch self {
            case .unreadable: "Dosya açılamadı."
            case .unsupported: "Bu dönüşüm desteklenmiyor."
            case .failed: "Dönüştürme başarısız oldu."
            }
        }
    }

    static func convert(_ input: URL, to output: URL, format: String) async throws -> URL {
        let ext = input.pathExtension.lowercased()
        guard FormatCatalog.choices(for: input).contains(format) else { throw Failure.unsupported }
        if input.standardizedFileURL == output.standardizedFileURL { throw Failure.unsupported }
        if FileManager.default.fileExists(atPath: output.path) {
            try FileManager.default.removeItem(at: output)
        }
        if ext == "pdf" { return try pdfToImages(input, output, format) }
        if FormatCatalog.documentFormats.contains(ext) || ext == "htm" {
            try documentToDocument(input, output, format)
            return output
        }
        if FormatCatalog.audioInputs.contains(ext) || FormatCatalog.videoInputs.contains(ext) {
            if ["wav", "aiff", "caf"].contains(format) {
                try await audioToAudio(input, output, format)
            } else {
                try await mediaToMedia(input, output, format)
            }
            return output
        }
        if let source = CGImageSourceCreateWithURL(input as CFURL, nil),
           CGImageSourceGetCount(source) > 0 {
            if format == "pdf" { try imageToPdf(input, output) }
            else { try imageToImage(input, output, format) }
            return output
        }
        throw Failure.unsupported
    }

    private static func imageToImage(_ input: URL, _ output: URL, _ format: String) throws {
        guard let source = CGImageSourceCreateWithURL(input as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw Failure.unreadable
        }
        try writeImage(image, to: output, format: format)
    }

    private static func writeImage(_ image: CGImage, to output: URL, format: String) throws {
        guard let type = FormatCatalog.imageType(format),
              let destination = CGImageDestinationCreateWithURL(output as CFURL,
                                                                 type as CFString, 1, nil) else {
            throw Failure.unsupported
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { throw Failure.failed }
    }

    private static func imageToPdf(_ input: URL, _ output: URL) throws {
        guard let source = CGImageSourceCreateWithURL(input as CFURL, nil),
              let bitmap = CGImageSourceCreateImageAtIndex(source, 0, nil),
              let page = PDFPage(image: NSImage(cgImage: bitmap, size: .zero)) else {
            throw Failure.unreadable
        }
        let document = PDFDocument()
        document.insert(page, at: 0)
        guard document.write(to: output) else { throw Failure.failed }
    }

    private static func pdfToImages(_ input: URL, _ output: URL, _ format: String) throws -> URL {
        guard let document = PDFDocument(url: input), document.pageCount > 0 else {
            throw Failure.unreadable
        }
        var firstOutput: URL?
        for index in 0..<document.pageCount {
            guard let page = document.page(at: index) else { throw Failure.failed }
            let bounds = page.bounds(for: .mediaBox)
            let image = page.thumbnail(of: NSSize(width: bounds.width * 2,
                                                  height: bounds.height * 2), for: .mediaBox)
            guard let bitmap = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                throw Failure.failed
            }
            let file = document.pageCount == 1 ? output : output.deletingPathExtension()
                .appendingPathComponent("_page_\(index + 1)")
                .appendingPathExtension(format)
            try writeImage(bitmap, to: file, format: format)
            if firstOutput == nil { firstOutput = file }
        }
        return firstOutput!
    }

    private static func documentToDocument(_ input: URL, _ output: URL, _ format: String) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/textutil")
        process.arguments = ["-convert", format, "-output", output.path, input.path]
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0,
              FileManager.default.fileExists(atPath: output.path) else { throw Failure.failed }
    }

    private static func audioToAudio(_ input: URL, _ output: URL, _ format: String) async throws {
        var audioInput = input
        var temporary: URL?
        if FormatCatalog.videoInputs.contains(input.pathExtension.lowercased()) {
            temporary = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString).appendingPathExtension("m4a")
            try await mediaToMedia(input, temporary!, "m4a")
            audioInput = temporary!
        }
        defer { if let temporary { try? FileManager.default.removeItem(at: temporary) } }
        let fileType: String
        let dataType: String
        switch format {
        case "wav": fileType = "WAVE"; dataType = "LEI16"
        case "aiff": fileType = "AIFF"; dataType = "BEI16"
        case "caf": fileType = "caff"; dataType = "LEI16"
        default: throw Failure.unsupported
        }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/afconvert")
        process.arguments = ["-f", fileType, "-d", dataType, audioInput.path, output.path]
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0,
              FileManager.default.fileExists(atPath: output.path) else { throw Failure.failed }
    }

    private static func mediaToMedia(_ input: URL, _ output: URL, _ format: String) async throws {
        let asset = AVURLAsset(url: input)
        let preset = format == "m4a" ? AVAssetExportPresetAppleM4A : AVAssetExportPresetHighestQuality
        guard let session = AVAssetExportSession(asset: asset, presetName: preset) else {
            throw Failure.unsupported
        }
        session.outputURL = output
        session.outputFileType = switch format {
        case "m4a": .m4a
        case "mp4": .mp4
        case "mov": .mov
        default: throw Failure.unsupported
        }
        await session.export()
        guard session.status == .completed else { throw session.error ?? Failure.failed }
    }
}
