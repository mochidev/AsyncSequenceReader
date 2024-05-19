//
//  AnyReadableSequence.swift
//  AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2023-06-26.
//  Copyright © 2021-24 Mochi Development, Inc. All rights reserved.
//

/// A type-erased convenience type to normalize synchronous and asynchronous sequences into a common async type.
public struct AnyReadableSequence<Element>: AsyncSequence {
    @usableFromInline
    let makeUnderlyingIterator: @Sendable () -> () async throws -> Element?
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        @usableFromInline
        let makeUnderlyingNext: () async throws -> Element?
        
        @inlinable
        init(_ makeUnderlyingNext: @escaping () async throws -> Element?) {
            self.makeUnderlyingNext = makeUnderlyingNext
        }
        
        @inlinable
        public mutating func next() async throws -> Element? {
            try await makeUnderlyingNext()
        }
    }
    
    @inlinable
    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(makeUnderlyingIterator())
    }
    
    @inlinable
    init(_ makeUnderlyingIterator: @Sendable @escaping () -> () async throws -> Element?) {
        self.makeUnderlyingIterator = makeUnderlyingIterator
    }
    
    /// Initialize ``AnyReadableSequence`` with a sequence.
    @inlinable
    public init<S: Sequence & Sendable>(_ sequence: S) where S.Element == Element, Element: Sendable {
        self.init {
            var iterator = sequence.makeIterator()
            
            return { iterator.next() }
        }
    }
    
    /// Initialize ``AnyReadableSequence`` with an async sequence.
    @inlinable
    public init<S: AsyncSequence & Sendable>(_ sequence: S) where S.Element == Element, Element: Sendable {
        self.init {
            var iterator = sequence.makeAsyncIterator()
            
            return { try await iterator.next() }
        }
    }
}

extension AnyReadableSequence: Sendable where Element: Sendable {}
extension AnyReadableSequence.AsyncIterator: @unchecked Sendable where Element: Sendable {}
