//
//  ServerEventName.swift
//  TanyaAI
//
//  Created by Wendra on 22/10/26.
//

/// Nama event SSE yang dikenali; event lain diabaikan.
enum ServerEventName: String {
    case message, heartbeat, error
}
