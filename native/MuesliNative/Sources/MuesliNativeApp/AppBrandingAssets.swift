import AppKit
import Foundation

enum AppBrandingAssets {
    private static let directoryName = "Branding"
    private static let logoFileName = "custom-logo.png"

    static func importLogo(from sourceURL: URL, supportDirectory: URL = AppIdentity.supportDirectoryURL) throws -> String {
        guard let image = NSImage(contentsOf: sourceURL) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw CocoaError(.fileWriteUnknown)
        }

        let directory = supportDirectory.appendingPathComponent(directoryName, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let destination = directory.appendingPathComponent(logoFileName)
        try pngData.write(to: destination, options: .atomic)
        return destination.path
    }

    static func removeLogo(at path: String?) {
        guard let path, !path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        try? FileManager.default.removeItem(atPath: path)
    }

    static func image(at path: String?) -> NSImage? {
        guard let path, !path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return NSImage(contentsOfFile: path)
    }
}
