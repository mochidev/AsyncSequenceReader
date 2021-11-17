//
//  TestSequence.swift
//  AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-16.
//  Copyright © 2021 Mochi Development, Inc. All rights reserved.
//

import Foundation

struct TestSequence<Base>: AsyncSequence where Base: Sequence {
    typealias Element = Base.Element
    
    var base: Base
    
    struct AsyncIterator: AsyncIteratorProtocol {
        var baseIterator: Base.Iterator
        
        mutating func next() async -> Base.Iterator.Element? {
            baseIterator.next()
        }
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(baseIterator: base.makeIterator())
    }
}

struct ThrowingTestSequence<Base>: AsyncSequence where Base: Sequence {
    typealias Element = Base.Element
    
    var base: Base
    
    struct AsyncIterator: AsyncIteratorProtocol {
        var baseIterator: Base.Iterator
        
        mutating func next() async throws -> Base.Iterator.Element? {
            baseIterator.next()
        }
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(baseIterator: base.makeIterator())
    }
}
