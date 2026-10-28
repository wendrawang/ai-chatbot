//
//  TanyaAIInitGreeting.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 28/10/26.
//

import TanyaAI

/// `data.greetings` inquiry init: sapaan di bawah emblem.
struct TanyaAIInitGreeting: Decodable {
    let title: String
    let description: String

    var greeting: WelcomeGreeting {
        WelcomeGreeting(title: title, description: description)
    }
}
