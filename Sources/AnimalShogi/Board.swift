public enum Turn: Character, Equatable, Hashable {
    case black = "+"
    case white = "-"
}

public struct Board: Equatable, Hashable {
    private var board: [[Piece?]]

    public private(set) var blackCaptured: [Piece.Kind]
    public private(set) var whiteCaptured: [Piece.Kind]

    public subscript(position: Position) -> Piece? {
        get { return board[position.y][position.x] }
        set(piece) { board[position.y][position.x] = piece }
    }

    public init(
        board: [[Piece?]] = [
            ["k", "l", "z"],
            [nil, "h", nil],
            [nil, "H", nil],
            ["Z", "L", "K"],
        ],
        blackCaptured: [Piece.Kind] = [],
        whiteCaptured: [Piece.Kind] = []
    ) {
        self.board = board
        self.blackCaptured = blackCaptured
        self.whiteCaptured = whiteCaptured
    }
}

extension Board {
    public enum Error: Swift.Error, Equatable {
        case pieceNotFound(at: Position)
        case pieceNotMine(at: Position)
        case pieceNotPromotable(at: Position)
        case pieceAlreadyExists(at: Position)
        case pieceNotCaptured(kind: Piece.Kind)
    }
}

extension Board {
    public var positions: Set<Position> {
        var positions = Set<Position>()
        for (y, row) in board.enumerated() {
            for x in row.indices {
                positions.insert([x, y])
            }
        }
        return positions
    }

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

    public mutating func move(turn: Turn, from: Position, to: Position, isPromoted: Bool) throws {
        guard var moving = self[from] else {
            throw Error.pieceNotFound(at: from)
        }
        guard moving.turn == turn else {
            throw Error.pieceNotMine(at: from)
        }

        if isPromoted {
            guard let promoted = moving.promoted(on: to) else {
                throw Error.pieceNotPromotable(at: to)
            }
            moving = promoted
        }

        self[from] = nil
        let captured = self[to]
        self[to] = moving

        if let captured = captured {
            let kind = captured.kind.unpromoted ?? captured.kind
            turn == .black ? blackCaptured.append(kind) : whiteCaptured.append(kind)
        }
    }

    public mutating func drop(turn: Turn, kind: Piece.Kind, to: Position) throws {
        guard self[to] == nil else {
            throw Error.pieceAlreadyExists(at: to)
        }

        if turn == .black {
            guard let index = blackCaptured.firstIndex(of: kind) else {
                throw Error.pieceNotCaptured(kind: kind)
            }
            blackCaptured.remove(at: index)
        } else {
            guard let index = whiteCaptured.firstIndex(of: kind) else {
                throw Error.pieceNotCaptured(kind: kind)
            }
            whiteCaptured.remove(at: index)
        }

        self[to] = Piece(turn: turn, kind: kind)
    }
}

extension Board: CustomStringConvertible {
    public var description: String {
        return board
            .map { pieces in "|" + pieces.map { piece in piece?.description ?? " " }.joined(separator: "|") + "|" }
            .joined(separator: "\n")
    }
}
