//
// Xcore
// Copyright © 2022 Xcore
// MIT license, see LICENSE file for details
//

import Foundation

/// An asynchronous sequence that uses continuation to produce new elements.
///
/// Unlike ``AsyncCurrentValueStream``, a ``AsyncPassthroughStream`` doesn’t
/// have an initial value or a buffer of the most recently-published element.
///
/// ```swift
/// let stream = AsyncPassthroughStream<Int>()
///
/// // Produce new elements
/// stream.send(1)
/// stream.send(2)
///
/// // Finish producing elements
/// stream.finish()
/// ```
public final class AsyncPassthroughStream<Element>: AsyncSequence {
    fileprivate typealias Base = AsyncStream<Element>
    private typealias Continuation = Base.Continuation
    private var continuations = [AnyHashable: Continuation]()

    /// Creates an asynchronous sequence.
    public init() {}

    /// Resume the task awaiting the next iteration point by having it return
    /// nomally from its suspension point with a given element.
    ///
    /// If nothing is awaiting the next value, this method attempts to buffer the
    /// result's element.
    ///
    /// This can be called more than once and returns to the caller immediately
    /// without blocking for any awaiting consumption from the iteration.
    ///
    /// - Parameter value: The value to send from the continuation.
    public func send(_ value: Element) {
        continuations.values.forEach {
            $0.yield(value)
        }
    }

    /// Resume the task awaiting the next iteration point by having it return
    /// `nil`, which signifies the end of the iteration.
    ///
    /// Calling this function more than once has no effect. After calling finish,
    /// the stream enters a terminal state and doesn't produces any additional
    /// elements.
    public func finish() {
        continuations.values.forEach {
            $0.finish()
        }

        continuations.removeAll()
    }
}

// MARK: - Iterator

extension AsyncPassthroughStream {
    public func makeAsyncIterator() -> Iterator {
        let id = UUID()

        let stream = AsyncStream<Element> { [weak self] continuation in
            self?.continuations[id] = continuation
        }

        return Iterator(stream.makeAsyncIterator()) { [weak self] in
            self?.continuations[id] = nil
        }
    }

    public struct Iterator: AsyncIteratorProtocol {
        private var iterator: Base.Iterator
        private let onCancel: () -> Void

        fileprivate init(_ iterator: Base.Iterator, onCancel: @escaping () -> Void) {
            self.iterator = iterator
            self.onCancel = onCancel
        }

        public mutating func next() async -> Element? {
            guard !Task.isCancelled else {
                onCancel()
                return nil
            }

            let next = await iterator.next()
            if next == nil {
                onCancel()
            }
            return next
        }
    }
}

// MARK: - AsyncStream

extension AsyncPassthroughStream {
    /// Creates an asynchronous sequence that produce new elements over time.
    public func makeAsyncStream() -> AsyncStream<Element> {
        AsyncStream { continuation in
            Task {
                for await value in self {
                    continuation.yield(value)
                }
            }
        }
    }
}