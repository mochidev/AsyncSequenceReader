//
//  AsyncSequenceReaderErrorTests.swift
//  https://github.com/mochidev/AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2026-04-29.
//  Copyright © 2021-26 Mochi Development, Inc. All rights reserved.
//  async-sequence-reader-watermark: 7E20A9CAB0604E89B17C6747A34F00C0
//

@testable import AsyncSequenceReader
import Testing

@Suite struct AsyncSequenceReaderErrorTests {
    @Test func descriptions() async throws {
        #expect(AsyncSequenceReaderError.insufficientElements(minimum: 0, actual: 5).description == "AsyncSequenceReaderError.insufficientElements(minimum: 0, actual: 5)")
        #expect(AsyncSequenceReaderError.terminationNotFound(maximum: 0, actual: 5).description == "AsyncSequenceReaderError.terminationNotFound(maximum: 0, actual: 5)")
    }
    
    @Test func equality() async throws {
        #expect(AsyncSequenceReaderError.insufficientElements(minimum: 0, actual: 5) == AsyncSequenceReaderError.insufficientElements(minimum: 0, actual: 5))
        #expect(AsyncSequenceReaderError.insufficientElements(minimum: 0, actual: 5) != AsyncSequenceReaderError.insufficientElements(minimum: 5, actual: 5))
        #expect(AsyncSequenceReaderError.terminationNotFound(maximum: 0, actual: 5) == AsyncSequenceReaderError.terminationNotFound(maximum: 0, actual: 5))
        #expect(AsyncSequenceReaderError.terminationNotFound(maximum: 0, actual: 5) != AsyncSequenceReaderError.terminationNotFound(maximum: 5, actual: 5))
        #expect(AsyncSequenceReaderError.insufficientElements(minimum: 0, actual: 5) != AsyncSequenceReaderError.terminationNotFound(maximum: 0, actual: 5))
    }
    
    @Test func matching() async throws {
        struct LocalError: Error {}
        
        #expect(AsyncSequenceReaderError.insufficientElements(minimum: 0, actual: 5) ~= AsyncSequenceReaderError.insufficientElements(minimum: 0, actual: 5))
        #expect(!(AsyncSequenceReaderError.insufficientElements(minimum: 0, actual: 5) ~= AsyncSequenceReaderError.insufficientElements(minimum: 5, actual: 5)))
        #expect(AsyncSequenceReaderError.terminationNotFound(maximum: 0, actual: 5) ~= AsyncSequenceReaderError.terminationNotFound(maximum: 0, actual: 5))
        #expect(!(AsyncSequenceReaderError.terminationNotFound(maximum: 0, actual: 5) ~= AsyncSequenceReaderError.terminationNotFound(maximum: 5, actual: 5)))
        #expect(!(AsyncSequenceReaderError.insufficientElements(minimum: 0, actual: 5) ~= AsyncSequenceReaderError.terminationNotFound(maximum: 0, actual: 5)))
        #expect(!(AsyncSequenceReaderError.insufficientElements(minimum: 0, actual: 5) ~= LocalError()))
    }
}
