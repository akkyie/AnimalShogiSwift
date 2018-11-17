public struct Position: Equatable, Hashable {
    let x: Int
    let y: Int

    init?(x: Int, y: Int) {
        guard 0 <= x && x < 3 && 0 <= y && y < 4 else { return nil }

        self.x = x
        self.y = y
    }
}

extension Position: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Int...) {
        assert(elements.count == 2, "The array must have just 2 elements to express Position")
        x = elements[0]
        y = elements[1]
    }
}

extension Position: CustomStringConvertible {
    public var description: String {
        let column = x + 1
        let row = UnicodeScalar(("a" as UnicodeScalar).value + UInt32(y))!
        return "\(column)\(String(row))"
    }
}

extension Position: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(description) (\(x), \(y))"
    }
}

extension Position {
    init?<T: StringProtocol>(_ string: T) {
        guard string.count == 2 else { return nil }

        switch string.first {
        case "1": x = 0
        case "2": x = 1
        case "3": x = 2
        default: return nil
        }

        switch string.last {
        case "a": y = 0
        case "b": y = 1
        case "c": y = 2
        case "d": y = 3
        default: return nil
        }
    }
}

struct Move: Equatable, Hashable {
    let x: Int
    let y: Int
}

extension Move: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Int...) {
        assert(elements.count == 2, "The array must have just 2 elements to express Move")
        x = elements[0]
        y = elements[1]
    }
}

extension Position {
    static func + (lhs: Position, rhs: Move) -> Position? {
        return Position(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: Position, rhs: Move) -> Position? {
        return Position(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}
