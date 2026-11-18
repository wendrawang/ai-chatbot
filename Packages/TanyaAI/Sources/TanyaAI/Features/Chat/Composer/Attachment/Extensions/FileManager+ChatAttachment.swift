//
//  FileManager+ChatAttachment.swift
//  TanyaAI
//
//  Created by Wendra on 18/11/26.
//

import Foundation

extension FileManager {
    /// Salinan file pilihan nasabah di folder sementara aplikasi, karena file dari galeri dihapus sistem setelah
    /// callback-nya selesai. Satu folder unik per salinan, jadi nama file asli tetap dipakai tanpa bentrok.
    func copyChatAttachment(from source: URL) throws -> URL {
        let folder = temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try createDirectory(at: folder, withIntermediateDirectories: true)
        let destination = folder.appendingPathComponent(source.lastPathComponent)
        try copyItem(at: source, to: destination)
        return destination
    }
}
