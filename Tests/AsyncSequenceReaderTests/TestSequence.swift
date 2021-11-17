//
//  TestSequence.swift
//  AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-16.
//  Copyright © 2021 Mochi Development, Inc. All rights reserved.
//

import Foundation
import XCTest

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

func AsyncXCTAssertEqual<T>(_ expression1: @autoclosure () async throws -> T, _ expression2: @autoclosure () async throws -> T, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) async rethrows where T : Equatable {
    let result1 = try await expression1()
    let result2 = try await expression2()
    
    XCTAssertEqual(result1, result2, message(), file: file, line: line)
}
