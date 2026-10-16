//
//  TanyaAISession.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import DesignKit
import TanyaAIDomain
import UIKit

@MainActor
public final class TanyaAISession
{
    public let navigationController: UINavigationController
    private let model: ChatViewModel
    public init(
        context: SessionContext,
        dependencies: TanyaAIDependencies,
        configuration: TransferConfiguration,
        onLink: @escaping (URL) -> Void,
        onClose: @escaping () -> Void) throws
    {
        guard configuration.pinLength > 0, configuration.noteLimit > 0,
              configuration.minimumAmount > 0, configuration.maximumAmount >= configuration.minimumAmount,
              !configuration.sourceAccounts.isEmpty, !configuration.methods.isEmpty,
              !configuration.purposes.isEmpty
        else
        {
            throw TanyaAIConfigurationError.invalidTransferConfiguration
        }

        model = ChatViewModel(context: context, dependencies: dependencies, configuration: configuration)
        let screen = ChatViewController(model: model, onLink: onLink, onClose: onClose)
        navigationController = UINavigationController(rootViewController: screen)
        navigationController.modalPresentationStyle = .fullScreen
        ScreenNavigationStyle.apply(to: navigationController)
    }

    public func updateLanguage(_ language: String)
    {
        model.updateLanguage(language)
    }
}

public enum TanyaAIConfigurationError: Error
{
    case invalidTransferConfiguration
}
