public enum Message: Equatable {
    case beginSummary
    case gameID(String)
    case turn(Turn)
    case endSummary
    case agree
    case start
    case move(turn: Turn, from: Position, to: Position, isPromoted: Bool)
    case drop(turn: Turn, kind: Piece.Kind, to: Position)
    case moved(turn: Turn, from: Position, to: Position, isPromoted: Bool)
    case dropped(turn: Turn, kind: Piece.Kind, to: Position)
    case gameOver(isIllegal: Bool)
    case result(GameResult)
    case chat(String)

    public init(line: String) {
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
        case "#ILLEGAL":
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

        MoveOrDrop: if line.count >= 5, let turnchar = line.first, let turn = Turn(rawValue: turnchar) {
            let line = line[line.index(after: line.startIndex)...]
            let fromIndex = line.index(line.startIndex, offsetBy: 2)
            let toIndex = line.index(fromIndex, offsetBy: 2)
            let kindchar = line[line.startIndex]

            Drop: if let kind = Piece.Kind(rawValue: kindchar), let to = Position(line[fromIndex ..< toIndex]) {
                let suffix = line[toIndex...]
                switch suffix {
                case "":
                    self = .drop(turn: turn, kind: kind, to: to)
                    return
                case ",OK":
                    self = .dropped(turn: turn, kind: kind, to: to)
                    return
                default:
                    break Drop
                }
            }

            guard
                let from = Position(line[..<fromIndex]),
                let to = Position(line[fromIndex ..< toIndex])
            else { break MoveOrDrop }

            let suffix = line[toIndex...]
            switch suffix {
            case "":
                self = .move(turn: turn, from: from, to: to, isPromoted: false)
                return
            case "+":
                self = .move(turn: turn, from: from, to: to, isPromoted: true)
                return
            case ",OK":
                self = .moved(turn: turn, from: from, to: to, isPromoted: false)
                return
            case "+,OK":
                self = .moved(turn: turn, from: from, to: to, isPromoted: true)
                return
            default:
                break MoveOrDrop
            }
        }

        let parts = line.split(separator: ":")
        switch (parts.first, parts.last) {
        case ("Your_Turn", "+"):
            self = .turn(.black)
            return
        case ("Your_Turn", "-"):
            self = .turn(.white)
            return
        case let ("Game_ID", id?):
            self = .gameID(String(id))
            return
        default:
            break
        }

        self = .chat(line)
    }
}

extension String {
    public init(_ message: Message) {
        switch message {
        case .beginSummary:
            self = "BEGIN Game_Summary"
        case let .gameID(id):
            self = "Game_ID:\(id)"
        case let .turn(turn):
            self = "Your_Turn:\(turn.rawValue)"
        case .endSummary:
            self = "END Game_Summary"
        case .agree:
            self = "AGREE"
        case .start:
            self = "START"
        case let .move(turn, from, to, isPromoted):
            self = "\(turn.rawValue)\(from.description)\(to.description)\(isPromoted ? "+" : "")"
        case let .drop(turn, kind, to):
            self = "\(turn.rawValue)\(kind.rawValue)*\(to.description)"
        case let .moved(turn, from, to, isPromoted):
            self = "\(turn.rawValue)\(from.description)\(to.description)\(isPromoted ? "+" : ""),OK"
        case let .dropped(turn, kind, to):
            self = "\(turn.rawValue)\(kind.rawValue)*\(to.description),OK"
        case let .gameOver(isIllegal):
            self = !isIllegal ? "#GAME_OVER" : "#ILLEGAL"
        case let .result(result):
            self = result.description
        case let .chat(message):
            self = message
        }
    }
}
