//
//  ChatViewModel+Turn.swift
//  TanyaAI
//
//  Created by Wendra on 26/10/26.
//

import Foundation

/// Kirim, tunggu jawaban, dan hentikan jawaban.
extension ChatViewModel {
    /// True bila chat mulai dikirim. Draft baru dikosongkan saat pesannya muncul di stream
    /// (`deliveredQuestionId`), jadi teks tetap ada bila kirim gagal.
    func send(_ text: String) -> Bool {
        let question = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, phase == .ready, turn == .idle, let sessionId else { return false }
        turn = .sending
        notice = nil
        turnTask = Task { [weak self, service] in
            do {
                try await service.send(question, sessionId: sessionId)
            } catch {
                self?.didFailSending()
            }
        }
        return true
    }

    /// Tombol stop: minta BE menghentikan jawaban untuk pertanyaan yang sedang ditunggu.
    func stop() {
        guard case .waiting(let questionId) = turn, let sessionId else { return }
        turn = .stopping(questionId: questionId)
        notice = nil
        turnTask = Task { [weak self, service] in
            do {
                try await service.cancel(messageId: questionId, sessionId: sessionId)
                self?.didStop(questionId)
            } catch {
                self?.didFailStopping(questionId)
            }
        }
    }

    /// Majukan giliran dari pesan yang baru masuk lewat stream.
    func advanceTurn(with message: ChatMessage) {
        switch turn {
        case .sending where message.role == .user:
            turn = .waiting(questionId: message.id)
            deliveredQuestionId = message.id
        case .waiting(let questionId), .stopping(let questionId):
            if message.role == .assistant, message.replyTo == nil || message.replyTo == questionId { turn = .idle }
        case .idle, .sending:
            break
        }
    }

    /// Setelah reconnect: jawaban yang terlewat mungkin sudah ada di history.
    func reconcileTurn() {
        switch turn {
        case .waiting(let questionId), .stopping(let questionId):
            if messages.contains(where: { $0.replyTo == questionId }) { turn = .idle }
        case .idle, .sending:
            break
        }
    }

    func didFailSending() {
        guard turn == .sending else { return }
        turn = .idle
        notice = .sendFailed
    }

    func didStop(_ questionId: String) {
        stoppedQuestions.insert(questionId)
        // Jawaban yang sempat tiba sebelum stop selesai tetap ditampilkan.
        if !messages.contains(where: { $0.replyTo == questionId }),
            let index = messages.firstIndex(where: { $0.id == questionId })
        {
            messages[index].isAnswerStopped = true
        }
        if turn == .stopping(questionId: questionId) { turn = .idle }
    }

    func didFailStopping(_ questionId: String) {
        guard turn == .stopping(questionId: questionId) else { return }
        turn = .waiting(questionId: questionId)
        notice = .stopFailed
    }
}
