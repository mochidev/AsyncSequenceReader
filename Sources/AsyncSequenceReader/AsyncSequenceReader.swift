//
//  AsyncSequenceReader.swift
//  AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-16.
//  Copyright © 2021-24 Mochi Development, Inc. All rights reserved.
//

#if compiler(>=5.5) && canImport(_Concurrency)

/// An asynchronous sequence that will read from a mutable iterator so long as the specified condition is valid.
///
/// When finished, the iterator can be read back to read other values.
public class AsyncSequenceReader<BaseIterator: AsyncIteratorProtocol>: AsyncReadSequence {
    /// The baseIterator to read from.
    ///
    /// When finished with the sequence, callers should read back this value so they can continue iterating on the sequence.
    public var baseIterator: AsyncBufferedIterator<BaseIterator>
    
    /// The closure to call when a new value is requested.
    ///
    /// Note that implementers must **never** read from the iterator if they don't expect to forward the value. It is, however, acceptable to save the last value sent, and verify that before the next read to check if the read sequence should end early (by returning nil) or not. Ending a sequence early is completely supported, allowing more reads within a different context from occuring.
    @usableFromInline
    let read: (_ iterator: inout AsyncBufferedIterator<BaseIterator>) async throws -> Element?
    
    @usableFromInline
    init(
        _ baseIterator: AsyncBufferedIterator<BaseIterator>,
        read: @escaping (_ iterator: inout AsyncBufferedIterator<BaseIterator>) async throws -> Element?
    ) {
        self.baseIterator = baseIterator
        self.read = read
    }
}

extension AsyncSequenceReader: AsyncSequence {
    /// The type of element produced by this asynchronous sequence.
    ///
    /// The read sequence produces whatever type of element its base iterator produces.
    public typealias Element = BaseIterator.Element
    
    /// The iterator that produces elements of the read sequence.
    public struct AsyncIterator: AsyncIteratorProtocol {
        @usableFromInline
        var readSequence: AsyncSequenceReader
        
        @usableFromInline
        init(_ readSequence: AsyncSequenceReader) {
            self.readSequence = readSequence
        }
        
        /// Produces the next element in the sequence.
        ///
        /// This iterator calls `read()` with its base iterator, and lets that closure produce an appropriate result.
        @inlinable
        public mutating func next() async throws -> Element? {
            return try await readSequence.read(&readSequence.baseIterator)
        }
    }
    
    @inlinable
    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(self)
    }
}

extension AsyncSequenceReader: @unchecked Sendable where BaseIterator: Sendable, BaseIterator.Element: Sendable {}
extension AsyncSequenceReader.AsyncIterator: @unchecked Sendable where BaseIterator: Sendable, BaseIterator.Element: Sendable, Element: Sendable {}

#endif
