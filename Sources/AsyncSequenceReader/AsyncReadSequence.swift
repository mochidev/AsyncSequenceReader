//
//  AsyncReadSequence.swift
//  AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-17.
//  Copyright © 2021-24 Mochi Development, Inc. All rights reserved.
//

#if compiler(>=5.5) && canImport(_Concurrency)

/// An AsyncSequence subtype suitable for reading an existing iterator in place.
///
/// Note that to conform to this protocol, your type must be a reference type. After iterating, you'll also likely want to copy the base iterator back into your starting iterator, as shown in ``AsyncIteratorProtocol/transform(with:readSequenceFactory:)``.
public protocol AsyncReadSequence: AsyncSequence, AnyObject {
    associatedtype BaseIterator: AsyncIteratorProtocol where BaseIterator.Element == Element
    
    @inlinable
    var baseIterator: AsyncBufferedIterator<BaseIterator> { get }
}

extension AsyncIteratorProtocol {
    /// Transform the receiving iterator using the specified sequence transformer and configured read sequence.
    ///
    /// - Note: Iterating over the read sequence multiple times will result in undefined behavior.
    ///
    /// - Parameter sequenceTransform: A transformation that accepts a sequence that can be read from, or stopped prematurely by returning `nil`. The receiving iterator will have moved forward by the same amount of items consumed within `sequenceTransform`.
    /// - Parameter readSequenceFactory: A factory to create a suitable ``AsyncReadSequence`` that will determine the logical bounds of the transformation within the receiving iterator.
    /// - Returns: A transformed value read from the iterator, or `nil` if there were no values left to read.
    public mutating func transform<Transformed, ReadSequence: AsyncReadSequence>(
        with sequenceTransform: (ReadSequence) async throws -> Transformed,
        readSequenceFactory: (inout AsyncBufferedIterator<Self>) -> ReadSequence
    ) async throws -> Transformed? where ReadSequence.BaseIterator == Self {
        var results: Transformed? = nil
        var wrappedIterator = AsyncBufferedIterator(self)
        if try await wrappedIterator.hasMoreData() {
            let readSequence = readSequenceFactory(&wrappedIterator)
            results = try await sequenceTransform(readSequence)
            wrappedIterator = readSequence.baseIterator
        }
        self = wrappedIterator.baseIterator
        
        return results
    }
}

extension AsyncBufferedIterator {
    /// Transform the receiving iterator using the specified sequence transformer and configured read sequence.
    ///
    /// - Note: Iterating over the read sequence multiple times will result in undefined behavior.
    ///  
    /// - Parameter sequenceTransform: A transformation that accepts a sequence that can be read from, or stopped prematurely by returning `nil`. The receiving iterator will have moved forward by the same amount of items consumed within `sequenceTransform`.
    /// - Parameter readSequenceFactory: A factory to create a suitable ``AsyncReadSequence`` that will determine the logical bounds of the transformation within the receiving iterator.
    /// - Returns: A transformed value read from the iterator, or `nil` if there were no values left to read.
    public mutating func transform<Transformed, ReadSequence: AsyncReadSequence>(
        with sequenceTransform: (ReadSequence) async throws -> Transformed,
        readSequenceFactory: (inout Self) -> ReadSequence
    ) async throws -> Transformed? where ReadSequence.BaseIterator == BaseIterator {
        
        var results: Transformed? = nil
        if try await self.hasMoreData() {
            let readSequence = readSequenceFactory(&self)
            results = try await sequenceTransform(readSequence)
            self = readSequence.baseIterator
        }
        
        return results
    }
}

#endif
