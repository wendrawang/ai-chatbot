//
//  MessageListController.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import DesignKit
import SwiftUI
import UIKit

/// Daftar pesan untuk ratusan chat: cell di-recycle dan hanya baris yang berubah dirender ulang.
/// Plain UIViewController (bukan UITableViewController) agar inset keyboard dimiliki SwiftUI.
@MainActor
final class MessageListController: UIViewController, UITableViewDelegate {
    private enum Section {
        case messages
    }

    let tableView = UITableView(frame: .zero, style: .plain)
    var handlers: MessageHandlers?
    var onScrollStateChange: ((_ isScrolled: Bool, _ isAtBottom: Bool) -> Void)?
    private var dataSource: UITableViewDiffableDataSource<Section, String>?
    private var messages: [String: ChatMessage] = [:]
    private var locale = Locale.current
    private var colors: any FigmaColorProtocol = EnvironmentValues().designColors
    private var isScrolled = false
    private var isAtBottom = true
    /// Pertanyaan terakhir yang ditahan dekat atas selama jawabannya mengalir.
    private var anchorId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .interactive
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
        dataSource = UITableViewDiffableDataSource(tableView: tableView) { [weak self] tableView, indexPath, id in
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifier, for: indexPath)
            guard let self, let message = self.messages[id], let handlers = self.handlers else { return cell }
            let content = MessageRowContent(
                message: message, handlers: handlers, locale: self.locale, colors: self.colors)
            (cell as? MessageCell)?.show(content, parent: self)
            return cell
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Keyboard mengubah tinggi daftar: hitung ulang ruang anchor, atau tetap di pesan terbaru.
        if anchorId != nil { updateTrailingInset() } else if isAtBottom { scrollToBottom(isAnimated: false) }
    }

    /// Terapkan pesan terbaru; baris yang sama persis tidak disentuh.
    func show(_ newMessages: [ChatMessage], locale: Locale, colors: any FigmaColorProtocol) {
        let isEnvironmentChanged =
            locale != self.locale
            || ObjectIdentifier(type(of: colors)) != ObjectIdentifier(type(of: self.colors))
        self.locale = locale
        self.colors = colors
        let existing = Set(dataSource?.snapshot().itemIdentifiers ?? [])
        let changed = newMessages.filter { existing.contains($0.id) && (isEnvironmentChanged || messages[$0.id] != $0) }
        let newQuestion = newMessages.last { $0.role == .user && !existing.contains($0.id) }
        messages = Dictionary(uniqueKeysWithValues: newMessages.map { ($0.id, $0) })
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.messages])
        snapshot.appendItems(newMessages.map(\.id))
        snapshot.reconfigureItems(changed.map(\.id))
        let shouldFollow = anchorId == nil && isAtBottom
        dataSource?.apply(snapshot, animatingDifferences: false)
        if let newQuestion {
            anchorId = newQuestion.id
            updateTrailingInset()
            scrollToAnchor()
        } else if anchorId != nil {
            updateTrailingInset()
        } else if shouldFollow {
            scrollToBottom(isAnimated: false)
        }
    }

    /// Panah "ke terbaru": lepas anchor dan ruang sementaranya, lalu ke dasar sebenarnya.
    func scrollToLatest() {
        anchorId = nil
        updateTrailingInset()
        scrollToBottom(isAnimated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.bounds.height > .zero else { return }
        let top = scrollView.contentOffset.y + scrollView.contentInset.top
        let remaining = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.bounds.height
        let nextScrolled = top > LayoutTolerance.measurement
        let nextAtBottom = remaining < CustomSizes.MessageList.followThreshold.scaledToArtwork
        guard nextScrolled != isScrolled || nextAtBottom != isAtBottom else { return }
        isScrolled = nextScrolled
        isAtBottom = nextAtBottom
        onScrollStateChange?(nextScrolled, nextAtBottom)
    }
}

// MARK: - Helpers

private extension MessageListController {
    /// Pertanyaan baru ditahan dekat atas dengan sedikit jawaban sebelumnya tetap terlihat.
    func scrollToAnchor() {
        guard let anchorTop else { return }
        let offset = max(-tableView.contentInset.top, anchorTop - tableView.contentInset.top)
        tableView.setContentOffset(CGPoint(x: .zero, y: offset), animated: true)
    }

    func scrollToBottom(isAnimated: Bool) {
        tableView.layoutIfNeeded()
        let maximum = tableView.contentSize.height + tableView.contentInset.bottom - tableView.bounds.height
        let offset = max(-tableView.contentInset.top, maximum)
        tableView.setContentOffset(CGPoint(x: .zero, y: offset), animated: isAnimated)
    }

    /// Ruang kosong sementara di bawah agar anchor bisa berada di atas walau jawaban masih
    /// pendek; mengecil sendiri saat jawaban memanjang, nol tanpa anchor.
    func updateTrailingInset() {
        guard let anchorTop else {
            tableView.contentInset.bottom = .zero
            return
        }
        let visibleHeight = tableView.bounds.height - tableView.contentInset.top
        let contentBelowAnchor = tableView.contentSize.height - anchorTop
        tableView.contentInset.bottom = max(.zero, visibleHeight - contentBelowAnchor)
    }

    var anchorTop: CGFloat? {
        guard let anchorId, let indexPath = dataSource?.indexPath(for: anchorId) else { return nil }
        tableView.layoutIfNeeded()
        let preview = CustomSizes.MessageList.previousAnswerPreview.scaledToArtwork
        return max(.zero, tableView.rectForRow(at: indexPath).minY - preview)
    }
}
