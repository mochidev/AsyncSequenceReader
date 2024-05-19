//
//  AsyncSequenceReaderError.swift
//  AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-17.
//  Copyright © 2021-24 Mochi Development, Inc. All rights reserved.
//

/// An Async Sequence Reader Error.
public struct AsyncSequenceReaderError: Error, Hashable, Sendable {
    enum Code: Hashable, Sendable {
        /// Not enough elements were available to read (ie. `actual < minimum`)
        case insufficientElements(minimum: Int, actual: Int)
        /// A termination was not found before the sequence ended (ie. `actual` will be less than or equal to `maximum`, indicating the amount of elements read)
        case terminationNotFound(maximum: Int, actual: Int)
    }
    
    let code: Code
    
    public var description: String {
        "AsyncSequenceReaderError.\(String(describing: code))"
    }
    
    static func ~= (lhs: Self, rhs: Error) -> Bool {
        lhs == rhs as? AsyncSequenceReaderError
    }
}

extension AsyncSequenceReaderError {
    /// Not enough elements were available to read (ie. `actual < minimum`)
    public static func insufficientElements(minimum: Int, actual: Int) -> Self {
        Self(code: .insufficientElements(minimum: minimum, actual: actual))
    }
    
    /// A termination was not found before the sequence ended (ie. `actual` will be less than or equal to `maximum`, indicating the amount of elements read)
    public static func terminationNotFound(maximum: Int, actual: Int) -> Self {
        Self(code: .terminationNotFound(maximum: maximum, actual: actual))
    }
}
