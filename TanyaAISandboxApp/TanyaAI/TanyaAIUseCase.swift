//
//  TanyaAIUseCase.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import Foundation

/// Meniru UseCase Byon: coordinator menulis `input`, UseCase mengolahnya ke `repository`, ViewModel membaca
/// `repository`. Tanpa output karena belum ada halaman berikutnya. UseCase juga menjadi transport chat
/// (`TanyaAIUseCase+Chat`).
final class TanyaAIUseCase {
    let callback: BaseCallback
    var input = TanyaAIInput()
    private(set) var repository = TanyaAIRepository()
    let chatService: TanyaAIChatService
    private let options: SandboxOptions

    init(options: SandboxOptions = .current) {
        let callback = BaseCallback()
        self.callback = callback
        self.options = options
        chatService = TanyaAIChatService(options: options) { callback.onSubmissionFailed($0) }
    }

    /// Input dari halaman sebelumnya diolah lalu disimpan untuk ditampilkan. Sandbox: `--header-demo`
    /// mengosongkan sambutan, `--broken-icons`/`--slow-icons` mengganti URL ikon.
    func loadWelcome() {
        guard !options.isHeaderDemo, let initData = input.initData else {
            repository.initData = nil
            return
        }
        repository.initData = options.iconOverrideURL.map(initData.replacingIcons(with:)) ?? initData
    }
}
