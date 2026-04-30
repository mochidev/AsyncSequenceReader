//
//  ExitTest.Result+Lines.swift
//  https://github.com/mochidev/AsyncSequenceReader
//
//  Created by Dimitri Bouniol on 2026-04-28.
//  Copyright © 2021-26 Mochi Development, Inc. All rights reserved.
//  async-sequence-reader-watermark: 7E20A9CAB0604E89B17C6747A34F00C0
//

import Testing

extension ExitTest.Result {
    /// All UTF8-decoded lines written to the standard error stream of the exit test before it exited.
    ///
    /// The value of this property may contain any arbitrary sequence of bytes. If you are interested in confirming the raw error content, see ``standardErrorContent`` instead.
    ///
    /// When checking the value of this property, keep in mind that the standard output stream is globally accessible, and any code running in an exit test may write to it including the operating system and any third-party dependencies you have declared in your package. Consider comparing the `.last` value of this property with [`==`](https://developer.apple.com/documentation/swift/array/==(_:_:)) in your expectation or requirement:
    ///
    /// ```swift
    /// let result = await #expect(processExitsWith: .failure, observing: [\.standardErrorContent]) {
    ///     assertionFailure("Oh no")
    /// }
    /// #expect(result?.standardErrorUTF8Lines.first == "Ohno.swift:4: Assertion failed: Oh no")
    /// ```
    ///
    /// To enable gathering output from the standard error stream during an exit test, pass `\.standardErrorContent` in the `observedValues` argument of ``expect(processExitsWith:observing:_:sourceLocation:performing:)`` or ``require(processExitsWith:observing:_:sourceLocation:performing:)``.
    ///
    /// If you did not request standard error content when running an exit test, the value of this property is the empty array.
    var standardErrorUTF8Lines: [Substring] {
        String(decoding: standardErrorContent, as: UTF8.self).split { $0.isNewline }
    }
    
    /// All UTF8-decoded lines written to the standard output stream of the exit test before it exited.
    ///
    /// The value of this property may contain any arbitrary sequence of bytes. If you are interested in confirming the raw output content, see ``standardOutputContent`` instead.
    ///
    /// When checking the value of this property, keep in mind that the standard output stream is globally accessible, and any code running in an exit test may write to it including the operating system and any third-party dependencies you have declared in your package. Consider comparing the `.last` value of this property with [`==`](https://developer.apple.com/documentation/swift/array/==(_:_:)) in your expectation or requirement:
    ///
    /// ```swift
    /// let result = await #expect(processExitsWith: .success, observing: [\.standardOutputContent]) {
    ///     print("Oh good")
    /// }
    /// #expect(result?.standardOutputUTF8Lines.last == "Oh good")
    /// ```
    ///
    /// To enable gathering output from the standard output stream during an exit test, pass `\.standardOutputContent` in the `observedValues` argument of ``expect(processExitsWith:observing:_:sourceLocation:performing:)`` or ``require(processExitsWith:observing:_:sourceLocation:performing:)``.
    ///
    /// If you did not request standard output content when running an exit test, the value of this property is the empty array.
    var standardOutputUTF8Lines: [Substring] {
        String(decoding: standardOutputContent, as: UTF8.self).split { $0.isNewline }
    }
}
