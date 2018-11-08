enum Result: Equatable {
    case win
    case draw
    case lose
}

enum CommunicationState {
    case waitingSummary
    case waitingID
    case waitingTurn(id: String)
    case starting(id: String, isBlack: Bool)
    case started(id: String, isBlack: Bool)
    case waitingResult(id: String, isBlack: Bool, isIllegal: Bool)
    case ended(id: String, isBlack: Bool, isIllegal: Bool, result: Result)

    func receive(message: Message) -> CommunicationState? {
        switch (self, message) {
        case (.waitingSummary, .beginSummary):
            return .waitingID
        case let (.waitingID, .gameID(id)):
            return .waitingTurn(id: id)
        case let (.waitingTurn(id), .turn(isBlack)):
            return .starting(id: id, isBlack: isBlack)
        case let (.starting(id, isBlack), .start):
            return .started(id: id, isBlack: isBlack)
        case let (.started(id, isBlack), .gameOver(isIllegal)):
            return .waitingResult(id: id, isBlack: isBlack, isIllegal: isIllegal)
        case let (.waitingResult(id, isBlack, isIllegal), .result(result)):
            return .ended(id: id, isBlack: isBlack, isIllegal: isIllegal, result: result)
        default:
            return nil
        }
    }
}
