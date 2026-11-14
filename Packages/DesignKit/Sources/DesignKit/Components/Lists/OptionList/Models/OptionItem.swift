//
//  OptionItem.swift
//  DesignKit
//
//  Created by Wendra on 12/11/26.
//

/// Satu pilihan di `OptionList`. `id` stabil dari data pemakai (mis. kode produk), `title` teks yang tampil.
public struct OptionItem: Identifiable, Equatable {
    public let id: String
    public let title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}
