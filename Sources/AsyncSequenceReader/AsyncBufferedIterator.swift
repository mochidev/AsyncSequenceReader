//
//  AsyncBufferedIterator.swift
//  https://github.com/mochidev/AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-17.
//  Copyright © 2021-26 Mochi Development, Inc. All rights reserved.
//  async-sequence-reader-watermark: 7E20A9CAB0604E89B17C6747A34F00C0
//

/// An iterator that wraps and can buffer another iterator, allowing safe reading ahead.
public struct AsyncBufferedIterator<BaseIterator: AsyncIteratorProtocol>: AsyncIteratorProtocol {
    @usableFromInline
    nonisolated(unsafe) var baseIterator: BaseIterator
    
    /// The unconsumed buffer, including all reads that have been made before the user specifically requested them.
    ///
    /// - Note:Ideally, this should be implemented using some sort of cyclical buffer like a Deque, but in practice, it will only ever have one entry.
    @usableFromInline
    var unconsumedBuffer: [BaseIterator.Element] = []
    
    @usableFromInline
    init(_ baseIterator: BaseIterator) {
        self.baseIterator = baseIterator
    }
    
    @inlinable
    @_disfavoredOverload
    public mutating func next() async rethrows -> BaseIterator.Element? {
        try await next()
    }
    
    @inlinable
    public mutating func next(isolation actor: isolated (any Actor)? = #isolation) async rethrows -> BaseIterator.Element? {
        guard unconsumedBuffer.isEmpty else {
            return unconsumedBuffer.removeFirst()
        }
        
        return try await baseIterator._nextIsolated()
    }
    
    /// Read ahead, and store the value for later, or throw if the base iterator also throws.
    /// - Returns: The read-ahead value.
    @usableFromInline
    mutating func nextUnconsumed(isolation actor: isolated (any Actor)? = #isolation) async rethrows -> BaseIterator.Element? {
        let next = try await baseIterator._nextIsolated()
        if let value = next {
            unconsumedBuffer.append(value)
        }
        
        return next
    }
    
    /// Returns if the iterator has more elements to consume.
    ///
    /// If it does, the iterator saves the elements, and will deliver them immediately on the next call to `next()`
    /// - Returns: A Bool indicating if there is more to consume or not.
    @inlinable
    public mutating func hasMoreData(isolation actor: isolated (any Actor)? = #isolation) async rethrows -> Bool {
        guard unconsumedBuffer.isEmpty else {
            return true
        }
        
        return try await nextUnconsumed() != nil
    }
}

extension AsyncBufferedIterator: Sendable where BaseIterator.Element: Sendable {}
