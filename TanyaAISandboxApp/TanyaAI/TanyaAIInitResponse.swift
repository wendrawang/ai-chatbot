//
//  TanyaAIInitResponse.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 27/10/26.
//

import TanyaAI

/// Tiruan model response inquiry init di host. Envelope (`response_code`, dll.) milik network layer host;
/// objek `data` di-decode langsung ke `WelcomeContent` package. `isTncAgreed`/`tncCode` belum dipakai sandbox.
struct TanyaAIInitResponse: Decodable {
    let data: WelcomeContent
}
