//
//  ChatViewController.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import Combine
import DesignKit
import SwiftUI
import UIKit

@MainActor
final class ChatViewController: UIViewController
{
    let model: ChatViewModel
    let onLink: (URL) -> Void
    private let onClose: () -> Void
    let table: UITableView
    let latestButton: UIButton
    var rows: ChatTableDataSource?
    var composer: ContentSizeHostingController<Composer>?
    private var footerHeight: NSLayoutConstraint?
    var subscription: AnyCancellable?
    var previousAnchor: String?
    var previousLatest: Int
    var isFollowingLatest: Bool
    var isApplying: Bool
    var queuedState: ChatState?
    private let banner: UILabel
    private var renderedLanguage: String?
    init(model: ChatViewModel, onLink: @escaping (URL) -> Void, onClose: @escaping () -> Void)
    {
        self.model = model
        self.onLink = onLink
        self.onClose = onClose
        table = UITableView(frame: .zero, style: .plain)
        latestButton = UIButton(type: .system)
        banner = UILabel()
        previousLatest = 0
        isFollowingLatest = true
        isApplying = false
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder)
    {
        fatalError("init(coder:) is unavailable")
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor(CustomColors.background)
        configureTable()
        configureChrome()
        layoutContent()
        configureLatestButton()
        rows = ChatTableDataSource(controller: self)
        rows?.attach(to: table)
        subscription = model.$state.sink
        {
            [weak self] state in
            self?.render(state)
        }

        model.start()
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        model.pauseTransientInput()
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        resizeComposer()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
    {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory
        else
        {
            return
        }

        rows?.invalidateTypography()
        render(model.state)
    }

    private func configureTable()
    {
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = CustomSizes.estimatedRowHeight
        table.keyboardDismissMode = .interactive
        table.delegate = self
        table.alwaysBounceVertical = true
    }

    private func configureChrome()
    {
        banner.translatesAutoresizingMaskIntoConstraints = false
        banner.numberOfLines = 0
        banner.font = DesignTypography.body(traitCollection)
        banner.textAlignment = .center
        banner.backgroundColor = UIColor(CustomColors.warning)
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(closeTapped))
    }

    @objc private func closeTapped()
    {
        onClose()
    }

    private func layoutContent()
    {
        let footer = ContentSizeHostingController(rootView: makeComposer(model.state.language))
        let height = footer.view.heightAnchor.constraint(equalToConstant: CustomSizes.minimumTap)
        height.isActive = true
        footerHeight = height
        footer.onHeightChange =
        {
            [weak self] value in
            self?.footerHeight?.constant = value
        }

        composer = footer
        addChild(footer)
        footer.view.backgroundColor = .clear
        footer.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(banner)
        view.addSubview(table)
        view.addSubview(footer.view)
        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.topAnchor.constraint(equalTo: banner.bottomAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: footer.view.topAnchor),
            footer.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footer.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footer.view.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
        ])
        footer.didMove(toParent: self)
    }

    func makeComposer(_: String) -> Composer
    {
        Composer(
            copy: FeatureCopy(language: model.state.language),
            onSend:
            {
                [weak self] text in
                self?.model.send(text)
            })
    }

    private func resizeComposer()
    {
        guard let composer
        else
        {
            return
        }

        composer.view.invalidateIntrinsicContentSize()
    }

    func updateChrome(_ state: ChatState)
    {
        guard renderedLanguage != state.language
        else
        {
            return
        }

        renderedLanguage = state.language
        let copy = FeatureCopy(language: state.language)
        title = copy.title
        banner.text = copy.demo
        navigationItem.leftBarButtonItem?.accessibilityLabel = copy.close
        composer?.rootView = makeComposer(state.language)
    }
}
