# AsyncSequenceReader

<p align="center">
<a href="https://swiftpackageindex.com/mochidev/AsyncSequenceReader">
<img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmochidev%2FAsyncSequenceReader%2Fbadge%3Ftype%3Dswift-versions" />
</a>
<a href="https://swiftpackageindex.com/mochidev/AsyncSequenceReader">
<img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmochidev%2FAsyncSequenceReader%2Fbadge%3Ftype%3Dplatforms" />
</a>
<a href="https://github.com/mochidev/AsyncSequenceReader/actions?query=workflow%3A%22Test+AsyncSequenceReader%22">
<img src="https://github.com/mochidev/AsyncSequenceReader/workflows/Test%20AsyncSequenceReader/badge.svg" alt="Test Status" />
</a>
</p>

`AsyncSequenceReader` provides building blocks to easily consume Swift's `AsyncSequence`.

## Installation

Add `AsyncSequenceReader` as a dependency in your `Package.swift` file to start using it. Then, add `import AsyncSequenceReader` to any file you wish to use the library in.

Please check the [releases](https://github.com/mochidev/AsyncSequenceReader/releases) for recommended versions.

```swift
dependencies: [
    .package(url: "https://github.com/mochidev/AsyncSequenceReader.git", .upToNextMinor(from: "0.1.0")),
],
...
targets: [
    .target(
        name: "MyPackage",
        dependencies: [
            "AsyncSequenceReader",
        ]
    )
]
```

## What is `AsyncSequenceReader`?

`AsyncSequenceReader` is a collection of building blocks to make it easy to read information and transform `AsyncSequence` into data types your app understands.

Although an `AsyncSequence` can be consumed via a `for await` loop, that isn't often the easiest way of consuming that data:

```swift

for await byte in url.resourceBytes {
    // Buffer enough bytes to read an int
    // Buffer the amount of bytes specified by the int to read a frame
    // Repeat until all frames are consumed...
}

```

If the serialization format is more complicated than that, it can be significantly harder to write easy to read and understandable code that can be easily maintained.

`AsyncSequenceReader` provides 3 primary tools to help you with this: Iterator Maps, Counted Collections, and Terminated Collections.

### Iterator Maps

The most basic building block this package provides is called an **Iterator Map**. Iterator maps allow you a way of reading a sequence a value at a time without worrying about buffering or state management. Additionally, they allow you to return complete objects as you build them, letting other parts of your app consume those objects as they become available!

Let's build an iterator map:

```swift
struct DataFrame {
    var command: String
    var payload: [UInt8]
}

let url = ...
let sequence = url.resourceBytes

let results = sequence.iteratorMap { iterator -> DataFrame? in
    /// Reads go here
}

// Do something with the results:
for await dataFrame in results {
    print(dataFrame)
}
```

Within the closure, you can do one of three things:
- Read values and return an object (In this case a DataFrame),
- Throw and error, cancelling the whole process,
- Return `nil`, indicating the end of the sequence.

Reading values is as easy as calling `let value = try await iterator.next()`. This value will match the type of the sequence, which is `UInt8` in the above example. If the value is nil, you've reached the end of the sequence. We'll take a look at other ways to read values momentarily.

Note: Resist the urge to catch errors within an iterator map, as once a value is read, it will no longer be available.

Returning an object will make it available to whoever is consuming the resulting sequence, preparing your closure to be called again for the next object. Do note that Your closure will not be called unless something consumes your `results` sequence, either via `for await`, or by using `.reduce` or other `AsyncSequence` methods.

Note: Do not copy the iterator to other methods without marking it as `inout`, since as a value type, a copy will be made, and further reads may become out of sync.

### Counted Collections

Reading values in an iterator map one at a time is useful, but often times we need to buffer larger amounts of data. There are several ways we can do that:

```swift
var fourByteSequence = try await iterator.collect(4) // [UInt8, UInt8, UInt8, UInt8]?
var largeSequence = try await iterator.collect(max: 256) // Array of [UInt8]? with a max size of 256, but may be shorter if the sequence had less than 256 characters available.
var limitedSequence = try await iterator.collect(min: 128, max: 256) // Array of [UInt8]? that will throw if at least 128 bytes are available, but will be no larger than 256.
```

For that last example, do note that the `limitedSequence` will only become available if and when all the bytes have been read. ie. you will not get results back if only 128 bytes are available _right now_, if the sequence is still ongoing.

If the minimum number of bytes cannot be collected, an `AsyncSequenceReaderError.insufficientElements` error will be thrown.

You can also collect elements into another async sequence using a **sequence transform**:

```swift
var veryLargeSequence = try await iterator.collect(1024*1024*1024) { sequence -> Summary in
    let results = sequence.iteratorMap { iterator -> DataFrame? in
        guard let values = try await iterator.collect(count: 1024*1024) else { return nil }
        
        return DataFrame(values)
    }
    
    let averages = tray await results.reduce(into: []) { $0.append($1.average) }
    return Summary(averages)
}
```

In the above example, our sequence transform gives us access to a sequence that will be at most `1024*1024*1024` bytes large, which is 1 GB! However, instead of accumulating that data into an array, we get a sequence back, which we can attach an iterator map to so we can process the data 1 MB at a time, combining that data into a `DataFrame` type. When, we can consume this transformed sequence, reducing it to calculate averages for each data frame, and storing those averages in a `Summary` object.

Note that this whole time, no more than around 1 MB of memory will be used at a time, because it'll only actually be consumes while reducing the results, which will only read 1 MB of data at a time, and will stop once a total of 1 GB of data has been read.

### Terminated Collections

Terminated collections actually work just like counted collections, but they read until a certain element (or sequence of elements) is encountered:

```swift
var nullTerminatedString = try await iterator.collect(upToIncluding: 0, throwsIfOver: 1024) // [UInt8]?, ending in `\0`
var httpHeaderEntry = try await iterator.collect(upToExcluding: ["\r".asciiValue, "\n".asciiValue], throwsIfOver: 1024) // [UInt8]?, without the `\r\n`
```

This is especially useful when scanning for strings or other known boundaries, allowing you get get an array of elements either including or excluding the terminator you specified.

Note how a `throwsIfOver` parameter is necessary — this is to prevent un-bounded reads from running out of control. If the terminator is not detected, or your maximum element allowance has been reached, an `AsyncSequenceReaderError.terminationNotFound` error will be thrown.

You can bypass the `throwsIfOver` parameter if you use a **sequence transform** instead, which may be a better option if your algorithm deals with large amounts of data. If you stop reading early, elements can still be read by subsequent requests, giving you more control over how to read your data.

Also note that is you use a **sequence transform**, you can only collect a sequence up to and including your terminator, and no error will be thrown if your terminator was never encountered, since you can easily check `result.suffix(termination.count) == termination` to verify this yourself, allowing you the possibility of handling different data lengths yourself.

### Integration with Bytes

`AsyncSequenceReader` really shines when you combine it with [Bytes](https://github.com/mochidev/Bytes), another package specialized in dealing with and transforming byte sequences. For instance, if you wanted to decode data frames that consist of a four byte payload size, a null terminated header string, and a payload, you could do so easily like this:

```swift
struct DataFrame {
    var command: String
    var payload: [UInt8]
}

let url = ...
let sequence = url.resourceBytes

let results = sequence.iteratorMap { iterator -> DataFrame? in
    guard let payloadCountBytes = try await iterator.count(4) else { throw DataFrameError.missingPayloadSize }
    var payloadSize = try UInt32(bigEndianBytes: payloadCountBytes)
    
    guard let commandBytes = try await iterator.count(upToExcluding: 0, throwsIfOver: min(256, payloadSize)) else { throw DataFrameError.missingCommand }
    let commandString = String(utf8Bytes: commandBytes)
    payloadSize -= commandBytes.count - 1 // Don't forget the null byte we skipped
    
    guard let payloadBytes = try await iterator.count(payloadSize) else { throw DataFrameError.missingPayload }
    
    return DataFrame(command: commandString, payload: payloadBytes)
}

// Do something with the results:
for await dataFrame in results {
    print(dataFrame)
}
```

Better yet, [Bytes](https://github.com/mochidev/Bytes) will soon be getting support for reading from `AsyncIteratorProtocol` directly, allowing you to simplify the above to:

```swift
struct DataFrame {
    var command: String
    var payload: [UInt8]
}

let url = ...
let sequence = url.resourceBytes

let results = sequence.iteratorMap { iterator -> DataFrame? in
    var payloadSize = try await iterator.next(bigEndian: UInt32.self)
    
    let commandString = try await iterator.next(utf8StringUpToExcluding: 0, throwsIfOver: min(256, payloadSize))
    payloadSize -= commandString.utf8.count - 1 // Don't forget the null byte we skipped
    
    guard let payloadBytes = try await iterator.count(payloadSize) else { throw DataFrameError.missingPayload }
    
    return DataFrame(command: commandString, payload: payloadBytes)
}

// Do something with the results:
for await dataFrame in results {
    print(dataFrame)
}
```

### More

For more examples, please take a look at the unit tests provided in this package. If a good example isn't listed, please consider submitting a PR to show how it's done!

## Contributing

Contribution is welcome! Please take a look at the issues already available, or start a new issue to discuss a new feature. Although guarantees can't be made regarding feature requests, PRs that fit with the goals of the project and that have been discussed before hand are more than welcome!

Please make sure that all submissions have clean commit histories, are well documented, and thoroughly tested. **Please rebase your PR** before submission rather than merge in `main`. Linear histories are required.
