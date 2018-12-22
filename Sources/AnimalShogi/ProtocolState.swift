public enum GameResult: Equatable {
    case win
    case draw
    case lose
}

public struct GameSummary: Equatable {
    public let id: String
    public let turn: Turn
}

public enum ProtocolState: Equatable {
    case waitingBeginSummary
    case waitingID
    case waitingTurn(id: String)
    case waitingEndSummary(GameSummary)
    case starting(summary: GameSummary)
    case started(summary: GameSummary)
    case waitingResult(summary: GameSummary, isIllegal: Bool)
    case ended(summary: GameSummary, isIllegal: Bool, result: GameResult)

    public func received(message: ServerMessage) -> ProtocolState? {
        switch (self, message) {
        case (.waitingBeginSummary, .beginSummary):
            return .waitingID

        case let (.waitingID, .gameID(id)):
            return .waitingTurn(id: id)

        case let (.waitingTurn(id), .turn(turn)):
            return .waitingEndSummary(GameSummary(id: id, turn: turn))

        case let (.waitingEndSummary(summary), .endSummary):
            return .starting(summary: summary)

        case let (.starting(summary), .start):
            return .started(summary: summary)

        case let (.started(summary), .gameOver(isIllegal)):
            return .waitingResult(summary: summary, isIllegal: isIllegal)

        case let (.waitingResult(summary, isIllegal), .result(result)):
            return .ended(summary: summary, isIllegal: isIllegal, result: result)

        default:
            return nil
        }
    }

    public var hasStarted: Bool {
        switch self {
        case .waitingBeginSummary,
             .waitingID,
             .waitingTurn,
             .waitingEndSummary,
             .starting:
            return false
        case .started,
             .waitingResult,
             .ended:
            return true
        }
    }

    public var summary: GameSummary? {
        switch self {
        case let .starting(summary),
             let .started(summary),
             let .waitingResult(summary, _),
             let .ended(summary, _, _):
            return summary
        default:
            return nil
        }
    }

    public var hasEnded: Bool {
        switch self {
        case .waitingBeginSummary,
             .waitingID,
             .waitingTurn,
             .waitingEndSummary,
             .starting,
             .started:
            return false
        case .waitingResult,
             .ended:
            return true
        }
    }
}
