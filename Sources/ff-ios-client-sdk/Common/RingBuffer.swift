import Foundation

public struct RingBuffer<Element> {
    public let capacity: Int
    private var underlying: [Element] = []
    private var index: Int = 0

    public init(capacity: Int, initial: [Element] = []) {
        precondition(capacity > 0, "A positive capacity is required")
        underlying = Array(initial.suffix(capacity))
        self.capacity = capacity
        index = underlying.count % capacity
    }

    public mutating func push(_ value: Element) {
        if underlying.count < capacity {
            underlying.append(value)
        } else {
            underlying[index] = value
        }
        index = (index + 1) % capacity
    }

    public mutating func pop() -> Element? {
        defer {
            underlying = .init(dropFirst())
            index = underlying.count
        }
        return first
    }

    public mutating func dropAll() {
        underlying = []
        index = 0
    }

    public subscript(offset: Int) -> Element {
        return underlying[(index + offset) % underlying.count]
    }
}

extension RingBuffer: Sequence {
    public func makeIterator() -> AnyIterator<Element> {
        let count = underlying.count
        var index = 0
        return AnyIterator {
            defer { index += 1 }
            if index < count {
                return self[index]
            } else {
                return nil
            }
        }
    }
}

extension RingBuffer: BidirectionalCollection {
    public func index(before i: Int) -> Int {
        return i - 1
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }

    public var startIndex: Int {
        return underlying.startIndex
    }

    public var endIndex: Int {
        return underlying.endIndex
    }
}

extension RingBuffer: CustomStringConvertible {
    public var description: String {
        return ["[", map(String.init(describing:)).joined(separator: ", "), "]"].joined()
    }
}
