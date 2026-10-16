//
//  HarnessRootViewController.swift
//  TanyaAIHarnessSupport
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import TanyaAIDomain
import TanyaAIFeature
import UIKit

@MainActor
public final class HarnessRootViewController: UIViewController
{
    private let history: InMemoryConversationHistoryStore
    private var session: TanyaAISession?
    private var scenario: TransferScenario
    private var language: String
    private let stack: UIStackView
    public init(arguments: [String])
    {
        history = InMemoryConversationHistoryStore()
        scenario = Self.argument("--scenario", arguments: arguments)
            .flatMap(TransferScenario.init(rawValue:)) ?? .success
        language = Self.argument("--language", arguments: arguments) ?? "id"
        stack = UIStackView()
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder)
    {
        fatalError("init(coder:) is unavailable")
    }

    override public func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor(CustomColors.background)
        stack.axis = .vertical
        stack.spacing = FigmaSize.spacingLarge
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: FigmaSize.spacingLarge),
            stack.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -FigmaSize.spacingLarge),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        renderControls()
    }

    override public func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        guard session == nil, ProcessInfo.processInfo.arguments.contains("--chat")
        else
        {
            return
        }

        startNew()
    }

    private func renderControls()
    {
        for arrangedSubview in stack.arrangedSubviews
        {
            stack.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }

        let copy = HarnessCopy(language: language)
        let banner = UILabel()
        banner.text = copy.demo
        banner.numberOfLines = 0
        banner.font = DesignTypography.heading()
        stack.addArrangedSubview(banner)
        addButton(copy.scenario, action: #selector(chooseScenario))
        addButton(copy.languageLabel, action: #selector(chooseLanguage))
        addButton(copy.newDemo, action: #selector(startNew))
        addButton(copy.resume, action: #selector(resume))
        let notice = UILabel()
        notice.text = copy.historyNotice
        notice.numberOfLines = 0
        notice.font = DesignTypography.body()
        stack.addArrangedSubview(notice)
    }

    private func addButton(_ title: String, action: Selector)
    {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = DesignTypography.body()
        button.addTarget(self, action: action, for: .touchUpInside)
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: CustomSizes.minimumTap).isActive = true
        stack.addArrangedSubview(button)
    }

    @objc private func startNew()
    {
        do
        {
            session = try TanyaAIBuilder.makeSession(
                scenario: scenario,
                identity: SessionIdentity(
                    customerID: "customer-demo",
                    sessionID: UUID().uuidString),
                language: language,
                history: history,
                onLink:
                {
                    [weak self] url in
                    self?.showDestination(url)
                },

                onClose:
                {
                    [weak self] in
                    self?.dismiss(animated: true)
                })
            resume()
        }

        catch
        {
            assertionFailure("Invalid demo configuration")
        }
    }

    @objc private func resume()
    {
        guard let session, presentedViewController == nil
        else
        {
            return
        }

        present(session.navigationController, animated: true)
    }

    @objc private func chooseScenario()
    {
        let copy = HarnessCopy(language: language)
        let alert = UIAlertController(title: copy.scenario, message: nil, preferredStyle: .actionSheet)
        for value in TransferScenario.allCases
        {
            alert.addAction(UIAlertAction(title: scenarioTitle(value, copy: copy), style: .default)
            {
                [weak self] _ in
                self?.scenario = value
            })
        }

        alert.addAction(UIAlertAction(title: copy.done, style: .cancel))
        present(alert, animated: true)
    }

    @objc private func chooseLanguage()
    {
        let copy = HarnessCopy(language: language)
        let alert = UIAlertController(title: copy.languageLabel, message: nil, preferredStyle: .actionSheet)
        for value in ["id", "en", "zh-Hans"]
        {
            alert.addAction(UIAlertAction(
                title: Locale(identifier: value).localizedString(forIdentifier: value),
                style: .default)
            {
                [weak self] _ in
                self?.language = value
                self?.session?.updateLanguage(value)
                self?.renderControls()
            })
        }

        alert.addAction(UIAlertAction(title: copy.done, style: .cancel))
        present(alert, animated: true)
    }

    private func showDestination(_ url: URL)
    {
        let copy = HarnessCopy(language: language)
        let alert = UIAlertController(title: copy.destination, message: url.absoluteString, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: copy.done, style: .default))
        (presentedViewController ?? self).present(alert, animated: true)
    }

    private func scenarioTitle(_ value: TransferScenario, copy: HarnessCopy) -> String
    {
        switch value
        {
        case .success:
            return copy.successScenario
        case .inquiryFailure:
            return copy.inquiryScenario
        case .pinRejection:
            return copy.pinScenario
        case .pending:
            return copy.pendingScenario
        case .duplicateIntent:
            return copy.duplicateScenario
        case .lateInquiry:
            return copy.lateScenario
        }
    }

    private static func argument(_ key: String, arguments: [String]) -> String?
    {
        guard let index = arguments.firstIndex(of: key), arguments.indices.contains(index + 1)
        else
        {
            return nil
        }

        return arguments[index + 1]
    }
}
