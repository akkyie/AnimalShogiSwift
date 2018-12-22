public enum ServerMessage: Equatable {
    case beginSummary
    case gameID(String)
    case turn(Turn)
    case endSummary
    case start
    case moved(turn: Turn, from: Position, to: Position, isPromoted: Bool)
    case dropped(turn: Turn, kind: Piece.Kind, to: Position)
    case gameOver(isIllegal: Bool)
    case result(GameResult)
    case login(name: String)
    case chat(String)

    public init(line: String) {
        switch line {
        case "BEGIN Game_Summary":
            self = .beginSummary
            return
        case "END Game_Summary":
            self = .endSummary
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
        case let ("LOGIN", name?):
            self = .login(name: String(name))
            return
        default:
            break
        }

        self = .chat(line)
    }
}

public enum ClientMessage: Equatable {
    case agree
    case move(turn: Turn, from: Position, to: Position, isPromoted: Bool)
    case drop(turn: Turn, kind: Piece.Kind, to: Position)
    case chat(String)
    case login(name: String)
}

extension String {
    public init(_ message: ClientMessage) {
        switch message {
        case .agree:
            self = "AGREE"
        case let .move(turn, from, to, isPromoted):
            self = "\(turn.rawValue)\(from.description)\(to.description)\(isPromoted ? "+" : "")"
        case let .drop(turn, kind, to):
            self = "\(turn.rawValue)\(kind.rawValue)*\(to.description)"
        case let .chat(message):
            self = message
        case let .login(name):
            self = "LOGIN:\(name)"
        }
    }
}
