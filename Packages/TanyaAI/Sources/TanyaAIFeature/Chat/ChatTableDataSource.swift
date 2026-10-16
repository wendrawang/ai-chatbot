//
//  ChatTableDataSource.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import SwiftUI
import TanyaAIDomain
import UIKit

@MainActor
final class ChatTableDataSource
{
    private weak var controller: ChatViewController?
    private let cache: RichTextCache
    private var revisions: [String: Int]
    private var language: String?
    private var messages: [String: ChatMessage]
    private(set) var dataSource: UITableViewDiffableDataSource<Int, String>?
    init(controller: ChatViewController)
    {
        self.controller = controller
        cache = RichTextCache()
        revisions = [:]
        messages = [:]
    }

    func attach(to table: UITableView)
    {
        table.register(ChatTextCell.self, forCellReuseIdentifier: ChatTextCell.reuseIdentifier)
        table.register(
            HostingTableViewCell<TransferFlowView>.self,
            forCellReuseIdentifier: HostingTableViewCell<TransferFlowView>.reuseIdentifier)
        table.register(
            HostingTableViewCell<TransferSuggestion>.self,
            forCellReuseIdentifier: HostingTableViewCell<TransferSuggestion>.reuseIdentifier)
        dataSource = UITableViewDiffableDataSource<Int, String>(tableView: table)
        {
            [weak self] table, path, id in
            self?.cell(table, path: path, id: id) ?? UITableViewCell()
        }
    }

    func update(_ state: ChatState, completion: @escaping () -> Void)
    {
        guard let dataSource
        else
        {
            return
        }

        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(state.messages.map(\.id))
        // @Published emits in willSet. Cell providers must read the snapshot state,
        // not the model property, which can still contain the previous messages.
        messages = Dictionary(uniqueKeysWithValues: state.messages.map
        {
            ($0.id, $0)
        })
        let previous = Set(dataSource.snapshot().itemIdentifiers)
        let changed = state.messages.filter
        {
            previous.contains($0.id) && (revisions[$0.id] != $0.revision || language != state.language)
        }

        .filter
        {
            message in
            guard case .transfer = message.content
            else
            {
                return true
            }

            return language != state.language
        }

        snapshot.reloadItems(changed.map(\.id))
        revisions = Dictionary(uniqueKeysWithValues: state.messages.map
        {
            ($0.id, $0.revision)
        })
        language = state.language
        dataSource.apply(snapshot, animatingDifferences: false, completion: completion)
    }

    func invalidateTypography()
    {
        revisions.removeAll()
    }

    private func cell(_ table: UITableView, path: IndexPath, id: String) -> UITableViewCell?
    {
        guard let controller, let message = messages[id]
        else
        {
            return nil
        }

        let copy = FeatureCopy(language: language ?? controller.model.state.language)
        switch message.content
        {
        case let .user(text):
            return textCell(
                table,
                path: path,
                message: message,
                text: text,
                isUser: true,
                isFinal: true)
        case let .answer(text, isStreaming):
            return textCell(table, path: path, message: message, text: text, isUser: false, isFinal: !isStreaming)
        case .suggestion:
            let view = TransferSuggestion(
                title: copy.transfer,
                onTap:
                {
                    [weak controller] in
                    controller?.model.transferTapped()
                })
            return hosted(table, path: path, view: view, parent: controller)
        case let .transfer(snapshot):
            return transferCell(table, path: path, snapshot: snapshot, controller: controller, copy: copy)
        }
    }

    private func transferCell(
        _ table: UITableView,
        path: IndexPath,
        snapshot: TransferSnapshot,
        controller: ChatViewController,
        copy: FeatureCopy) -> UITableViewCell?
    {
        guard let model = controller.model.flows[snapshot.intent.flowID]
        else
        {
            return nil
        }

        let view = TransferFlowView(
            model: model,
            copy: copy,
            onFinished:
            {
                [weak controller] in
                controller?.model.showLatest()
            })
        return hosted(table, path: path, view: view, parent: controller)
    }

    private func textCell(
        _ table: UITableView,
        path: IndexPath,
        message: ChatMessage,
        text: String,
        isUser: Bool,
        isFinal: Bool) -> UITableViewCell
    {
        guard let cell = table.dequeueReusableCell(withIdentifier: ChatTextCell.reuseIdentifier, for: path)
            as? ChatTextCell
        else
        {
            return UITableViewCell()
        }

        let locale = Locale(identifier: language ?? "en")
        let value = attributedText(message, text: text, isUser: isUser, isFinal: isFinal, locale: locale)
        cell.configure(value, isUser: isUser)
        {
            [weak self] url in
            self?.controller?.onLink(url)
        }

        return cell
    }

    private func attributedText(
        _ message: ChatMessage,
        text: String,
        isUser: Bool,
        isFinal: Bool,
        locale: Locale) -> NSAttributedString
    {
        let font = DesignTypography.body(controller?.traitCollection)
        guard !isUser
        else
        {
            return NSAttributedString(string: text, attributes: [.font: font,
                                                                 .foregroundColor: UIColor(CustomColors.palette
                                                                     .colorsTextPrimaryLight)])
        }

        return cache.value(
            messageID: message.id,
            revision: message.revision,
            source: text,
            isFinal: isFinal,
            locale: locale,
            font: font)
    }

    private func hosted<Content: View>(
        _ table: UITableView,
        path: IndexPath,
        view: Content,
        parent: UIViewController) -> UITableViewCell
    {
        let identifier = HostingTableViewCell<Content>.reuseIdentifier
        guard let cell = table.dequeueReusableCell(withIdentifier: identifier, for: path)
            as? HostingTableViewCell<Content>
        else
        {
            return UITableViewCell()
        }

        cell.configure(rootView: view, parent: parent)
        return cell
    }
}

struct TransferSuggestion: View
{
    let title: String
    let onTap: () -> Void
    var body: some View
    {
        PrimaryButton(title, isEnabled: true, action: onTap).padding(FigmaSize.spacingLarge)
    }
}
