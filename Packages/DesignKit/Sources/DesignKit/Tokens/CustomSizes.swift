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
/// Kelompok bersama dinamai per peran (`Header`, `Shadow`); nilai milik satu komponen
/// memakai nama komponennya (`Composer`) supaya ikut terhapus bersama komponen itu.
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
    }
}
