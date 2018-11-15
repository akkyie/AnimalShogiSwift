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

    public var promoted: PieceKind? {
        return self == .hiyoko ? .niwatori : nil
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
