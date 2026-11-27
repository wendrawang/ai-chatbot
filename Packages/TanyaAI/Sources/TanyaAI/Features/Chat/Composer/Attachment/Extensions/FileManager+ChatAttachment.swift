//
//  FileManager+ChatAttachment.swift
//  TanyaAI
//
//  Created by Wendra on 18/11/26.
//

import Foundation

extension FileManager {
    /// Batas ukuran satu lampiran: 10 MB desimal (keputusan user), sama dengan angka di aplikasi Files.
    static let chatAttachmentByteLimit = 10_000_000

    /// Salinan file pilihan nasabah di folder sementara aplikasi, karena file dari galeri dihapus sistem setelah
    /// callback-nya selesai. Satu folder unik per salinan, jadi nama file asli tetap dipakai tanpa bentrok. File di
    /// atas batas ditolak sebelum disalin; ukuran yang belum terbaca diperiksa lagi pada salinannya. Gagal atau
    /// ditolak = folder itu dihapus lagi, karena pemanggil tidak menerima URL untuk dibersihkan.
    func copyChatAttachment(from source: URL) throws -> URL {
        try validateChatAttachmentSize(at: source)
        let folder = temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try createDirectory(at: folder, withIntermediateDirectories: true)
        let destination = folder.appendingPathComponent(source.lastPathComponent)
        do {
            try copyItem(at: source, to: destination)
            try validateChatAttachmentSize(at: destination)
        } catch {
            try? removeItem(at: folder)
            throw error
        }
        return destination
    }

    /// Menyalin `source` di thread pemanggil, lalu meneruskan hasilnya di main queue: salinan ke `onPick`, penolakan
    /// ke `onReject`.
    /// TODO: Gagal memuat atau menyalin karena sebab lain (jarang, mis. foto iCloud tanpa koneksi) belum punya desain;
    /// sementara diabaikan.
    func deliverChatAttachmentCopy(
        of source: URL,
        onPick: @escaping (URL) -> Void,
        onReject: @escaping (ChatAttachmentRejection) -> Void
    ) {
        let result = Result { try copyChatAttachment(from: source) }
        DispatchQueue.main.async {
            switch result {
            case .success(let file):
                onPick(file)
            case .failure(let rejection as ChatAttachmentRejection):
                onReject(rejection)
            case .failure:
                return
            }
        }
    }

    /// `ChatAttachmentRejection.tooLarge` bila file melewati batas. Ukuran yang tidak terbaca dianggap lolos di sini.
    func validateChatAttachmentSize(at file: URL) throws {
        let size = (try? file.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? .zero
        guard size > Self.chatAttachmentByteLimit else { return }
        throw ChatAttachmentRejection.tooLarge
    }

    /// Memindahkan folder salinan `file` ke dalam `folder` milik pemakai, supaya salinan ikut terhapus bersama folder
    /// itu. Gagal = salinan tetap di tempat semula (folder sementara tetap dibersihkan sistem).
    func adoptChatAttachment(_ file: URL, into folder: URL) -> URL {
        let source = file.deletingLastPathComponent()
        let destination = folder.appendingPathComponent(source.lastPathComponent, isDirectory: true)
        do {
            try createDirectory(at: folder, withIntermediateDirectories: true)
            try moveItem(at: source, to: destination)
        } catch {
            return file
        }
        return destination.appendingPathComponent(file.lastPathComponent)
    }

    /// Membuang file lampiran yang tidak dipakai lagi, beserta foldernya bila menjadi kosong (folder salinan galeri
    /// atau folder salinan aplikasi Files). Gagal diabaikan: folder sementara tetap dibersihkan sistem.
    func discardChatAttachment(at file: URL) {
        try? removeItem(at: file)
        let folder = file.deletingLastPathComponent()
        guard (try? contentsOfDirectory(atPath: folder.path))?.isEmpty == true else { return }
        try? removeItem(at: folder)
    }
}
