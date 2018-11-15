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

extension Move: CustomDebugStringConvertible {
    var debugDescription: String {
        return "[\(x), \(y)]"
    }
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

public enum PieceKind: Equatable, Hashable {
    case hiyoko
    case zou
    case kirin
    case lion
    case niwatori

    var possibleMoves: Set<Move> {
        switch self {
        case .hiyoko:
            return [
                [0, -1],
            ]
        case .zou:
            return [
                [-1, -1], [1, -1], [1, 1], [-1, 1],
            ]
        case .kirin:
            return [
                [0, -1], [1, 0], [0, 1], [-1, 0],
            ]
        case .lion:
            return [
                [-1, -1], [-1, 0], [-1, 1],
                [0, -1], [0, 0], [0, 1],
                [1, -1], [1, 0], [1, 1],
            ]
        case .niwatori:
            return [
                [-1, -1], [-1, 0],
                [0, -1], [0, 0], [0, 1],
                [1, -1], [1, 0],
            ]
        }
    }
}

public enum Piece: Equatable, Hashable {
    case black(PieceKind)
    case white(PieceKind)

    public var kind: PieceKind {
        switch self {
        case let .black(kind), let .white(kind):
            return kind
        }
    }

    public var isBlack: Bool {
        switch self {
        case .black: return true
        case .white: return false
        }
    }
}

extension Piece: CustomStringConvertible {
    public var description: String {
        switch self {
        case .black(.hiyoko): return "h"
        case .white(.hiyoko): return "H"
        case .black(.zou): return "z"
        case .white(.zou): return "Z"
        case .black(.kirin): return "k"
        case .white(.kirin): return "K"
        case .black(.lion): return "l"
        case .white(.lion): return "L"
        case .black(.niwatori): return "n"
        case .white(.niwatori): return "N"
        }
    }
}

public struct Board: Equatable, Hashable {
    private var board: [[Piece?]]

    public subscript(position: Position) -> Piece? {
        get { return board[position.y][position.x] }
        set(piece) { board[position.y][position.x] = piece }
    }

    public init() {
        board = [
            [.white(.kirin), .white(.lion), .white(.zou)],
            [nil, .white(.hiyoko), nil],
            [nil, .black(.hiyoko), nil],
            [.black(.zou), .black(.lion), .black(.kirin)],
        ]
    }
}

extension Board {
    public var pieces: [Position: Piece] {
        var pieces: [Position: Piece] = [:]
        for (y, row) in board.enumerated() {
            for case let (x, piece?) in row.enumerated() {
                pieces[[x, y]] = piece
            }
        }
        return pieces
    }

    public func movablePoints(from position: Position) -> Set<Position> {
        guard let piece = self[position] else {
            return []
        }

        var set = Set<Position>()
        for move in piece.kind.possibleMoves {
            guard let newPosition = piece.isBlack ? position + move : position - move else {
                continue // 壁の外
            }
            if let newPiece = self[newPosition], piece.isBlack == newPiece.isBlack {
                continue // 自分の駒の上
            }
            set.insert(newPosition)
        }
        return set
    }

    public mutating func move(from: Position, to: Position) {
        let moving = self[from]
        self[from] = nil
        self[to] = moving
    }
}

extension Board: CustomStringConvertible {
    public var description: String {
        return board
            .map { pieces in pieces.map { piece in piece?.description ?? " " }.joined(separator: "|") }
            .joined(separator: "\n")
    }
}
