//
//  TanyaAITermsViewModel.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 26/10/26.
//

import Foundation

/// View model T&C Tanya AI di host. Bila sudah pernah disetujui, T&C tidak dimuat dan chat langsung tampil.
final class TanyaAITermsViewModel: ScreenContentViewModel {
    @Published
    private(set) var phase = TanyaAITermsPhase.loading
    @Published
    private(set) var isAccepted: Bool
    @Published
    private(set) var isAccepting = false
    private let options: SandboxOptions
    private let store: TanyaAITermsStore
    private var task: Task<Void, Never>?
    /// Dibuat saat pertama dipakai agar error service bisa diteruskan ke blocker halaman ini.
    private(set) lazy var useCase = TanyaAITermsUseCase(options: options, store: store) { [weak self] error in
        Task { @MainActor in self?.didReceiveError(error) }
    }

    init(options: SandboxOptions = .current, store: TanyaAITermsStore = TanyaAITermsStore()) {
        self.options = options
        self.store = store
        isAccepted = store.isAccepted
        super.init()
    }

    deinit {
        task?.cancel()
    }

    /// Inquiry T&C saat halaman tampil; tidak berjalan bila sudah disetujui atau sedang berjalan.
    @MainActor
    func load() {
        guard !isAccepted, task == nil else { return }
        phase = .loading
        let useCase = useCase
        task = Task { @MainActor [weak self] in
            let terms = try? await useCase.inquiry()
            self?.task = nil
            self?.phase = terms.map(TanyaAITermsPhase.loaded) ?? .failed
        }
    }

    @MainActor
    func accept() {
        guard case .loaded(let terms) = phase, !isAccepting, task == nil else { return }
        isAccepting = true
        let useCase = useCase
        task = Task { @MainActor [weak self] in
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
