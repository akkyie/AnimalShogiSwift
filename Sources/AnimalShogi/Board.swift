struct Position: Equatable, Hashable {
    let x: Int
    let y: Int

    init?(x: Int, y: Int) {
        guard 0 <= x && x < 3 && 0 <= y && y < 4 else { return nil }

        self.x = x
        self.y = y
    }
}

extension Position: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Int...) {
        assert(elements.count == 2, "The array must have just 2 elements to express Position")
        x = elements[0]
        y = elements[1]
    }
}

extension Position: CustomStringConvertible {
    var description: String {
        return "(\(x), \(y))"
    }
}

struct Move: Equatable, Hashable {
    let x: Int
    let y: Int
}

extension Move: CustomStringConvertible {
    var description: String {
        return "(\(x), \(y))"
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

enum PieceKind: Equatable, Hashable {
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

enum Piece: Equatable, Hashable {
    case ours(PieceKind)
    case theirs(PieceKind)

    var kind: PieceKind {
        switch self {
        case let .ours(kind), let .theirs(kind):
            return kind
        }
    }

    var isOurs: Bool {
        switch self {
        case .ours: return true
        case .theirs: return false
        }
    }
}

extension Piece {
    static func movablePoints(from position: Position, in board: Board) -> Set<Position> {
        guard let piece = board[position] else {
            return []
        }

        var set = Set<Position>()
        for move in piece.kind.possibleMoves {
            guard let newPosition = piece.isOurs ? position + move : position - move else {
                continue // 壁の外
            }
            if let newPiece = board[newPosition], piece.isOurs == newPiece.isOurs {
                continue // 自分の駒の上
            }
            set.insert(newPosition)
        }
        return set
    }
}

struct Board: Equatable, Hashable {
    private var board: [[Piece?]]

    subscript(position: Position) -> Piece? {
        return board[position.y][position.x]
    }

    init() {
        board = [
            [.theirs(.kirin), .theirs(.lion),   .theirs(.zou)],
            [nil,             .theirs(.hiyoko), nil],
            [nil,             .ours(.hiyoko),   nil],
            [.ours(.zou),     .ours(.lion),     .ours(.kirin)],
        ]
    }
}
