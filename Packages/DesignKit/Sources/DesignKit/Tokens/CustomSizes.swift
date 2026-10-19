//
//  CustomSizes.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import CoreGraphics

/// Dimensi desain (point pada artwork 375) yang belum ada di `FigmaSize`.
/// Setiap nilai di sini SELALU dipakai dengan `.scaledToArtwork`.
/// Cek `FigmaSize` dulu (spacing 4/8/16/32, ikon 24/36, outline 1); minta tim desain
/// menambah token agar nilai custom bisa dihapus. Nilai milik satu komponen memakai
/// nama komponennya supaya ikut terhapus bersama komponen itu.
/// Status konfirmasi setiap nilai ada di docs/FIGMA_SIZES.md.
public enum CustomSizes {
    public enum Header {
        public static let height: CGFloat = 56
    }

    public enum Shadow {
        public static let radius: CGFloat = 10
        public static let offsetY: CGFloat = 2
    }

    public enum Composer {
        public static let sendButton: CGFloat = 24
        public static let sendIconInset: CGFloat = 6
        public static let cornerRadius: CGFloat = 8
        public static let stopMark: CGFloat = 8
        public static let stopMarkRadius: CGFloat = 2
    }

    public enum Welcome {
        public static let emblem: CGFloat = 60
    }

    public enum QuickAction {
        public static let chevron: CGFloat = 20
        public static let cornerRadius: CGFloat = 8
        public static let iconTextGap: CGFloat = 12
        public static let titleGap: CGFloat = 2
    }

    public enum Bubble {
        public static let cornerRadius: CGFloat = 12
        public static let maximumWidth: CGFloat = 310
        public static let horizontalPadding: CGFloat = 12
    }

    public enum Option {
        public static let cornerRadius: CGFloat = 8
        public static let indicatorGap: CGFloat = 12
    }

    public enum Media {
        public static let width: CGFloat = 240
        public static let imageHeight: CGFloat = 137
        public static let cornerRadius: CGFloat = 8
        public static let captionPadding: CGFloat = 12
    }

    public enum Action {
        public static let pillHeight: CGFloat = 40
        public static let filledHeight: CGFloat = 48
        public static let filledCornerRadius: CGFloat = 8
        public static let icon: CGFloat = 16
    }

    public enum Status {
        public static let icon: CGFloat = 16
    }

    public enum ScrollToLatest {
        public static let button: CGFloat = 40
    }

    public enum MessageList {
        /// Jarak dari dasar daftar yang masih dianggap "di pesan terbaru" (auto-follow streaming).
        public static let followThreshold: CGFloat = 80
        /// Bagian jawaban sebelumnya yang tetap terlihat di atas pertanyaan baru.
        public static let previousAnswerPreview: CGFloat = 48
    }
}
