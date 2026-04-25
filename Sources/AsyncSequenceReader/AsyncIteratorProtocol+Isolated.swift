//
//  AsyncIteratorProtocol+Isolated.swift
//  AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2026-04-26.
//  Copyright © 2021-24 Mochi Development, Inc. All rights reserved.
//

extension AsyncIteratorProtocol {
    /// Internal method for getting the next value in an isolated context.
    @usableFromInline
    mutating func _nextIsolated(_ actor: isolated (any Actor)? = #isolation) async rethrows -> Element? {
        if #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) {
            return try await self.next(isolation: actor)
        } else {
            nonisolated(unsafe) var iterator = self
            defer { self = iterator }
            #if compiler(>=6.2)
            return try await iterator.next()
            #else
            /// Swift 6.0 and Swift 6.1 require a bypass for `non-sendable result type 'Self.Element?' cannot be sent from nonisolated context in call to instance method 'next()'`
            let value = try await iterator._nextSendable()
            return value as! Element?
            #endif
        }
    }
    
    #if compiler(<6.2)
    /// Swift 6.0 and Swift 6.1 require a bypass for `non-sendable result type 'Self.Element?' cannot be sent from nonisolated context in call to instance method 'next()'`
    @usableFromInline
    mutating func _nextSendable() async rethrows -> sending Any {
        try await self.next() as Any
    }
    #endif
}
