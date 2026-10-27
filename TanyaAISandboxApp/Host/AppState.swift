//
//  AppState.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 20/10/26.
//

import Foundation

/// Tiruan state aplikasi host. Sandbox mulai dalam keadaan login agar langsung ke main.
/// Class karena dipakai sebagai `ObservableObject`.
@MainActor
final class AppState: ObservableObject {
    @Published
    var isLoggedIn = true
}
