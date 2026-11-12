//
//  FormDemoModel.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 12/11/26.
//

import Combine
import DesignKit
import Foundation

/// Sandbox saja: state form contoh `--form-demo`, untuk mencoba komponen field DesignKit. Validasi hanya saat
/// Konfirmasi: semua field kosong ditandai, dan pilihan kosong paling atas langsung membuka sheet-nya. Mesin form yang
/// sebenarnya menyusul di TanyaAI. Class karena `ObservableObject` mewajibkannya.
@MainActor
final class FormDemoModel: ObservableObject {
    @Published private(set) var formatID: String?
    @Published private(set) var accountIDs: [String] = []
    @Published var address = String() {
        didSet { invalidFields.remove(.address) }
    }
    @Published var isBalanceShown = false
    @Published private(set) var invalidFields: Set<FormDemoField> = []
    @Published var sheet: FormDemoSheet?
    /// Nil = masih diambil dari "service host".
    @Published private(set) var accountOptions: [OptionItem]?

    var isHardcopy: Bool { formatID == SandboxOptions.formHardcopyID }

    func open(_ sheet: FormDemoSheet) {
        self.sheet = sheet
        guard sheet == .accounts, accountOptions == nil else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + SandboxOptions.formLoadDelay) { [weak self] in
            self?.accountOptions = SandboxOptions.formAccounts
        }
    }

    /// Field yang bergantung pada format di-reset saat tidak lagi tampil.
    func selectFormat(_ ids: [String]) {
        formatID = ids.first
        invalidFields.remove(.format)
        sheet = nil
        guard !isHardcopy else { return }
        address = String()
    }

    func selectAccounts(_ ids: [String]) {
        accountIDs = ids
        invalidFields.remove(.accounts)
        sheet = nil
    }

    func confirm() {
        let invalid = FormDemoField.allCases.filter(isInvalid)
        invalidFields = Set(invalid)
        guard let sheet = invalid.compactMap(\.sheet).first else { return }
        open(sheet)
    }
}

// MARK: - Helpers

private extension FormDemoModel {
    func isInvalid(_ field: FormDemoField) -> Bool {
        switch field {
        case .format:
            return formatID == nil
        case .accounts:
            return accountIDs.isEmpty
        case .address:
            return isHardcopy && address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}
