//
//  SessionContext.swift
//  TanyaAIDomain
//
//  Created by Wendra on 16/10/26.
//

import Foundation

public struct SessionIdentity: Hashable, Sendable
{
    public let customerID: String
    public let sessionID: String
    public init(customerID: String, sessionID: String)
    {
        self.customerID = customerID
        self.sessionID = sessionID
    }
}

public struct SessionContext: Sendable
{
    public let identity: SessionIdentity
    public let language: String
    public init(identity: SessionIdentity, language: String)
    {
        self.identity = identity
        self.language = language
    }
}

public struct TransferConfiguration: Sendable
{
    public let pinLength: Int
    public let noteLimit: Int
    public let minimumAmount: Decimal
    public let maximumAmount: Decimal
    public let initialAmount: Decimal?
    public let methods: [String]
    public let purposes: [String]
    public let sourceAccounts: [Account]
    public let brandName: String
    public init(
        pinLength: Int, noteLimit: Int, minimumAmount: Decimal, maximumAmount: Decimal,
        initialAmount: Decimal?, methods: [String], purposes: [String],
        sourceAccounts: [Account], brandName: String)
    {
        self.pinLength = pinLength
        self.noteLimit = noteLimit
        self.minimumAmount = minimumAmount
        self.maximumAmount = maximumAmount
        self.initialAmount = initialAmount
        self.methods = methods
        self.purposes = purposes
        self.sourceAccounts = sourceAccounts
        self.brandName = brandName
    }
}
