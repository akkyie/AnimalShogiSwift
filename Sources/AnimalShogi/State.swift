public enum Result: Equatable {
    case win
    case draw
    case lose
}

extension Result: CustomStringConvertible {
    public var description: String {
        switch self {
        case .win: return "#WIN"
        case .draw: return "#DRAW"
        case .lose: return "#LOSE"
        }
    }
}

public enum State: Equatable {
    case waitingBeginSummary
    case waitingID
    case waitingTurn(id: String)
    case waitingEndSummary(id: String, isBlack: Bool)
    case starting(id: String, isBlack: Bool)
    case started(id: String, isBlack: Bool)
    case moved(id: String, isBlack: Bool, from: Position, to: Position, isPromoted: Bool)
    case dropped(id: String, isBlack: Bool, kind: PieceKind, to: Position)
    case waitingResult(id: String, isBlack: Bool, isIllegal: Bool)
    case ended(id: String, isBlack: Bool, isIllegal: Bool, result: Result)

    public func received(message: Message) -> State? {
        switch (self, message) {
        case (.waitingBeginSummary, .beginSummary):
            return .waitingID

        case let (.waitingID, .gameID(id)):
            return .waitingTurn(id: id)

        case let (.waitingTurn(id), .turn(isBlack)):
            return .waitingEndSummary(id: id, isBlack: isBlack)

        case let (.waitingEndSummary(id, isBlack), .endSummary):
            return .starting(id: id, isBlack: isBlack)

        case let (.starting(id, isBlack), .start):
            return .started(id: id, isBlack: isBlack)

        case let (.started(id, _), .moved(from, to, isBlack, isPromoted)):
            return .moved(id: id, isBlack: isBlack, from: from, to: to, isPromoted: isPromoted)

        case let (.moved(id, _, _, _, _), .moved(from, to, isBlack, isPromoted)),
             let (.dropped(id, _, _, _), .moved(from, to, isBlack, isPromoted)):
            return .moved(id: id, isBlack: isBlack, from: from, to: to, isPromoted: isPromoted)

        case let (.moved(id, _, _, _, _), .dropped(kind, to, isBlack)),
             let (.dropped(id, _, _, _), .dropped(kind, to, isBlack)):
            return .dropped(id: id, isBlack: isBlack, kind: kind, to: to)

        case let (.moved(id, isBlack, _, _, _), .gameOver(isIllegal)):
            return .waitingResult(id: id, isBlack: isBlack, isIllegal: isIllegal)

        case let (.waitingResult(id, isBlack, isIllegal), .result(result)):
            return .ended(id: id, isBlack: isBlack, isIllegal: isIllegal, result: result)

        default:
            return nil
        }
    }

    public var hasEnded: Bool {
        if case .ended = self {
            return true
        }
        return false
    }
}
