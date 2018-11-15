public enum Message: Equatable {
    case beginSummary
    case gameID(String)
    case turn(isBlack: Bool)
    case endSummary
    case agree
    case start
    case move(from: Position, to: Position, isBlack: Bool, isPromoted: Bool)
    case drop(kind: PieceKind, to: Position, isBlack: Bool)
    case moved(from: Position, to: Position, isBlack: Bool, isPromoted: Bool)
    case dropped(kind: PieceKind, to: Position, isBlack: Bool)
    case gameOver(isIllegal: Bool)
    case result(Result)

    public init?(line: String) {
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

        if line.first == "+" || line.first == "-" {
            var line = line
            let isBlack = line.removeFirst() == "+"

            guard let first = line.first else { return nil }

            let fromIndex = line.index(line.startIndex, offsetBy: 2)
            let toIndex = line.index(fromIndex, offsetBy: 2)

            Drop: if let kind = PieceKind(rawValue: first), let to = Position(line[fromIndex ..< toIndex]) {
                let suffix = line[toIndex...]
                switch suffix {
                case "":
                    self = .drop(kind: kind, to: to, isBlack: isBlack)
                    return
                case ",OK":
                    self = .dropped(kind: kind, to: to, isBlack: isBlack)
                    return
                default:
                    break Drop
                }
            }

            guard
                let from = Position(line[..<fromIndex]),
                let to = Position(line[fromIndex ..< toIndex])
            else { return nil }

            let suffix = line[toIndex...]
            switch suffix {
            case "":
                self = .move(from: from, to: to, isBlack: isBlack, isPromoted: false)
                return
            case "+":
                self = .move(from: from, to: to, isBlack: isBlack, isPromoted: true)
                return
            case ",OK":
                self = .moved(from: from, to: to, isBlack: isBlack, isPromoted: false)
                return
            case "+,OK":
                self = .moved(from: from, to: to, isBlack: isBlack, isPromoted: true)
                return
            default:
                return nil
            }
        }

        let parts = line.split(separator: ":")
        switch (parts.first, parts.last) {
        case ("Your_Turn", "+"):
            self = .turn(isBlack: true)
            return
        case ("Your_Turn", "-"):
            self = .turn(isBlack: false)
            return
        case let ("Game_ID", id?):
            self = .gameID(String(id))
            return
        default:
            break
        }

        return nil
    }
}

extension String {
    public init(_ message: Message) {
        switch message {
        case .beginSummary:
            self = "BEGIN Game_Summary"
        case let .gameID(id):
            self = id
        case let .turn(isBlack):
            self = "Your_Turn:\(isBlack ? "+" : "-")"
        case .endSummary:
            self = "END Game_Summary"
        case .agree:
            self = "AGREE"
        case .start:
            self = "START"
        case let .move(from, to, isBlack, isPromoted):
            self = "\(isBlack ? "+" : "-")\(from.description)\(to.description)\(isPromoted ? "+" : "")"
        case let .drop(kind, to, isBlack):
            self = "\(isBlack ? "+" : "-")\(kind.rawValue)*\(to.description)"
        case let .moved(from, to, isBlack, isPromoted):
            self = "\(isBlack ? "+" : "-")\(from.description)\(to.description)\(isPromoted ? "+" : ""),OK"
        case let .dropped(kind, to, isBlack):
            self = "\(isBlack ? "+" : "-")\(kind.rawValue)*\(to.description),OK"
        case let .gameOver(isIllegal):
            self = !isIllegal ? "#GAME_OVER" : "#ILLEGAL_MOVE"
        case let .result(result):
            self = result.description
        }
    }
}
