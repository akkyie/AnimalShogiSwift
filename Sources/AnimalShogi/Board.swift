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

    public mutating func move(from: Position, to: Position, isPromoted: Bool) {
        guard var moving = self[from] else { preconditionFailure("piece not found at \(from.debugDescription)") }
        if isPromoted {
            guard let promoted = moving.promoted(on: to) else {
                preconditionFailure("piece at \(to.debugDescription) is not promotable: \(moving)")
            }
            moving = promoted
        }
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
