//
//  TanyaAITermsPhase.swift
//  TanyaAISandboxApp
//
//  Created by Wendra on 27/10/26.
//

/// Status inquiry T&C.
enum TanyaAITermsPhase: Equatable {
    case loading, loaded(SandboxTerms), failed
}
