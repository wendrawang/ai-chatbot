//
//  TanyaAIBridge+LiveAgent.swift
//  TanyaAI
//
//  Created by Wendra on 10/11/26.
//

import Foundation

extension TanyaAIBridge {
    /// "Batalkan proses ini" selama antre. `left:true` = langsung kembali ke bot tanpa menunggu event `state`;
    /// kartu batal datang dari stream (`queue_canceled`). `left:false` = sudah tidak antre, state dari stream.
    /// 409 = agen sudah bergabung; tombol kembali aktif sampai event `state` menyembunyikannya.
    func leaveAgentQueue() async {
        guard conversationState == .agentQueued, !isLeavingAgentQueue, let conversationID else { return }
        isLeavingAgentQueue = true
        defer { isLeavingAgentQueue = false }
        do {
            let data = try await transport.leaveAgent(conversationID: conversationID)
            let result = try JSONDecoder.wire.decode(WireEnvelope<WireLeaveAgent>.self, from: data).data
            guard result.isLeft, conversationState == .agentQueued else { return }
            conversationState = .assistantActive
        } catch {
            didFailRequest(error)
        }
    }
}
