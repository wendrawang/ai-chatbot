//
//  ScreenContent.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import SwiftUI

/// Tiruan protocol host: setiap halaman yang dibungkus `Screen` membawa view model base-nya.
@MainActor
protocol ScreenContent: View {
    associatedtype ViewModel: ScreenContentViewModel
    var viewModel: ViewModel { get }
}
