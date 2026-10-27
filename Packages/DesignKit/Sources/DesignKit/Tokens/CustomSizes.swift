//
//  CustomSizes.swift
//  DesignKit
//
//  Created by Wendra on 15/10/26.
//

import CoreGraphics

/// Dimensi desain (point pada artwork 375) yang belum ada di `FigmaSize`.
/// Setiap nilai di sini SELALU dipakai dengan `.scaledToArtwork`.
/// Cek `FigmaSize` dulu; minta tim desain menambah token agar nilai custom bisa dihapus.
/// Kelompok bersama dinamai per peran (`Header`, `Card`, `Shadow`); nilai milik satu komponen
/// memakai nama komponennya (`Composer`) supaya ikut terhapus bersama komponen itu.
public enum CustomSizes {
    public enum Header {
        public static let height: CGFloat = 56
    }

    public enum Card {
        public static let cornerRadius: CGFloat = 8
    }

    public enum Shadow {
        public static let radius: CGFloat = 10
        public static let offsetY: CGFloat = 2
    }

    public enum MessageList {
        /// Jarak dari tepi bawah yang masih dianggap "di pesan terbaru", dan dari tepi atas
        /// yang memicu muat history sebelumnya.
        public static let edgeThreshold: CGFloat = 48
    }

    public enum Composer {
        public static let sendButton: CGFloat = 24
        public static let sendIconInset: CGFloat = 6
        /// Kotak di tombol stop saat menunggu jawaban.
        public static let stopMark: CGFloat = 8
        public static let stopMarkRadius: CGFloat = 2
    }

    public enum LoadingDots {
        public static let dot: CGFloat = 4
        public static let spacing: CGFloat = 2
        /// Tinggi lompatan setiap titik.
        public static let bounce: CGFloat = 2
    }
}
