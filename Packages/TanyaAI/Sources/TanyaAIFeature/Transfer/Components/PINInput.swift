//
//  PINInput.swift
//  TanyaAIFeature
//
//  Created by Wendra on 16/10/26.
//

import Combine

/// Digit storage belongs only to this transient input object, never the flow/history.
@MainActor
final class PINInput: ObservableObject
{
    @Published private(set) var digits: [Int]
    private let length: Int
    private var isLocked: Bool
    private let onComplete: () -> Void
    init(length: Int, onComplete: @escaping () -> Void)
    {
        self.length = length
        self.onComplete = onComplete
        digits = []
        isLocked = false
    }

    func append(_ digit: Int)
    {
        guard !isLocked, digits.count < length
        else
        {
            return
        }

        digits.append(digit)
        guard digits.count == length
        else
        {
            return
        }

        digits.removeAll(keepingCapacity: false)
        isLocked = true
        onComplete()
    }

    func delete()
    {
        guard !digits.isEmpty
        else
        {
            return
        }

        digits.removeLast()
    }

    func clear()
    {
        digits.removeAll(keepingCapacity: false)
        isLocked = false
    }
}
