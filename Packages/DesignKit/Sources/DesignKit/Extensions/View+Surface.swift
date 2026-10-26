//
//  View+Surface.swift
//  DesignKit
//
//  Created by Wendra on 22/10/26.
//

import SwiftUI

public extension View {
    /// Kartu standar (isi, radius, garis tepi, bayangan). Pakai ini daripada menyusun ulang di setiap view.
    func cardStyle() -> some View {
        modifier(CardStyle())
    }

    /// Bayangan standar untuk permukaan yang mengambang.
    func designShadow() -> some View {
        modifier(DesignShadow())
    }
}
