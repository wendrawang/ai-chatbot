//
//  TanyaAIHost.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import SwiftUI
import UIKit

public extension View
{
    /// Mount once on the host root. Presentation is independent of NavigationLink.
    func tanyaAIHost(isPresented: Binding<Bool>, session: TanyaAISession) -> some View
    {
        background(ChatHostAnchor(isPresented: isPresented, session: session))
    }
}

private struct ChatHostAnchor: UIViewControllerRepresentable
{
    @Binding var isPresented: Bool
    let session: TanyaAISession
    func makeUIViewController(context _: Context) -> UIViewController
    {
        UIViewController()
    }

    func updateUIViewController(_ controller: UIViewController, context _: Context)
    {
        guard isPresented
        else
        {
            guard controller.presentedViewController === session.navigationController
            else
            {
                return
            }

            controller.dismiss(animated: true)
            return
        }

        presentIfReady(controller)
    }

    private func presentIfReady(_ controller: UIViewController)
    {
        guard controller.presentedViewController == nil
        else
        {
            return
        }

        guard controller.view.window != nil
        else
        {
            DispatchQueue.main.async
            {
                [weak controller] in
                guard let controller, isPresented, controller.view.window != nil,
                      controller.presentedViewController == nil
                else
                {
                    return
                }

                controller.present(session.navigationController, animated: true)
            }

            return
        }

        controller.present(session.navigationController, animated: true)
    }
}
