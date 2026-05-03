//
//  AsyncBufferedIterator.swift
//  https://github.com/mochidev/AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-17.
//  Copyright © 2021-26 Mochi Development, Inc. All rights reserved.
//  async-sequence-reader-watermark: 7E20A9CAB0604E89B17C6747A34F00C0
//

/// An iterator that wraps and can buffer another iterator, allowing safe reading ahead.
public struct AsyncBufferedIterator<
    BaseIterator: AsyncIteratorProtocol,
    Failure: Error
>: AsyncIteratorProtocol {
    @usableFromInline
    nonisolated(unsafe) var baseIterator: BaseIterator
    
    /// The unconsumed buffer, including all reads that have been made before the user specifically requested them.
    ///
    /// - Note:Ideally, this should be implemented using some sort of cyclical buffer like a Deque, but in practice, it will only ever have one entry.
    @usableFromInline
    var unconsumedBuffer: [Result<BaseIterator.Element, Failure>] = []
    
    @usableFromInline
    @_disfavoredOverload
    init(_ baseIterator: BaseIterator) {
        self.baseIterator = baseIterator
    }
    
    @usableFromInline
    @_disfavoredOverload
    init(_ baseIterator: BaseIterator) where Failure == any Error {
        self.baseIterator = baseIterator
    }
    
    @usableFromInline
    init<Element>(_ baseIterator: BaseIterator) where BaseIterator == AsyncStream<Element>.Iterator, Failure == Never {
        self.baseIterator = baseIterator
    }
    
    @usableFromInline
    init<Element>(_ baseIterator: BaseIterator) where BaseIterator == AsyncThrowingStream<Element, Failure>.Iterator {
        self.baseIterator = baseIterator
    }
    
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    @usableFromInline
    init(_ baseIterator: BaseIterator) where Failure == BaseIterator.Failure {
        self.baseIterator = baseIterator
    }
    
    @inlinable
    @_disfavoredOverload
    public mutating func next() async throws(Failure) -> BaseIterator.Element? {
        try await next()
    }
    
    @inlinable
    public mutating func next(isolation actor: isolated (any Actor)? = #isolation) async throws(Failure) -> BaseIterator.Element? {
        guard unconsumedBuffer.isEmpty else {
            return try unconsumedBuffer.removeFirst().get()
        }
        
        /// Prevent a compiler crash catching a re-throwing result by casting it first.
        /// - SeeAlso: https://github.com/swiftlang/swift/issues/88790
        func _preventCompilerCrashCacthingError(_ actor: isolated (any Actor)? = #isolation) async throws -> Element? {
            try await baseIterator._nextIsolated()
        }
        do {
            return try await _preventCompilerCrashCacthingError()
        } catch {
            throw error as! Failure
        }
    }
    
    /// Read ahead, and store the value for later, or throw if the base iterator also throws.
    /// - Returns: The read-ahead value.
    @usableFromInline
    mutating func nextUnconsumed(isolation actor: isolated (any Actor)? = #isolation) async -> Result<BaseIterator.Element, Failure>? {
        /// Prevent a compiler crash catching a re-throwing result by casting it first.
        /// - SeeAlso: https://github.com/swiftlang/swift/issues/88790
        func _preventCompilerCrashCacthingError(_ actor: isolated (any Actor)? = #isolation) async throws -> Element? {
            try await baseIterator._nextIsolated()
        }
        
        do {
            let next = try await _preventCompilerCrashCacthingError()
            if let value = next {
                unconsumedBuffer.append(.success(value))
                return .success(value)
            }
            
            return nil
        } catch {
            unconsumedBuffer.append(.failure(error as! Failure))
            return .failure(error as! Failure)
        }
    }
    
    /// Returns if the iterator has more elements to consume.
    ///
    /// If it does, the iterator saves the elements, and will deliver them immediately on the next call to `next()`
    /// - Returns: A Bool indicating if there is more to consume or not.
    @inlinable
    public mutating func hasMoreData(isolation actor: isolated (any Actor)? = #isolation) async -> Bool {
        guard unconsumedBuffer.isEmpty else {
            return true
        }
        
        return await nextUnconsumed() != nil
    }
}

extension AsyncBufferedIterator: Sendable where BaseIterator.Element: Sendable {}
