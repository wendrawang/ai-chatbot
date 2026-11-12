//
//  OptionSelectionTests.swift
//  DesignKitTests
//
//  Created by Wendra on 12/11/26.
//

import Testing

@testable import DesignKit

/// Satu pilihan langsung selesai dan mengganti pilihan lama; banyak pilihan menyalakan dan mematikan centang sampai
/// dikonfirmasi, dan hasilnya urut sesuai daftar.
struct OptionSelectionTests {
    private let items = ["a", "b", "c"].map { OptionItem(id: $0, title: $0.uppercased()) }

    @Test
    func aSingleChoiceFinishesAtOnceAndReplacesThePreviousOne() {
        var selection = OptionSelection(mode: .single, selectedIDs: ["a"])
        let isFinished = selection.toggle("c")
        #expect(isFinished)
        #expect(selection.ordered(in: items) == ["c"])
    }

    @Test
    func multipleChoicesToggleAndWaitForTheConfirmation() {
        var selection = OptionSelection(mode: .multiple, selectedIDs: ["b"])
        let isFinished = [selection.toggle("c"), selection.toggle("a"), selection.toggle("b")]
        #expect(isFinished == [false, false, false])
        #expect(selection.ordered(in: items) == ["a", "c"], "urut sesuai daftar, bukan urutan ketukan")
    }

    @Test
    func anIDMissingFromTheListIsLeftOut() {
        let selection = OptionSelection(mode: .multiple, selectedIDs: ["b", "z"])
        #expect(selection.ordered(in: items) == ["b"])
    }
}
