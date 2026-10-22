//
//  MessageListController.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

import DesignKit
import SwiftUI
import UIKit

/// Daftar pesan untuk ratusan chat: cell di-recycle dan hanya baris yang berubah dirender ulang.
/// Plain UIViewController (bukan UITableViewController) agar inset keyboard dimiliki SwiftUI.
@MainActor
final class MessageListController: UIViewController, UITableViewDelegate {
    enum Item: Hashable {
        case message(String)
        case replying
    }

    let tableView = UITableView(frame: .zero, style: .plain)
    var handlers: MessageHandlers?
    var onScrolledChange: ((Bool) -> Void)?
    private var dataSource: UITableViewDiffableDataSource<Int, Item>?
    private var messages: [String: ChatMessage] = [:]
    private var locale = Locale.current
    private var colors: any FigmaColorProtocol = EnvironmentValues().designColors
    private var isScrolled = false
    private var isAtBottom = true
    private var isShowingContent = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .interactive
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.accessibilityIdentifier = ChatElementIdentifier.messages
        tableView.delegate = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
        dataSource = UITableViewDiffableDataSource(tableView: tableView) { [weak self] tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifier, for: indexPath)
            guard let self, let content = self.content(for: item) else { return cell }
            (cell as? MessageCell)?.show(content, parent: self)
            return cell
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Keyboard mengubah tinggi daftar: tetap di pesan terbaru bila sebelumnya di sana.
        if isAtBottom { scrollToBottom() }
    }

    /// Terapkan pesan terbaru; baris yang sama persis tidak disentuh. History lama yang
    /// ditambahkan di atas tidak menggeser posisi baca.
    func show(_ newMessages: [ChatMessage], isReplying: Bool, locale: Locale, colors: any FigmaColorProtocol) {
        let isEnvironmentChanged =
            locale != self.locale
            || ObjectIdentifier(type(of: colors)) != ObjectIdentifier(type(of: self.colors))
        self.locale = locale
        self.colors = colors
        let existing = Set(dataSource?.snapshot().itemIdentifiers ?? [])
        let changed = newMessages.filter {
            existing.contains(.message($0.id)) && (isEnvironmentChanged || messages[$0.id] != $0)
        }
        let isPrepending = isOlderHistoryAdded(newMessages)
        let shouldFollow = isAtBottom || !isShowingContent
        let previousHeight = tableView.contentSize.height
        messages = Dictionary(uniqueKeysWithValues: newMessages.map { ($0.id, $0) })
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        snapshot.appendSections([.zero])
        snapshot.appendItems(newMessages.map { .message($0.id) } + (isReplying ? [.replying] : []))
        snapshot.reconfigureItems(changed.map { .message($0.id) })
        dataSource?.apply(snapshot, animatingDifferences: false)
        isShowingContent = !newMessages.isEmpty
        if shouldFollow {
            scrollToBottom()
        } else if isPrepending {
            tableView.layoutIfNeeded()
            tableView.contentOffset.y += tableView.contentSize.height - previousHeight
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.bounds.height > .zero else { return }
        let top = scrollView.contentOffset.y + scrollView.contentInset.top
        let remaining = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.bounds.height
        let threshold = CustomSizes.MessageList.edgeThreshold.scaledToArtwork
        isAtBottom = remaining < threshold
        if scrollView.isDragging || scrollView.isDecelerating, top < threshold { handlers?.loadOlder() }
        let nextScrolled = top > LayoutTolerance.measurement
        guard nextScrolled != isScrolled else { return }
        isScrolled = nextScrolled
        onScrolledChange?(nextScrolled)
    }
}

// MARK: - Helpers

private extension MessageListController {
    func content(for item: Item) -> MessageRowContent? {
        guard let handlers else { return nil }
        switch item {
        case .message(let id):
            guard let message = messages[id] else { return nil }
            return MessageRowContent(row: .message(message), handlers: handlers, locale: locale, colors: colors)
        case .replying:
            return MessageRowContent(row: .replying, handlers: handlers, locale: locale, colors: colors)
        }
    }

    /// True bila pesan teratas sebelumnya tidak lagi di posisi pertama (history lama masuk di atas).
    func isOlderHistoryAdded(_ newMessages: [ChatMessage]) -> Bool {
        let first = dataSource?.snapshot().itemIdentifiers.first
        guard case .message(let firstId) = first,
            let position = newMessages.firstIndex(where: { $0.id == firstId })
        else { return false }
        return position > .zero
    }

    func scrollToBottom() {
        tableView.layoutIfNeeded()
        let maximum = tableView.contentSize.height + tableView.contentInset.bottom - tableView.bounds.height
        tableView.contentOffset.y = max(-tableView.contentInset.top, maximum)
    }
}
