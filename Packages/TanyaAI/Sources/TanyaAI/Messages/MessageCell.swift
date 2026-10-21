//
//  MessageCell.swift
//  TanyaAI
//
//  Created by Wendra on 19/10/26.
//

import SwiftUI
import UIKit

/// Cell pesan: `UIHostingConfiguration` di iOS 16+, hosting controller sebagai fallback iOS 15.
@MainActor
final class MessageCell: UITableViewCell {
    static let reuseIdentifier = String(describing: MessageCell.self)
    private var fallbackHost: UIHostingController<MessageRowContent>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func show(_ content: MessageRowContent, parent: UIViewController) {
        if #available(iOS 16, *) {
            contentConfiguration = UIHostingConfiguration { content }.margins(.all, .zero)
            return
        }
        if let fallbackHost {
            fallbackHost.rootView = content
            fallbackHost.view.invalidateIntrinsicContentSize()
            return
        }
        let host = UIHostingController(rootView: content)
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false
        parent.addChild(host)
        contentView.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        host.didMove(toParent: parent)
        fallbackHost = host
    }
}
