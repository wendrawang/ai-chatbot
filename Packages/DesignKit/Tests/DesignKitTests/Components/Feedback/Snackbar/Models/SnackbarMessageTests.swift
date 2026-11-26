//
//  SnackbarMessageTests.swift
//  DesignKit
//
//  Created by Wendra on 26/11/26.
//

import Testing

@testable import DesignKit

/// Pesan yang sama berturut-turut adalah kejadian baru, supaya snackbar tampil penuh lagi.
struct SnackbarMessageTests {
    @Test
    func repeatedIdenticalMessagesAreNewEvents() {
        let first = SnackbarMessage(text: "File terlalu besar", tone: .warning)
        let second = SnackbarMessage(text: "File terlalu besar", tone: .warning)
        #expect(first != second)
        #expect(first.id != second.id)
        #expect(first.text == second.text)
        #expect(first.tone == second.tone)
    }
}
