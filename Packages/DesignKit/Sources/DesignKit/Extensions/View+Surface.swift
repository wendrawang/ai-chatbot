//
//  View+Surface.swift
//  DesignKit
//
//  Created by Wendra on 22/10/26.
//

import SwiftUI

public extension View {
    /// Kartu standar (isi, radius, bayangan, garis tepi). Pakai ini daripada menyusun ulang di setiap view.
    /// `isOutlined: false` untuk kartu yang hanya memakai bayangan, misalnya `ActionCard`.
    func cardStyle(isOutlined: Bool = true) -> some View {
        modifier(CardStyle(isOutlined: isOutlined))
    }

    /// Bayangan standar untuk permukaan yang mengambang.
    func designShadow() -> some View {
        modifier(DesignShadow())
    }
}
