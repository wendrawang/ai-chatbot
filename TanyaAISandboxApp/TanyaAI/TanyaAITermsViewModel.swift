//
//  TanyaAITermsViewModel.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 26/10/26.
//

import Foundation

/// View model T&C Tanya AI di host. Bila sudah pernah disetujui, T&C tidak dimuat dan chat langsung tampil.
final class TanyaAITermsViewModel: ScreenContentViewModel {
    enum Phase: Equatable {
        case loading, loaded(SandboxTerms), failed
    }

    @Published
    private(set) var phase = Phase.loading
    @Published
    private(set) var isAccepted: Bool
    @Published
    private(set) var isAccepting = false
    let useCase: TanyaAITermsUseCase
    private var task: Task<Void, Never>?

    init(useCase: TanyaAITermsUseCase = TanyaAITermsUseCase()) {
        self.useCase = useCase
        isAccepted = useCase.store.isAccepted
        super.init()
        useCase.callback.onSubmissionFailed = { [weak self] error in self?.didReceiveError(error) }
    }

    deinit {
        task?.cancel()
    }

    /// Inquiry T&C saat halaman tampil; tidak berjalan bila sudah disetujui atau sedang berjalan.
    @MainActor
    func load() {
        guard !isAccepted, task == nil else { return }
        phase = .loading
        task = Task { @MainActor [weak self, useCase] in
            let terms = try? await useCase.inquiry()
            self?.task = nil
            self?.phase = terms.map(Phase.loaded) ?? .failed
        }
    }

    @MainActor
    func accept() {
        guard case .loaded(let terms) = phase, !isAccepting, task == nil else { return }
        isAccepting = true
        task = Task { @MainActor [weak self, useCase] in
            let isSaved = (try? await useCase.accept(terms)) != nil
            self?.task = nil
            self?.isAccepting = false
            if isSaved { self?.isAccepted = true }
        }
    }

    /// Tombol coba lagi pada blocker host juga mengulang inquiry yang gagal.
    override func retry() {
        super.retry()
        Task { @MainActor [weak self] in
            if self?.phase == .failed { self?.load() }
        }
    }
}
