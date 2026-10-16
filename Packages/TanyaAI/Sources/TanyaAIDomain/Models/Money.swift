//
//  Money.swift
//  TanyaAIDomain
//
//  Created by Wendra on 16/10/26.
//

import Foundation

public struct Money: Equatable, Sendable
{
    public let amount: Decimal
    public let currency: String
    public init(amount: Decimal, currency: String)
    {
        self.amount = amount
        self.currency = currency
    }
}

public struct Account: Equatable, Identifiable, Sendable
{
    public let id: String
    public let name: String
    public let bank: String
    public let maskedNumber: String
    public let balance: Money?
    public init(id: String, name: String, bank: String, maskedNumber: String, balance: Money?)
    {
        self.id = id
        self.name = name
        self.bank = bank
        self.maskedNumber = maskedNumber
        self.balance = balance
    }
}
