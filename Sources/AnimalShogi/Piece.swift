public struct Piece: Equatable, Hashable {
    public enum Kind: Character, Equatable, Hashable {
        case hiyoko = "h"
        case zou = "z"
        case kirin = "k"
        case lion = "l"
        case niwatori = "n"
    }

    public let turn: Turn
    public let kind: Kind

    public init(turn: Turn, kind: Kind) {
        self.turn = turn
        self.kind = kind
    }
}

extension Piece: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        assert(value.count == 1)
        let char = value.lowercased()[value.startIndex]
        turn = char != value[value.startIndex] ? .black : .white
        kind = Piece.Kind(rawValue: char)!
    }
}

extension Piece {
    public var isBlack: Bool {
        return turn == .black
    }

    public func promoted(on position: Position) -> Piece? {
        switch (turn, kind, position.x, position.y) {
        case (.black, .hiyoko, _, 0):
            return Piece(turn: .black, kind: .niwatori)
        case (.white, .hiyoko, _, 3):
            return Piece(turn: .white, kind: .niwatori)
        default:
            return nil
        }
    }
}

extension Piece: CustomStringConvertible {
    public var description: String {
        switch turn {
        case .black: return String(kind.rawValue).uppercased()
        case .white: return String(kind.rawValue)
        }
    }
}

extension Piece.Kind {
    var possibleMoves: Set<Move> {
        switch self {
        case .hiyoko:
            return [
                [+0, -1],
            ]
        case .zou:
            return [
                [-1, -1], [+1, -1],
                [+1, +1], [-1, +1],
            ]
        case .kirin:
            return [
                [+0, -1], [+1, +0],
                [+0, +1], [-1, +0],
            ]
        case .lion:
            return [
                [-1, -1], [-1, +0], [-1, +1],
                [+0, -1], [+0, +0], [+0, +1],
                [+1, -1], [+1, +0], [+1, +1],
            ]
        case .niwatori:
            return [
                [-1, -1], [-1, +0],
                [+0, -1], [+0, +0], [+0, +1],
                [+1, -1], [+1, +0],
            ]
        }
    }

    public var promoted: Piece.Kind? {
        return self == .hiyoko ? .niwatori : nil
    }

    public var unpromoted: Piece.Kind? {
        return self == .niwatori ? .hiyoko : nil
    }
}
