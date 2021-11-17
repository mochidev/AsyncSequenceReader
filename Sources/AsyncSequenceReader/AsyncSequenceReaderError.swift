//
//  AsyncSequenceReaderError.swift
//  AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2021-11-17.
//  Copyright © 2021 Mochi Development, Inc. All rights reserved.
//

/// An Async Sequence Reader Error.
public enum AsyncSequenceReaderError: Error {
    /// Not enough elements were available to read (ie. `actual < minimum`)
    case insufficientElements(minimum: Int, actual: Int)
}
