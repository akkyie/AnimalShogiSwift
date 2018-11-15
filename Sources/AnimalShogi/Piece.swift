public enum PieceKind: Character, Equatable, Hashable {
    case hiyoko = "h"
    case zou = "z"
    case kirin = "k"
    case lion = "l"
    case niwatori = "n"

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

    public var promoted: PieceKind? {
        return self == .hiyoko ? .niwatori : nil
    }

    public var droppable: Bool {
        switch self {
        case .hiyoko, .zou, .kirin: return true
        case .lion, .niwatori: return false
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

    public func promoted(on position: Position) -> Piece? {
        switch (self, position.x, position.y) {
        case (.black(.hiyoko), _, 0):
            return .black(.niwatori)
        case (.white(.hiyoko), _, 3):
            return .white(.niwatori)
        default:
            return nil
        }
    }
}

extension Piece: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .black(kind): return String(kind.rawValue).uppercased()
        case let .white(kind): return String(kind.rawValue)
        }
    }
}
