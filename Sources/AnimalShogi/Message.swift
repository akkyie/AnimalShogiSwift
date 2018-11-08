enum Message: Equatable {
    case beginSummary
    case endSummary
    case agree
    case start
    case gameID(String)
    case turn(isBlack: Bool)
    case gameOver(isIllegal: Bool)
    case result(Result)

    init?(line: String) {
        switch line {
        case "BEGIN Game_Summary":
            self = .beginSummary
            return
        case "END Game_Summary":
            self = .endSummary
            return
        case "AGREE":
            self = .agree
            return
        case "START":
            self = .start
            return
        case "#GAME_OVER":
            self = .gameOver(isIllegal: false)
            return
        case "#ILLEGAL_MOVE":
            self = .gameOver(isIllegal: true)
            return
        case "#WIN":
            self = .result(.win)
            return
        case "#DRAW":
            self = .result(.draw)
            return
        case "#LOSE":
            self = .result(.lose)
            return
        default:
            break
        }

        let parts = line.split(separator: ":")
        guard parts.count == 2 else {
            return nil
        }

        switch (parts[0], parts[1]) {
        case let ("Game_ID", id) where !id.isEmpty:
            self = .gameID(String(id))
            return
        case ("Your_Turn", "+"):
            self = .turn(isBlack: true)
            return
        case ("Your_Turn", "-"):
            self = .turn(isBlack: false)
            return
        default:
            break
        }

        return nil
    }
}
